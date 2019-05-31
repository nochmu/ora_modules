CREATE or REPLACE PACKAGE BODY om_module_api 
IS
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

    -- Executes a list of DDL statements. 
    PROCEDURE exec_ddl
        (
            p_stmts   om_helper_pkg.t_statement_list, 
            p_verbose boolean default true
        )
        IS
        BEGIN
            IF p_stmts IS not null 
            THEN 
                FOR i IN 1..p_stmts.count
                LOOP
                    IF p_verbose THEN 
                        sys.dbms_output.put_line(p_stmts(i)); 
                    END IF; 
                    execute immediate p_stmts(i);
                END LOOP; 
            END IF; 
        END exec_ddl;

    -- Calls the procedure OM_MODULE_DEFINE which defines the module.  
    -- Afterwards the module specification can be used via the package OM_HELPER_PKG. 
    PROCEDURE load_config 
        IS 
        BEGIN
             om_module_define();  
        END load_config; 

        -- Does the install process
        PROCEDURE install
        ( 
            p_user   t_identifier DEFAULT user,
            p_prefix t_prefix     DEFAULT null 
        )
        IS 
            v_ddl om_helper_pkg.t_statement_list;  
        BEGIN
            load_config();
            om_helper_pkg.grant_to(p_user); 
            v_ddl := om_helper_pkg.get_ddl_create_synonyms(
                p_schema => p_user, 
                p_prefix => p_prefix
            ); 
            exec_ddl(v_ddl); 
        END install;   

    -- Does the uninstall process
    PROCEDURE uninstall
        ( 
            p_user   t_identifier DEFAULT user,
            p_prefix t_prefix     DEFAULT null 
        )
        IS 
            v_ddl om_helper_pkg.t_statement_list; 
        BEGIN 
            load_config();
            v_ddl := om_helper_pkg.get_ddl_drop_synonyms(
                p_schema => p_user, 
                p_prefix => p_prefix
            ); 
            exec_ddl(v_ddl); 
            om_helper_pkg.revoke_from(p_user); 
        END uninstall; 

    -- 
    FUNCTION get_json RETURN clob
        IS 
        BEGIN 
            return om_helper_pkg.get_json(); 
        END; 

END om_module_api; 
/
