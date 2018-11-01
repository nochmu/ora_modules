-- -------- Setup the database
WHENEVER SQLERROR EXIT SQL.SQLCODE;

define api_table_name = OMM_API_OBJECT_TBL;
define test_module = 'ext_module'; 
define moduleRole = '&test_module._users'; 


PROMPT ----- Create Database User: TEST
-- User to run the tests
CREATE USER test identified by test;
GRANT unlimited tablespace to test;
GRANT create session to test;

PROMPT ----- Create Database User: &test_module
-- Owner user for the module
CREATE USER &test_module identified by null;
GRANT unlimited tablespace to &test_module;
/

-- -- Install module objects

ALTER SESSION SET current_schema = &test_module;

CREATE or REPLACE FUNCTION get_the_answer RETURN varchar2
AS
BEGIN
	return 'Hello world!';
END get_the_answer;
/

start make_module.sql null  &api_table_name

-- allow user test to use the module
GRANT &moduleRole TO test;

show errors;

SET SERVEROUTPUT on;
start test_define_api.sql &api_table_name
