
WHENEVER SQLERROR EXIT SQL.SQLCODE;

SET SERVEROUTPUT on;
SET ROLE om_role_ext_module;


PROMPT test: GRANT
exec ext_module.om_module_api.install();
BEGIN
	dbms_output.put_line(ext_module.hello_world());
END; 
/
exec ext_module.om_module_api.uninstall();


PROMPT test: SYNONYM
exec ext_module.om_module_api.install();
BEGIN
	dbms_output.put_line(ext_get_the_answer());
END; 
/
exec ext_module.om_module_api.uninstall();


PROMPT test: with Prefix
exec ext_module.om_module_api.install(p_prefix=>'v2_');
BEGIN
	dbms_output.put_line(v2_ext_get_the_answer());
END; 
/
exec ext_module.om_module_api.uninstall(p_prefix=>'v2_');

