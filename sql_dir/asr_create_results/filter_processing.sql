declare v_cnt number := 0;

begin



for rec IN (with recs as (select * from asr_process_run
  where complete IN ('N') and activitydate = to_char(sysdate - 1 ,'dd-MON-yy')),
repo as (select f.facility_id,recs.complete,recs.activitydate,recs.order_number,recs.textual_result_full text_result,r.result_test_code,r.order_test_code,lo.initiate_id reid,r.loinc_code,r.lab_fk from recs
join ih_dw.results r ON r.requisition_id = recs.order_number 
join ih_dw.dim_lab_order lo ON lo.requisition_id = r.requisition_id
join IH_DW.DIM_ACCOUNT a ON a.account_pk = lo.account_fk
join IH_DW.DIM_FACILITY f ON f.facility_pk = a.facility_fk
where r.result_test_code = recs.result_test_code),
pat as (select * from patientmaster p)
select distinct r.*,p.eid,p.lname,p.fname,p.state from repo r
left outer join pat p ON p.eid = r.reid 
where r.complete = 'N' order by p.state,r.order_number,r.result_test_code
)
loop
  v_cnt := v_cnt + 1;
  if(rec.loinc_code is null or
    rec.eid is null) then
    dbms_output.put_line(v_cnt || chr(9) || rec.order_number);  
  end if;
  
  dbms_output.put_line(v_cnt || chr(9) || rec.order_number || chr(9) || rec.result_test_code || chr(9) || rec.state || chr(9) || rec.text_result || chr(9) || rec.lname);
  
  if(regexp_like(rec.text_result,'^Non-Reactive','i') and
    regexp_like(rec.result_test_code,'336') and rec.complete = 'N') then
      dbms_output.put_line('Update for 336 Non-reactive' || chr(9) || rec.order_number || chr(9) || rec.text_result);
      update asr_process_run
      set complete = 'Q'
      where order_number = rec.order_number and result_test_code = rec.result_test_code;
    
  end if;
  
  if(regexp_like(rec.text_result,'^Reactive','i') and
    regexp_like(rec.result_test_code,'336') and rec.complete = 'N'
    and rec.state IN ('OK')) then
      dbms_output.put_line('Update for 336 Non-reactive' || chr(9) || rec.order_number || chr(9) || rec.text_result);
      update asr_process_run
      set complete = 'R'
      where order_number = rec.order_number and result_test_code = rec.result_test_code;
    
  end if;
  
  if(regexp_like(rec.state,'PA|OR') and
    regexp_like(rec.result_test_code,'^335|^331') and rec.complete = 'N') then
      dbms_output.put_line('Inactive tests update' || chr(9) || rec.order_number || chr(9) || rec.text_result);
      update asr_process_run
      set complete = 'I'
      where order_number = rec.order_number and result_test_code = rec.result_test_code;
    
  end if;
  
  -- Remove all covid negative results for PA-OR
  if(regexp_like(rec.result_test_code,'^332') and rec.complete = 'N')
      and regexp_like(rec.text_result,'^negative$','i')then
      dbms_output.put_line('Covid negative removed' || chr(9) || rec.order_number || chr(9) || rec.text_result);
      update asr_process_run
      set complete = 'Q'
      where order_number = rec.order_number and result_test_code = rec.result_test_code;
    
  end if;
  
  commit;
end loop;



dbms_output.put_line('Total tests: ' || v_cnt );

Exception
when others then dbms_output.put_line('Error occurred: ' || substr(sqlerrm,1,200));

end;
