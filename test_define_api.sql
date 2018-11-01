
define api_table_name = '&1'

DECLARE
    PROCEDURE define_object(p_name varchar2, p_object varchar2, p_privs varchar2, p_description varchar2)
    AS
    begin
        dbms_output.put_line('ALIAS '||p_name || ' as '||p_object||'('||p_privs||') -- '||p_description); 
        INSERT INTO &api_table_name.(public_name, private_name, privileges, description )
                           VALUES(p_name, p_object, p_privs, p_description); 
    end;
begin
    define_object(
        p_name   => 'API_V', 
        p_object => '&api_table_name.',
        p_privs  => 'SELECT', 
        p_description => 'the API'
    ); 

    define_object(
        p_name   => 'HELLO_WORLD', 
        p_object => 'GET_THE_ANSWER',
        p_privs  => 'EXECUTE', 
        p_description => 'a simple hello world'
    ); 

end;
/
