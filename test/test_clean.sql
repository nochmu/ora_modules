 
define test_module = 'ext_module'; 
define module_role = 'om_role_&test_module'; 

PROMPT ------- Clean the test database
WHENEVER SQLERROR CONTINUE none;
drop role &module_role;
drop user &test_module cascade;
drop user test cascade;
WHENEVER SQLERROR EXIT SQL.SQLCODE;

