-- make_modules 
-- 
-- Usage: 
--        @make_module [<api_role>] 
--        api_role: 
--            To use the module, the <api_role> must be granted. 
--            The role must not yet exist.
--            default value: om_role_<module_schema>
--
-- Version 0.0.4 
--

SET TERMOUT OFF
SET VERIFY OFF

-- Arg1: role to use the module | default: null => om_role_<current_schema>
COLUMN p NEW_VALUE 1
SELECT null p FROM dual where 1=2;
DEFINE moduleRoleParam     = &1 ""


-- if(moduleRuleParam is null then: om_role_<current_schema>)
COLUMN x NEW_VALUE v NOPRINT
SELECT upper(DECODE(nvl('&moduleRoleParam', 'null'), 'null', ('om_role_'||SYS_CONTEXT('userenv','current_schema')),  '&moduleRoleParam' )) x FROM dual; 
DEFINE module_role = &v


-- check input
SET FEEDBACK OFF
SET TERMOUT ON
SET SERVEROUTPUT on 
VAR next_script VARCHAR2(200 char);
DECLARE
    v_error boolean := false; 
BEGIN
    dbms_output.enable();  

    IF sys_context('userenv','current_schema') = 'SYS' THEN 
        dbms_output.put_line('ERROR: current_schema=SYS'); 
        dbms_output.put_line('       You should run "ALTER SESSION SET current_schema=<module-schema>"'); 
        v_error := true;
    END IF; 

    IF v_error 
    THEN :next_script := 'make_module_err.sql'; 
    ELSE :next_script := 'make_module_run.sql'; 
    END IF; 
END;
/
-- store value of :next_script into &next_script
SET TERMOUT OFF
COLUMN next_script NEW_VAL next_script NOPRINT 
SELECT :next_script next_script FROM dual; 
SET TERMOUT ON

SET FEEDBACK ON

start &next_script &module_role
 
undefine module_role
undefine next_script 


-- Finish
PROMPT
PROMPT ===========================
PROMPT 
PROMPT Module created.  
PROMPT 
SET TERMOUT ON
SET pagesize 100 long 10000
EXEC om_module_define(); 
SELECT  json_query(om_helper_pkg.get_json(), '$' pretty) as OM_MODULE_JSON FROM  dual;

