
ALTER SESSION set current_schema = ext_module;
SET serveroutput on; 

BEGIN
  ora_modules.init; 
  ora_modules.add_grant(p_object=>'GET_THE_ANSWER', p_privileges=>ora_modules.t_privilege_list('EXECUTE'));
  ora_modules.add_synonym(p_object=>'GET_THE_ANSWER', p_synonym=>'HELLO_WORLD'); 
  
  sys.dbms_output.put_line(
    ora_modules.dump_ddl(
      ora_modules.get_ddl_create_role('TEST_ROLE')
    )||
    ora_modules.dump_ddl(
      ora_modules.get_ddl_grants('TEST')
    )||
    ora_modules.dump_ddl(
      ora_modules.get_ddl_create_synonyms('TEST')
    ) 
  ); 
  

END; 
