SET TERMOUT OFF
SET VERIFY OFF

-- Arg1: role to use the module | default: null => <current_schema>_users
COLUMN p NEW_VALUE 1
SELECT null p FROM dual where 1=2;
DEFINE moduleRoleParam     = &1 ""


-- Arg2: name of the table to store the module api | default: OMM_API_OBJECT_TBL
COLUMN p NEW_VALUE 2 
SELECT null p FROM dual where 1=2;
DEFINE api_table_name = &2 OMM_API_OBJECT_TBL

-- if(moduleRuleParam is null then: <current_schema>_users)
COLUMN x NEW_VALUE v NOPRINT
SELECT upper(DECODE(nvl('&moduleRoleParam', 'null'), 'null', (SYS_CONTEXT('userenv','current_schema')||'_users'),  '&moduleRoleParam' )) x FROM dual; 
DEFINE moduleRole = &v; 

SET TERMOUT ON
SET VERIFY OFF

PROMPT ################ Install ORA_MODULES  #########
PROMPT # Module Role:  &moduleRole                   
PROMPT # Object Table: &api_table_name             
PROMPT ################

--  Drop old objects
SET VERIFY ON
SET TERMOUT OFF
WHENEVER SQLERROR CONTINUE;
DROP TABLE &api_table_name;

--  Create objects
WHENEVER SQLERROR EXIT SQL.SQLCODE;
SET TERMOUT ON

CREATE TABLE &api_table_name.
(
    public_name  varchar2(128), 
    private_name varchar2(128), 
    privileges   varchar2(200), 
    description  varchar2(4000),
   CONSTRAINT &api_table_name._pk PRIMARY KEY(public_name)
);


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

        dbms_output.put_line(v_sql); 
		execute immediate v_sql;
	END;
BEGIN
    FOR c IN (SELECT private_name, privileges FROM &api_table_name. )
    LOOP
	    set_grant(c.private_name, c.privileges);
    END LOOP; 

END update_grants;
/

REM PROCEDURE update_synonyms
create or replace PROCEDURE
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
        dbms_output.put_line(v_sql); 
		execute immediate v_sql;
	END;
BEGIN

    DECLARE
            TYPE rc_type IS ref cursor;
            v_cursor rc_type;
            v_entry  &api_table_name.%ROWTYPE; 
    BEGIN
        OPEN v_cursor for 'SELECT * FROM '||$$PLSQL_UNIT_OWNER||'.&api_table_name.';
        LOOP
            FETCH v_cursor INTO v_entry;
            EXIT WHEN v_cursor%notfound;
            set_alias(v_entry.public_name, v_entry.private_name);
        END LOOP;
        CLOSE v_cursor;
   END;

END update_synonyms;

/



CREATE or REPLACE PROCEDURE
/* Installs the module for a specific user.
   %param p_user - install for this user

*/
install(
    p_user   varchar2 DEFAULT USER,
    p_prefix varchar2 DEFAULT null
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
	update_synonyms(p_schema=>p_user, p_prefix => p_prefix,  p_drop => true);
    update_grants(p_user => p_user, p_revoke=>true);
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
	v_role := '&moduleRole';
	create_role(v_role);
END;
/ 
