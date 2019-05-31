PROMPT PACKAGE om_helper_pkg 
start src/ddl/om_helper_pkg.pls
start src/ddl/om_helper_pkg.plb


PROMPT FUNCTION om_module_json
SET TERMOUT off

COLUMN script NEW_VALUE script NOPRINT
SELECT   
  CASE WHEN exists (SELECT 'Y'  FROM sys.all_objects 
                                WHERE object_name = 'OM_MODULE_DEFINE'  
                                  AND owner = sys_context('userenv', 'current_schema'))
       THEN 'src/_skip.sql'
       ELSE 'src/ddl/om_module_define.plsql' 
  END as script 
FROM dual; 

SET TERMOUT on

start &script 


PROMPT PACKAGE om_module_api
start src/ddl/om_module_api.pls
start src/ddl/om_module_api.plb


PROMPT Recompile and show errors
EXEC DBMS_UTILITY.compile_schema(schema => sys_context('userenv', 'current_schema'));
start src/show_errors
