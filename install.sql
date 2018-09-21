-- -------- Setup the database
WHENEVER SQLERROR EXIT SQL.SQLCODE;

-- User to run the tests
CREATE USER test identified by test;
GRANT unlimited tablespace to test;
GRANT create session to test;


-- Owner user for the module
CREATE USER ext_module identified by null;
GRANT unlimited tablespace to ext_module;


-- -- Install module objects

ALTER SESSION SET current_schema = ext_module;

CREATE or REPLACE FUNCTION get_the_answer RETURN varchar2
AS
BEGIN
	return 'Hello world!';
END get_the_answer;
/

start make_module.sql

-- allow user test to use the module
GRANT ext_module_users TO test;

show errors;