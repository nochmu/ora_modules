-- ------------------- Clean the database
WHENEVER SQLERROR CONTINUE none;
drop role ext_module_users;
drop user ext_module cascade;
drop user test cascade;


-- -------- Setup the database
WHENEVER SQLERROR EXIT SQL.SQLCODE;

-- User to run the tests
CREATE USER test identified by test;
GRANT unlimited tablespace to test;
GRANT create session to test;


-- Owner user for the module
CREATE USER ext_module identified by null;
GRANT unlimited tablespace to ext_module;


-- init test user
ALTER SESSION SET current_schema = test;

CREATE OR REPLACE PROCEDURE ignore_return(p_in varchar2)
AS
BEGIN
	null;
END ignore_return;
/

-- -- Install module objects

ALTER SESSION SET current_schema = ext_module;

CREATE or REPLACE FUNCTION get_the_answer RETURN varchar2
AS
BEGIN
	return 'Hello world!';
END get_the_answer;
/



/* Updates the grants to use this module
 *  %param p_user   - grant to this user
 *  %param p_revoke - revoke the grants
*/
CREATE or REPLACE PROCEDURE update_grants(
	p_user   varchar2 default USER,
	p_revoke boolean default false
)
AUTHID definer
AS
	PROCEDURE set_grant(p_obj varchar2, p_priv varchar2)
	IS
		v_sql varchar2(1024);
	BEGIN
		IF(p_revoke)
		THEN
			v_sql := 'REVOKE '||p_priv||' ON '||p_obj||' FROM '||p_user;
		ELSE
			v_sql := 'GRANT  '||p_priv||' ON '||p_obj||' TO '||p_user;
		END IF;

		execute immediate v_sql;
	END;
BEGIN
	set_grant('get_the_answer', 'EXECUTE');
END update_grants;
/



/* Updates the alias synonyms installed in a specific schema.
 *   %param p_schema - into this schema
 *   %param p_prefix - prefix the synonyms
 *   %param p_drop   - drop the synonyms
*/
CREATE or REPLACE PROCEDURE update_synonyms(
	p_schema varchar2,
	p_prefix varchar2,
	p_drop   boolean default false
)
AUTHID current_user
AS
	v_module_schema constant varchar2(30) := $$PLSQL_UNIT_OWNER;

	PROCEDURE set_alias(p_alias varchar2, p_obj varchar2)
	IS
		v_sql                 varchar2(4000);
		v_full_alias constant varchar2(257) := p_schema||'.'||p_prefix||p_alias;
		v_full_obj   constant varchar2(257) := v_module_schema||'.'||p_obj;
	BEGIN
		IF(p_drop)
		THEN
			v_sql := 'DROP SYNONYM '||v_full_alias;
		ELSE
			v_sql := 'CREATE or REPLACE SYNONYM '||v_full_alias||' FOR '|| v_full_obj;
		END IF;

		execute immediate v_sql;
	END;
BEGIN
	set_alias('hello_world', 'get_the_answer');
END update_synonyms;
/




/* Installs the module for a specific user.
   %param p_user - install for this user
   %param p_prefix - Prefix for the synonyms. Using a prefix allows to install multiple versions.
*/
CREATE or REPLACE PROCEDURE install(
    p_user varchar2 default USER,
    p_prefix varchar2 default null
)
AUTHID current_user
AS
BEGIN
	update_grants(p_user => p_user);
	update_synonyms(p_schema=>p_user, p_prefix=>p_prefix);
END install;
/



/* Uninstalls the module for a specific user.
   %param p_user - uninstall for this user
   %param p_prefix - Prefix for the installed synonyms.
*/
CREATE or REPLACE PROCEDURE uninstall(
    p_user varchar2 default USER,
    p_prefix varchar2 default null
)
AUTHID current_user
AS
BEGIN
	update_grants(p_user => p_user, p_revoke=>true);
	update_synonyms(p_schema=>p_user, p_prefix=>p_prefix,  p_drop => true);
END uninstall;
/



-- to use the module
CREATE ROLE ext_module_users;
GRANT execute ON install   TO ext_module_users;
GRANT execute ON uninstall TO ext_module_users;
GRANT create synonym       TO ext_module_users;


-- allow user test to use the module
GRANT ext_module_users TO test;

show errors;