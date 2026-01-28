

select to_timestamp(trunc(sysdate -1),'DD-MON-RR HH.MI.SS.FF AM') from dual;

select order_number from results_sent_log
where regexp_like(result_source,'^IL','i')
and last_update_time > '07-JUN-25 12.34.08.712651000 AM'
order by order_number;

delete results_sent_log
where order_number IN
(select order_number from results_sent_log
where regexp_like(result_source,'^IL','i')
and last_update_time > '07-JUN-25 12.34.08.712651000 AM');

select * from asr_process_run
where activitydate = '07-JUN-25'
and source = 'IL';

update asr_process_run
set complete = 'S'
where complete = 'N'
and result_test_code  in ('332');



/
-- Current reporting
select e.stateabbrev,resulttestcode,performing_lab,batchseq,count(1) from asr_inbound_extract e
join ih_dw.results r ON r.requisition_id = e.ordernumber and r.result_test_code = e.resulttestcode
join ASR_INBOUND_STATUS s ON s.statusid = e.statuscode
--where batchseq = 'LOAD_20250512'
where e.statuscode  IN (2)
--and stateabbrev = 'NC'
group by e.stateabbrev,e.resulttestcode,performing_lab,batchseq
order by e.STATEABBREV;

select * from asr_inbound_extract
where stateabbrev = 'XX'
and batchseq = 'LOAD_20250723';

select * from asr_process_run
where order_number IN ('0604KWS'
,'0605MVS'
,'7292MMW');
/
-- Update script 
declare 
  cntloop number := 7;
  v_activitydate varchar2(9);
  
begin
  
  for i IN 0 .. cntloop - 1  loop
    v_activitydate := trunc(sysdate - (cntloop -1 - i));
    dbms_output.put_line(i || chr(9) || v_activitydate);
  
  
  for rec IN (select * from asr_process_run
    where activitydate = v_activitydate)
  loop
  
    dbms_output.put_line(rec.activitydate || chr(9) || rec.order_number || chr(9) || rec.complete); 
  
    if(rec.complete = 'N') then
      update asr_inbound_extract 
      -- VALIDATED
      set statuscode = 2
      where ordernumber = rec.order_number and resulttestcode = rec.result_test_code;
    end if;
    
    if(rec.complete = 'T') then
      update asr_inbound_extract 
      -- TESTING ASR_INBOUND_STATUS TABLE
      set statuscode = 10
      where ordernumber = rec.order_number and resulttestcode = rec.result_test_code;
    end if;
    
    if(rec.complete = 'D') then
      update asr_inbound_extract 
      -- NY 111
      set statuscode = 3 
      where ordernumber = rec.order_number and resulttestcode = rec.result_test_code;
    end if;
    
    if(rec.complete = 'Q') then
      update asr_inbound_extract 
      -- NY ALT NOT QUALIFIED
      set statuscode = 4 
      where ordernumber = rec.order_number and resulttestcode = rec.result_test_code;
    end if;
    
    if(rec.complete = 'A') then
      update asr_inbound_extract 
      -- COVID PROMPT
      set statuscode = 5 
      where ordernumber = rec.order_number and resulttestcode = rec.result_test_code;
    end if;
    
    if(rec.complete = 'R') then
      update asr_inbound_extract 
      -- POSTED GENERAL
      set statuscode = 6 
      where ordernumber = rec.order_number and resulttestcode = rec.result_test_code;
    end if;
    
    if(rec.complete = 'S') then
      update asr_inbound_extract 
      -- POSTED COVID
      set statuscode = 7 
      where ordernumber = rec.order_number and resulttestcode = rec.result_test_code;
    end if;
    
    if(rec.complete = 'D') then
      update asr_inbound_extract 
      -- POSTED COVID
      set statuscode = 8 
      where ordernumber = rec.order_number and resulttestcode = rec.result_test_code;
    end if;
    commit;
    
    
  end loop;
  
  end loop;
  
end;

/


