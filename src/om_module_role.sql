
SET VERIFY off

SET FEEDBACK off

DEFINE role_name = &1 


-- Create Role
DECLARE 
    SUBTYPE t_identifier IS om_helper_pkg.t_identifier; 

    v_role  t_identifier;

    FUNCTION check_role_exists(
            p_role t_identifier
        ) RETURN boolean 
        IS 
            v_role_exists varchar2(1 CHAR);
        BEGIN 
            SELECT CASE WHEN exists (SELECT 1 FROM sys.dba_roles WHERE role = p_role) 
                        THEN 'Y' 
                        ELSE 'N' 
                    END INTO v_role_exists
            FROM   dual;
            return v_role_exists = 'Y'; 
        END;  

    -- Executes a list of DDL statements. 
    PROCEDURE exec_ddl(
            p_stmts   om_helper_pkg.t_statement_list, 
            p_verbose boolean DEFAULT true
        )IS
        BEGIN
            IF p_stmts IS not null 
            THEN 
                FOR i IN 1..p_stmts.count
                LOOP
                    IF p_verbose THEN  
                        sys.dbms_output.put_line(p_stmts(i));  
                    END IF;  
                    execute immediate p_stmts(i);
                END LOOP; 
            END IF; 
        END exec_ddl;

BEGIN
    v_role := '&role_name';

    IF check_role_exists(v_role) THEN  
        dbms_output.put_line('Role exists.');  
    ELSE 
        exec_ddl(om_helper_pkg.get_ddl_create_role(v_role)); 
        dbms_output.put_line('Role created.'); 
    END IF; 

END;
/
