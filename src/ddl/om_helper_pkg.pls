CREATE OR REPLACE PACKAGE om_helper_pkg AUTHID DEFINER IS
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

    /* Helper Package for ora_modules.
    * This package is intended to define the module definition via PL/SQL. 
    * See the procedure <code>OM_MODULE_DEFINE</code> for an example to use this package.  
    * @version 0.0.1
    * @see om_module_define
    */

    -- Data types
    SUBTYPE t_key     IS varchar2(64 BYTE);
    SUBTYPE t_name    IS varchar2(64 CHAR);
    SUBTYPE t_version IS varchar2(32 CHAR);
    SUBTYPE t_text    IS varchar2(4000 BYTE);

    SUBTYPE t_prefix      IS varchar2(8 BYTE);
    SUBTYPE t_identifier  IS varchar2(128 BYTE);
    TYPE t_privilege_list IS TABLE OF varchar2(40 BYTE);

    SUBTYPE t_statement   IS varchar2(4000 BYTE);
    TYPE t_statement_list IS TABLE OF t_statement;

    /* Begins the module definition. 
    * This procedure should be called at the beginning.
    */
    PROCEDURE define_module
    (
        p_key         t_key,
        p_name        t_name,
        p_version     t_version,
        p_description t_text
    );

    -- Set  meta data
    PROCEDURE set_metadata
    (
        p_key   t_key,
        p_value t_text
    );

    /* Add the given object as API Object. 
    * @param p_name       The public name of the API Object. 
    * @param p_object     The internal object name.   
    * @param p_privileges Grant these privileges to use the API. 
    * @param p_description A short description for your API Documentation. 
    */
    PROCEDURE add_api_object
    (
        p_name        t_identifier,
        p_object      t_identifier,
        p_privileges  t_privilege_list,
        p_description t_text DEFAULT null
    );

    /* Allow to access the given object. 
    * @param p_object      Name of the object.
    * @param p_privileges  Grant this privileges during install. 
    * @param p_owner       Owner of the object.
    */
    PROCEDURE add_grant
    (
        p_object     t_identifier,
        p_privileges t_privilege_list
    );

    /* Create a synonym. 
    * @param p_object  The name of the object
    * @param p_synonym The alias name for the object
    * @param p_description A short description for your API Documentation. 
    */
    PROCEDURE add_synonym
    (
        p_object      t_identifier,
        p_synonym     t_identifier,
        p_description t_text DEFAULT null
    );

    /* 
     * @return the DDL statements to create the role
    */
    FUNCTION get_ddl_create_role(p_role t_identifier) return t_statement_list;

    /* 
    * @return the DDL statements to create the role
    */
    FUNCTION get_ddl_drop_role(p_role t_identifier) return t_statement_list;

    /* 
    * @return the DDL to grant
    */
    FUNCTION get_ddl_grants(p_grantee t_identifier) return t_statement_list;

    /* 
    * @return the DDL to revoke
    */
    FUNCTION get_ddl_revokes(p_grantee t_identifier) return t_statement_list;

    /* 
    * @return the DDL to create the synonyms
    */
    FUNCTION get_ddl_create_synonyms
    (
        p_schema t_identifier,
        p_prefix t_prefix DEFAULT null
    ) return t_statement_list;

    /* 
    * @return the DDL to drop the synonyms
    */
    FUNCTION get_ddl_drop_synonyms
    (
        p_schema t_identifier,
        p_prefix t_prefix DEFAULT null
    ) return t_statement_list;

    /* 
    * @return the DDL to install this module for user p_user
    */
    FUNCTION get_ddl_install
    (
        p_user   t_identifier DEFAULT user,
        p_prefix t_prefix     DEFAULT null
    ) return t_statement_list; 

    /* 
    * @return the DDL to uninstall this module from user p_user
    */
    FUNCTION get_ddl_uninstall
    (
        p_user   t_identifier DEFAULT user,
        p_prefix t_prefix     DEFAULT null
    ) return t_statement_list; 



    /* Executes the grant list
    */
    PROCEDURE grant_to(p_grantee t_identifier);


    /* Execute the revoke list
    */
    PROCEDURE revoke_from(p_grantee t_identifier);


    /* Converts the given statement_list into a clob
    */
    FUNCTION dump_ddl(p_ddl t_statement_list) return clob;


    /* Creates a JSON dump of the current buffer state
    */
    FUNCTION get_json return clob;

END om_helper_pkg;
/
