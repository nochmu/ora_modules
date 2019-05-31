CREATE OR REPLACE PACKAGE BODY om_helper_pkg IS
    /* ora_modules - Version 2
    * Copyright 2018-2019 Christian Mühlhaus
    *   https://github.com/nochmu/ora_modules
    *
    * Licensed to the Apache Software Foundation (ASF) under one
    * or more contributor license agreements.  See the NOTICE file
    * distributed with this work for additional information
    * regarding copyright ownership.  The ASF licenses this file
    * to you under the Apache License, Version 2.0 (the
    * "License"); you may not use this file except in compliance
    * with the License.  You may obtain a copy of the License at
    *
    *   http://www.apache.org/licenses/LICENSE-2.0
    *
    * Unless required by applicable law or agreed to in writing,
    * software distributed under the License is distributed on an
    * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
    * KIND, either express or implied.  See the License for the
    * specific language governing permissions and limitations
    * under the License. 
    */

    TYPE t_grant IS RECORD(
        object_name t_identifier,
        privileges  t_privilege_list);

    TYPE t_synonym IS RECORD(
        object_name  t_identifier,
        synonym_name t_identifier,
        description  t_text);

    TYPE t_kv_map       IS TABLE OF t_text INDEX BY t_key;
    TYPE t_grant_list   IS TABLE OF t_grant;
    TYPE t_synonym_list IS TABLE OF t_synonym;

    TYPE t_module_buffer IS RECORD(
        key         t_key,
        name        t_name,
        version     t_version,
        description t_text,
        owner       t_identifier , -- Module owner 
        metadata    t_kv_map       NOT NULL DEFAULT t_kv_map(),    -- Additional metadata about the module
        grants      t_grant_list   NOT NULL DEFAULT t_grant_list(),  -- Privileges for the API Objects
        synonyms    t_synonym_list NOT NULL DEFAULT t_synonym_list() -- Synonyms for the API Objects
        ); 

    -- -------------- INTERNAL VARIABLES ------------------------------------------
    
    -- OM Specification Version
    c_om_version CONSTANT t_version := '2';
    
    -- Internal buffer 
    g_buffer t_module_buffer;
    -- ----------------------------------------------------------------------------

    -- Reset the internal buffer
    PROCEDURE define_module
    (
        p_key         t_key,
        p_name        t_name,
        p_version     t_version,
        p_description t_text
    ) IS
    BEGIN
        g_buffer             := null;
        g_buffer.key         := p_key;
        g_buffer.name        := p_name;
        g_buffer.version     := p_version;
        g_buffer.description := p_description;

        g_buffer.owner       := $$PLSQL_UNIT_OWNER;
        g_buffer.metadata    := t_kv_map();   
        g_buffer.grants      := t_grant_list();
        g_buffer.synonyms    := t_synonym_list();
    
    END define_module;


    -- Set  meta data
    PROCEDURE set_metadata
    (
        p_key   t_key,
        p_value t_text
    ) IS
    BEGIN
        g_buffer.metadata(p_key) := p_value;
    END set_metadata;




    -- Adds the given object as API Object.
    PROCEDURE add_api_object
    (
        p_name        t_identifier,
        p_object      t_identifier,
        p_privileges  t_privilege_list,
        p_description t_text DEFAULT null
    ) IS
    BEGIN
        add_grant(p_object     => p_object,
                  p_privileges => p_privileges);

        add_synonym(p_object      => p_object
                   ,p_synonym     => p_name
                   ,p_description => p_description);

    END add_api_object;




    -- Adds a grant definition to the internal buffer. 
    PROCEDURE add_grant
    (
        p_object     t_identifier,
        p_privileges t_privilege_list 
    ) IS
        v_grant t_grant;
    BEGIN
        v_grant.object_name := p_object;
        v_grant.privileges  := p_privileges;

        g_buffer.grants.extend();
        g_buffer.grants(g_buffer.grants.last) := v_grant;
    
    END add_grant;




    -- Adds the synonym definition to the internal buffer
    PROCEDURE add_synonym
    (
        p_object      t_identifier,
        p_synonym     t_identifier,
        p_description t_text DEFAULT null
    ) IS
        v_synonym t_synonym;
    BEGIN
        v_synonym.object_name  := p_object;
        v_synonym.synonym_name := p_synonym;
        v_synonym.description  := p_description;
    
        g_buffer.synonyms.extend();
        g_buffer.synonyms(g_buffer.synonyms.last) := v_synonym;
    
    END add_synonym;





    -- Returns all allowed privileges for the given object. 
    FUNCTION get_object_privileges(p_object t_identifier) return t_privilege_list IS
        v_privs t_privilege_list := t_privilege_list();
    BEGIN

        FOR i IN 1 .. g_buffer.grants.count
        LOOP
            IF g_buffer.grants(i).object_name = p_object
            THEN
                v_privs := v_privs 
                            MULTISET UNION DISTINCT 
                            g_buffer.grants(i).privileges;
            END IF;
        END LOOP; 

        return v_privs;
    END get_object_privileges;

    -- --------------------------------- FORMAT DDL HELPER ------------------------------------------

    -- Returns the privilege list as comma delemited string
    FUNCTION format_privilege_list
    (
        p_privileges t_privilege_list,
        p_json       boolean DEFAULT false
    ) return varchar2 IS
        v_result varchar2(4000 BYTE);
    BEGIN
    
        FOR i IN 1 .. p_privileges.count
        LOOP
            IF v_result IS null -- v_result is empty
            THEN
                v_result := p_privileges(i);
            ELSE
                v_result := v_result || ',' || p_privileges(i);
            END IF;
        END LOOP;
    
        IF p_json
        THEN
            v_result := '["' || REPLACE(v_result,',','","') || '"]';
        END IF;
    
        return v_result;
    
    END format_privilege_list;







    /* Format the Grant as DDL Statement.
    * @param p_object     object name or null for system privileges
    * @param p_owner      object owner or null for system privileges
    * @param p_privileges Privileges to grant
    * @param p_grantee    User or role to whom the privileges are granted. 
    */
    FUNCTION format_ddl_grant
    (
        p_object       t_identifier DEFAULT null,
        p_owner        t_identifier DEFAULT null, 
        p_privileges   t_privilege_list,
        p_grantee      t_identifier
    ) return t_statement IS
        v_stmt t_statement; 
    BEGIN
        v_stmt := 'GRANT ' || format_privilege_list(p_privileges); 

        IF p_object IS NOT null
        THEN
            v_stmt := v_stmt ||  ' ON ' 
                             || CASE WHEN p_owner IS NOT NULL 
                                     THEN p_owner||'.'||p_object
                                     ELSE p_object
                                END ; 
        END IF;

        v_stmt := v_stmt || ' TO ' || p_grantee; 

        return v_stmt; 
    END format_ddl_grant;
 






    /* Format the Revoke as DDL Statement.
    * @param p_object     object name or null for system privileges
    * @param p_owner      object owner or null for system privileges
    * @param p_privileges Privileges to grant
    * @param p_grantee    User or role to whom the privileges are granted. 
    */
    FUNCTION format_ddl_revoke
    (
        p_object       t_identifier DEFAULT null,
        p_owner        t_identifier DEFAULT null,
        p_privileges   t_privilege_list,
        p_grantee      t_identifier
    ) return t_statement IS
        v_stmt t_statement; 
    BEGIN
        v_stmt := 'REVOKE ' || format_privilege_list(p_privileges); 

        IF p_object IS NOT null
        THEN
            v_stmt := v_stmt ||  ' ON ' 
                             || CASE WHEN p_owner IS NOT NULL 
                                     THEN p_owner||'.'||p_object
                                     ELSE p_object
                                END ; 
        END IF;

        v_stmt := v_stmt || ' FROM ' || p_grantee; 

        return v_stmt; 
    END format_ddl_revoke;







    -- Returns the DDL statement to create a synonym for the given object.
    FUNCTION format_ddl_create_synonym
    (
        p_object         t_identifier,
        p_object_schema  t_identifier DEFAULT null,
        p_synonym        t_identifier,
        p_synonym_schema t_identifier DEFAULT null
    ) return t_statement IS
    BEGIN
        return 'CREATE or REPLACE SYNONYM ' || 
                    CASE WHEN p_synonym_schema IS NOT null 
                         THEN p_synonym_schema || '.' || p_synonym 
                         ELSE p_synonym 
                     END 
                 || ' FOR ' || 
                    CASE WHEN p_object_schema IS NOT null 
                         THEN p_object_schema || '.' || p_object 
                         ELSE p_object 
                    END;
    END format_ddl_create_synonym;






    -- Returns the DDL statement to drop the given synonym.
    FUNCTION format_ddl_drop_synonym
    (
        p_synonym        t_identifier,
        p_synonym_schema t_identifier DEFAULT null
    ) return t_statement IS
    BEGIN
        return 'DROP SYNONYM ' 
                    || CASE WHEN p_synonym_schema IS NOT null 
                            THEN p_synonym_schema || '.' || p_synonym 
                            ELSE p_synonym 
                       END;
    END format_ddl_drop_synonym;

    -- -----------------------------------------------------------------------------------





    -- @return the DDL statements to create the role
    FUNCTION get_ddl_create_role(p_role t_identifier) return t_statement_list IS
        v_rolename t_identifier := p_role;
        v_stmts    t_statement_list := t_statement_list();
    BEGIN
    
        v_stmts.extend();
        v_stmts(v_stmts.last) := 'CREATE ROLE ' || v_rolename;
    
        v_stmts.extend();
        v_stmts(v_stmts.last) := format_ddl_grant(
            p_object     => 'om_module_api',
            p_privileges => t_privilege_list('execute'),
            p_grantee    => v_rolename
        );
    
        v_stmts.extend();
        v_stmts(v_stmts.last) := format_ddl_grant(
            p_privileges => t_privilege_list('create synonym'),
            p_grantee    => v_rolename
        );
    
        return v_stmts;
    END get_ddl_create_role;






    -- @return the DDL statements to drop the role
    FUNCTION get_ddl_drop_role(p_role t_identifier) return t_statement_list IS
        v_rolename t_identifier := p_role;
        v_stmts    t_statement_list := t_statement_list();
    BEGIN
        v_stmts.extend();
        v_stmts(v_stmts.last) := 'DROP ROLE ' || v_rolename;
        return v_stmts;
    END get_ddl_drop_role;





    -- @return the ddl to grant
    FUNCTION get_ddl_grants(p_grantee t_identifier) return t_statement_list IS
        v_grantee t_identifier     := p_grantee;
        v_stmts   t_statement_list := t_statement_list(); 
    BEGIN
    
        FOR i IN 1 .. g_buffer.grants.count()
        LOOP
            v_stmts.extend();
            v_stmts(v_stmts.last) := format_ddl_grant(
                p_object     => g_buffer.grants(i).object_name,
                p_owner      => g_buffer.owner, 
                p_privileges => g_buffer.grants(i).privileges,
                p_grantee    => v_grantee
            );
        END LOOP;
    
        return v_stmts;
    END get_ddl_grants;





    -- @return the ddl to revoke
    FUNCTION get_ddl_revokes(p_grantee t_identifier) return t_statement_list IS
        v_grantee t_identifier := p_grantee;
        v_stmts   t_statement_list := t_statement_list();
    BEGIN
    
        FOR i IN 1 .. g_buffer.grants.count
        LOOP
            v_stmts.extend();
            v_stmts(v_stmts.last) := format_ddl_revoke(
                p_object     => g_buffer.grants(i).object_name,
                p_owner      => g_buffer.owner, 
                p_privileges => g_buffer.grants(i).privileges,
                p_grantee    => v_grantee
            );
        END LOOP;
    
        return v_stmts;
    END get_ddl_revokes;






    -- Returns the target object of the given synoym. 
    FUNCTION get_object_by_synonym(p_synonym t_identifier) return t_identifier IS
        v_object t_identifier;
    BEGIN

        FOR i IN 1 .. g_buffer.synonyms.count
        LOOP
            IF g_buffer.synonyms(i).synonym_name = p_synonym
            THEN
                v_object := g_buffer.synonyms(i).object_name;
                EXIT;
            END IF;
        END LOOP; 
        return v_object;
    END;





    --
    FUNCTION get_ddl_create_synonyms
    (
        p_schema t_identifier,
        p_prefix t_prefix DEFAULT null
    ) return t_statement_list IS
        v_schema t_identifier := p_schema;
        v_stmts  t_statement_list := t_statement_list();
    BEGIN
    
        FOR i IN 1 .. g_buffer.synonyms.count
        LOOP
            v_stmts.extend();
            v_stmts(v_stmts.last) := format_ddl_create_synonym(
                p_object         => g_buffer.synonyms(i).object_name,
                p_object_schema  => g_buffer.owner,
                p_synonym        => p_prefix || g_buffer.synonyms(i).synonym_name,
                p_synonym_schema => p_schema
                );
        END LOOP;
    
        return v_stmts;
    END get_ddl_create_synonyms;






    --
    FUNCTION get_ddl_drop_synonyms
    (
        p_schema t_identifier,
        p_prefix t_prefix DEFAULT null
    ) return t_statement_list IS
        v_schema t_identifier := p_schema;
        v_stmts  t_statement_list := t_statement_list();
    BEGIN
    
        FOR i IN 1 .. g_buffer.synonyms.count
        LOOP
            v_stmts.extend();
            v_stmts(v_stmts.last) := format_ddl_drop_synonym(
                p_synonym        => p_prefix || g_buffer.synonyms(i).synonym_name,
                p_synonym_schema => v_schema
            );
        END LOOP;
    
        return v_stmts;
    END get_ddl_drop_synonyms;

    /* 
    * @return the DDL to install this module for user p_user
    */
    FUNCTION get_ddl_install
    (
        p_user   t_identifier DEFAULT user,
        p_prefix t_prefix     DEFAULT null
    )   return   t_statement_list
    IS 
        v_grant_ddl om_helper_pkg.t_statement_list;
        v_syn_ddl   om_helper_pkg.t_statement_list; 
    BEGIN 
        -- load the module definition
        om_module_define();

        -- Genrate the DDL 

        v_grant_ddl := get_ddl_grants(
            p_grantee => p_user
        );
        
        v_syn_ddl := get_ddl_create_synonyms(
            p_schema => p_user, 
            p_prefix => p_prefix
        ); 

        return v_grant_ddl MULTISET UNION DISTINCT v_syn_ddl; 

    END; 






    /* 
    * @return the DDL to uninstall this module from user p_user
    */
    FUNCTION get_ddl_uninstall
    (
        p_user   t_identifier DEFAULT user,
        p_prefix t_prefix     DEFAULT null
    )   return   t_statement_list 
    IS 
        v_grant_ddl om_helper_pkg.t_statement_list;
        v_syn_ddl   om_helper_pkg.t_statement_list; 
    BEGIN 
        -- load the module definition
        om_module_define();

        v_grant_ddl := get_ddl_revokes(
            p_grantee => p_user
        );
        
        v_syn_ddl   := get_ddl_drop_synonyms(
            p_schema => p_user,  
            p_prefix => p_prefix
        ); 

        return v_syn_ddl MULTISET UNION DISTINCT v_grant_ddl; 

    END;  




    -- Executes a statement list
    PROCEDURE exec_ddl
    (
        p_ddl     t_statement_list,
        p_verbose boolean DEFAULT true
    ) IS
        v_ddl t_statement_list := p_ddl;
    BEGIN
        IF v_ddl IS NOT null 
        THEN
            FOR i IN 1 .. v_ddl.count()
            LOOP
                IF p_verbose
                THEN
                    sys.dbms_output.put_line(v_ddl(i));
                END IF;
                
                EXECUTE IMMEDIATE v_ddl(i);
            END LOOP;
        END IF;
    END exec_ddl;






    -- Executed to grants
    PROCEDURE grant_to(p_grantee t_identifier) IS
        v_ddl t_statement_list;
    BEGIN
        v_ddl := get_ddl_grants(p_grantee => p_grantee); 
        exec_ddl(v_ddl);
    END grant_to;





    -- Executes the revokes
    PROCEDURE revoke_from(p_grantee t_identifier) IS
        v_ddl t_statement_list ;
    BEGIN
        v_ddl := get_ddl_revokes(p_grantee => p_grantee); 
        exec_ddl(v_ddl);
    END revoke_from;






    -- Converts a statement list into a String
    FUNCTION dump_ddl(p_ddl t_statement_list) return clob IS
        v_ddl      t_statement_list := p_ddl;
        v_clob     clob;
        c_new_line varchar2(2 CHAR) := chr(13) || chr(10);
    BEGIN
        IF v_ddl IS NOT null
        THEN
            FOR i IN 1 .. v_ddl.count()
            LOOP
                v_clob := v_clob || v_ddl(i) || ';' || c_new_line;
            END LOOP;
        END IF;
        return v_clob;
    END dump_ddl;




    -- Returns the API Object Entry as JSON Object
    FUNCTION get_json_api_entry(p_synonym_entry t_synonym) return json_object_t IS
        v_entry json_object_t := json_object_t();
        v_privs t_privilege_list;
    BEGIN
        v_privs := get_object_privileges(
            p_object => get_object_by_synonym(p_synonym_entry.synonym_name)
        );
        
        v_entry.put('name', p_synonym_entry.synonym_name);

        IF v_privs.count > 1
        THEN
            v_entry.put('privileges',
                        json_array_t(format_privilege_list(p_privileges => v_privs,
                                                           p_json       => true)));
        ELSE
            v_entry.put('privilege',
                        format_privilege_list(p_privileges => v_privs,
                                              p_json       => false));
        END IF;
    
        IF p_synonym_entry.description IS NOT null
        THEN
            v_entry.put('description',
                        p_synonym_entry.description);
        END IF;
        return v_entry;
    END;

    -- Creates a JSON dump of the current buffer value;
    FUNCTION get_json return clob IS
        v_json json_object_t := json_object_t();
    BEGIN
        v_json.put('key' ,g_buffer.key);
        v_json.put('name' ,g_buffer.name);
        v_json.put('version' ,g_buffer.version);
        v_json.put('description' ,g_buffer.description);

        v_json.put('om_version',c_om_version);
    
        DECLARE
            v_api json_array_t := json_array_t();
        BEGIN

            FOR i IN 1 .. g_buffer.synonyms.count
            LOOP
                v_api.append(get_json_api_entry(g_buffer.synonyms(i)));
            END LOOP;

            v_json.put('api' ,v_api);
        END;
    
        return v_json.stringify();
    END get_json;

END om_helper_pkg;
/
