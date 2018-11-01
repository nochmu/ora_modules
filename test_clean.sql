
define api_table_name = 'OMM_API_OBJECT_TBL';
define test_module = 'ext_module'; 
define module_role = '&test_module._users'; 

PROMPT ------- Clean the test database
WHENEVER SQLERROR CONTINUE none;
drop role &module_role;
drop user &test_module cascade;
drop user test cascade;
WHENEVER SQLERROR EXIT SQL.SQLCODE;

