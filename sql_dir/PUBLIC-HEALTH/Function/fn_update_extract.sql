create or replace function fn_update_extract(
  input_cursor IN SYS_REFCURSOR
  ) RETURN SYS_REFCURSOR AS 
  v_row GTT_RESULTS_EXTRACT%ROWTYPE;
  output_cursor SYS_REFCURSOR;
  v_loinc_code varchar2(32);
  v_loinc_name varchar2(256);
  v_delete smallint := 0;
  
BEGIN
  LOOP
    FETCH input_cursor INTO v_row;
    EXIT WHEN input_cursor%NOTFOUND;
    
    v_delete := 1;
    
    if(v_row.order_test_code IN ('111','113')) then
      select count(1) into v_delete from gtt_results_extract
      where order_test_code IN ('301','303','308','310','312','311','318')
      and order_number = v_row.order_number;
    end if;
    
    if(v_delete = 0) then
      delete gtt_results_extract
      where result_test_code = v_row.result_test_code
      and order_number = v_row.order_number;
      
      commit;
    end if;
    
    if(v_row.loinc_code is null) then
    
    update gtt_results_extract
    set loinc_code = '43409-2',loinc_name = 'Bacteria identified:Prid:Pt:Isolate:Nom:Culture'
    where order_number = v_row.order_number
    and result_test_code = v_row.result_test_code;
    end if;
    
--    select loinc_code into v_loinc_code from gtt_results_extract
--    where order_number = v_row.order_number and rownum = 2; 
    
  END LOOP;
  
  
  
  DBMS_OUTPUT.PUT_LINE(v_row.order_number || chr(9) || v_loinc_code);
  
  close input_cursor;
  
  OPEN output_cursor for
  select * from gtt_results_extract;
  
  return output_cursor;


END;