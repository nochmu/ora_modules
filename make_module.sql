-- Installs the necessary objects to use the current schema as module.
--
-- Required Privileges:
--     - CREATE PROCEDURE
--     - CREATE ROLE
--     - CREATE SYNONYM WITH ADMIN OPTION
--
-- Usage:
--    @make_module.sql [moduleRole=<current_schema>_users]


-----------------------------------------------------------

-- Arg1: role to use the module | default: null => <current_schema>_users
COLUMN p1 NEW_VALUE 1
SELECT null p1 FROM dual where 1=2;
DEFINE moduleRole = &1 ""


REM PROCEDURE update_grants
CREATE or REPLACE PROCEDURE
/* Updates the grants to use this module
 *  %param p_user   - grant to this user
 *  %param p_revoke - revoke the grants
*/
update_grants
(
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


REM PROCEDURE update_synonyms
CREATE or REPLACE PROCEDURE
/* Updates the alias synonyms installed in a specific schema.
 *   %param p_schema - into this schema
 *   %param p_name   -
 *   %param p_drop   - drop the synonyms
*/
update_synonyms
(
	p_schema varchar2,
	p_prefix varchar2,
	p_drop   boolean default false
)
AUTHID current_user
AS
	v_module_schema constant varchar2(30) := $$PLSQL_UNIT_OWNER;
	v_prefix varchar2(100);

	PROCEDURE set_alias(p_alias varchar2, p_obj varchar2)
	IS
		v_sql        varchar2(4000);
		v_full_alias varchar2(257);
		v_full_obj   varchar2(257);
	BEGIN
		v_prefix := CASE WHEN p_prefix IS null
		                 THEN ''
						 ELSE p_prefix END;

	    v_full_obj   := v_module_schema||'.'||p_obj;
 		v_full_alias := p_schema ||'.'|| v_prefix||p_alias;

		IF p_drop
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



CREATE or REPLACE PROCEDURE
/* Installs the module for a specific user.
   %param p_user - install for this user

*/
install(
    p_user varchar2 default USER,
    p_prefix varchar2 default null
)
AUTHID current_user
AS
BEGIN
	update_grants(p_user => p_user);
	update_synonyms(p_schema=>p_user, p_prefix => p_prefix);
END install;
/




CREATE or REPLACE PROCEDURE
/* Uninstalls the module for a specific user.
   %param p_user - uninstall for this user
   %param p_prefix - Prefix for the installed synonyms.
*/
uninstall(
    p_user varchar2 default USER,
    p_prefix varchar2 default null
)
AUTHID current_user
AS
BEGIN
	update_grants(p_user => p_user, p_revoke=>true);
	update_synonyms(p_schema=>p_user, p_prefix => p_prefix,  p_drop => true);
END uninstall;
/


-- Create Role
DECLARE
	v_role varchar2(128);
	PROCEDURE create_role(p_role varchar2)
	IS
	BEGIN
		execute immediate 'CREATE ROLE '||p_role;
		execute immediate 'GRANT execute ON install TO '||p_role;
		execute immediate 'GRANT execute ON uninstall TO '||p_role;
		execute immediate 'GRANT create synonym TO '||v_role;
	END;
BEGIN
	v_role := nvl('&moduleRole', SYS_CONTEXT('userenv','current_schema')||'_users');
	create_role(v_role);
END;
/