-- Posting results in ASR_PROCESS_RUN
DECLARE v_resulted varchar2(10);
v_complete varchar2(1);
v_covid number := 0;
v_general number := 0;

begin 

for rec IN (select a.order_number,a.order_test_code,a.result_test_code,
      case a.order_test_code
      when '332' then 'S'
      when '331' then 'C'
      else 'R' END complete,
      patient_account_state
      from results_sent_log r
      join asr_process_run a ON a.order_number = r.order_number
      where a.result_test_code = r.result_test_code
      and complete = 'N')
loop

        
  update asr_process_run
  set complete = rec.complete
  where order_number = rec.order_number and order_test_code = rec.order_test_code and result_test_code = rec.result_test_code;
  
  case when rec.complete = 'R' then v_general := v_general + 1 ;
       else v_covid := v_covid + 1; END CASE;
  
  commit;
  
  dbms_output.put_line('Update Complete: ' || rec.order_number || chr(9) || rec.result_test_code || chr(9) || rec.patient_account_state || chr(9) ||
      rec.complete);
      
  


end loop;

dbms_output.put_line('General Lab: ' || v_general || chr(9) || 'Covid: ' || v_covid);

end;