
/-- -------- Setup the database
WHENEVER SQLERROR EXIT SQL.SQLCODE;

define test_module = 'ext_module'; 
define moduleRole = 'om_role_&test_module.'; 

define test_user = 'test'; 

PROMPT ----- Create Database User: TEST
-- User to run the tests
CREATE USER &test_user identified by test;
GRANT unlimited tablespace to &test_user;
GRANT create session to &test_user;

PROMPT ----- Create Database User: &test_module
-- Owner user for the module
CREATE USER &test_module identified by null;
GRANT unlimited tablespace TO &test_module;
GRANT connect              TO &test_module; 
GRANT create procedure     TO &test_module; 

-- -- Install module objects

ALTER SESSION SET current_schema = &test_module;

CREATE or REPLACE FUNCTION hello_world RETURN varchar2
AS
BEGIN
	return 'Hello world!';
END hello_world;
/

start make_module.sql null

-- allow user test to use the module
GRANT &moduleRole TO &test_user;

show errors;

SET SERVEROUTPUT on;
start test/test_define_api.sql
