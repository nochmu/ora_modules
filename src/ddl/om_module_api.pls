CREATE or REPLACE PACKAGE om_module_api 
AUTHID current_user
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
 
    -- This package provides procedures to install and manage this module. 
    -- The procedures will be executed with invoker's rights. 
    -- This is necessary to create the depending objects in the invoker's schema. 
    -- %version 0.0.1

    SUBTYPE t_identifier IS varchar2(128 byte); 
    SUBTYPE t_prefix     IS varchar2(8   byte); 

    -- Create the api objects into user's schema .  
    PROCEDURE install(
        p_user   t_identifier DEFAULT user,
        p_prefix t_prefix     DEFAULT null
    ); 

    -- Drop the api objects from user's schema .
    PROCEDURE uninstall(
        p_user   t_identifier DEFAULT user,
        p_prefix t_prefix     DEFAULT null
    ); 

    -- Returns the OM_MODULE.json
    FUNCTION get_json RETURN clob;  
       

END om_module_api; 
/
