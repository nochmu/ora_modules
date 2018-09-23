-- ------------------- Clean the database
WHENEVER SQLERROR CONTINUE none;
drop role ext_module_users;
drop user ext_module cascade;
drop user test cascade;

