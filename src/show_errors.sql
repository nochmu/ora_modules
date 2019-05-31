
SET SERVEROUTPUT on 
set pagesize  0 embedded off

-- Pretty error report
DECLARE
  v_no_errors boolean := true;
BEGIN
  FOR c IN (
    SELECT 
      CASE sequence WHEN 1 THEN type END type, 
      CASE sequence WHEN 1 THEN name END name, 
      line, position, 
      text, sequence
    FROM (select * from all_errors order by name, type, sequence) 
    WHERE owner = SYS_CONTEXT('userenv', 'current_schema') 
          AND attribute='ERROR'
  )
  LOOP
    v_no_errors := false;       
    
    IF c.type IS NOT null
    THEN
      dbms_output.put_line(rpad('-', 80, '-'));
      dbms_output.put_line(c.type || ': ' || c.name);
      dbms_output.put_line(rpad('-', 80, '-'));
      dbms_output.put_line(lpad(c.line, 4, ' ') ||' '|| lpad(c.position, 4, ' ') || '  ' ||c.text);
    END IF;
  END LOOP;    
  
  IF v_no_errors
  THEN
    dbms_output.put_line('No errors.');
  END IF;
END;
/
