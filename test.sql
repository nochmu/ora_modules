WHENEVER SQLERROR EXIT SQL.SQLCODE;

SET SERVEROUTPUT on;
SET ROLE ext_module_users;


PROMPT test: GRANT
exec ext_module.install();
BEGIN
	dbms_output.put_line(ext_module.get_the_answer());
END; 
/
exec ext_module.uninstall();


PROMPT test: SYNONYM
exec ext_module.install();
BEGIN
	dbms_output.put_line(hello_world());
END; 
/
exec ext_module.uninstall();


PROMPT test: with Prefix
exec ext_module.install(p_prefix=>'v2_');
BEGIN
	dbms_output.put_line(v2_hello_world());
END; 
/
exec ext_module.uninstall(p_prefix=>'v2_');

