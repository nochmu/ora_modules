-- This script is invoked after validating the input 


DEFINE module_role = &1 

PROMPT ################ Install ORA_MODULES  #########
PROMPT # Module Role:  &module_role                   
PROMPT ###############################################

--  Drop old objects
SET VERIFY ON
SET TERMOUT OFF
WHENEVER SQLERROR CONTINUE;

--  Create objects
--WHENEVER SQLERROR EXIT SQL.SQLCODE;
SET TERMOUT ON


PROMPT
PROMPT Install Objects
PROMPT 
start src/all_ddl.sql

start src/show_errors

PROMPT ROLE &module_role
start src/om_module_role.sql '&module_role' 
