--
--select * from report_results
--where not regexp_like(result_test_code,'^(P|111)');
--
--group by result_test_code;
--/
DECLARE v_complete varchar2(1) := 'A';
v_insert_update varchar2(32) := 'ASR_INSERT';
v_covidcnt number := 0;
v_generalcnt number:= 0;
v_errcnt number := 0;
v_totalcnt number := 0;
v_promptcnt number := 0;
v_activitydate varchar2(10);

begin

--PROD
select to_char(sysdate - 1 ,'dd-MON-yy') into v_activitydate from dual;

--v_activitydate := '13-FEB-24';

for rec IN (select order_number,ORDER_TEST_CODE,RESULT_TEST_CODE,PERFORMING_LAB_ID,TEXTUAL_RESULT_FULL,
       PATIENT_LAST_NAME,source,ACTIVITYDATE,'N' complete from report_results rr
       where activitydate = v_activitydate
       )
loop


--dbms_output.put_line(rec.order_number || chr(9) || rec.result_test_code || chr(9) || rec.source || chr(9) || 
--  rec.complete);

-- Get test prompts from extract
BEGIN

  v_insert_update := 'ASR INSERT ';
  v_complete := 'N';
  
  if(regexp_like(rec.result_test_code,'^P')) then
    v_complete := 'A';
    
  end if;
  
  
  v_totalcnt := v_totalcnt + 1;
  
  INSERT INTO ASR_PROCESS_RUN
      (ORDER_NUMBER,ORDER_TEST_CODE,RESULT_TEST_CODE,PERFORMING_LAB_ID,TEXTUAL_RESULT_FULL,PATIENT_LAST_NAME,SOURCE,ACTIVITYDATE,COMPLETE)
      VALUES 
      (rec.ORDER_NUMBER,rec.ORDER_TEST_CODE,rec.RESULT_TEST_CODE,rec.PERFORMING_LAB_ID,rec.TEXTUAL_RESULT_FULL,rec.PATIENT_LAST_NAME,rec.SOURCE,rec.ACTIVITYDATE,v_complete);
  
  COMMIT;
  
  --dbms_output.put_line(rec.order_number || chr(9) || rec.order_test_code || chr(9) || rec.result_test_code || ' ASR_PROCESS_RUN INSERTED');  
  
  if (regexp_like(rec.result_test_code,'^P')) then
  
    --v_promptcnt := v_promptcnt + 1;
  
    v_insert_update := 'PROMPT_TABLE insert ';
    begin
    
    delete prompt_table where order_number = rec.order_number and result_test_code = rec.result_test_code;
    
    INSERT INTO PROMPT_TABLE
      (ORDER_NUMBER,ORDER_TEST_CODE,RESULT_TEST_CODE,PERFORMING_LAB_ID,TEXTUAL_RESULT_FULL,PATIENT_LAST_NAME,SOURCE,ACTIVITYDATE,COMPLETE)
      VALUES 
      (rec.ORDER_NUMBER,rec.ORDER_TEST_CODE,rec.RESULT_TEST_CODE,rec.PERFORMING_LAB_ID,rec.TEXTUAL_RESULT_FULL,rec.PATIENT_LAST_NAME,rec.SOURCE,rec.ACTIVITYDATE,rec.COMPLETE);
                 
        
      dbms_output.put_line(rec.order_number || chr(9) || rec.order_test_code || chr(9) || rec.result_test_code || ' PROMPT_TABLE UPDATED'); 
      
      v_promptcnt := v_promptcnt + 1;
    
    Exception
    When Others Then
      dbms_output.put_line(sqlerrm);
      
      v_errcnt := v_errcnt + 1;
      
    end;    
  end if;
  
  COMMIT;
  
  v_insert_update := null;
  
  EXCEPTION
  WHEN DUP_VAL_ON_INDEX THEN 
    dbms_output.put_line(v_insert_update || rec.order_number || chr(9) || rec.result_test_code || chr(10) || 'DUPLICATE KEY');
    
  v_errcnt := v_errcnt + 1;
  
END;

end loop;

--for loinc IN (select order_number,ORDER_TEST_CODE,RESULT_TEST_CODE,PERFORMING_LAB_ID,TEXTUAL_RESULT_FULL,
--       PATIENT_LAST_NAME,source,ACTIVITYDATE,'N' complete from report_results rr
--       where activitydate = v_activitydate
--       )
--loop
--
--dbms
--end loop;

dbms_output.put_line('Activity Date: ' || v_activitydate || chr(10) || 'Prompt count: ' || v_promptcnt || chr(10) || 
  'Total count: ' || v_totalcnt || chr(10) || 'Error count : ' || v_errcnt ||
  ' ');
  
  insert into asr_load_log (EXTRACTID,LOGGEDAT,ERRORCOUNT,ACTIVITYDATE,PROMPTCOUNT,GENERALCOUNT) 
  values 
  (asr_extract_log_seq.nextval,systimestamp,v_errcnt,v_activitydate,v_promptcnt,v_totalcnt);
  
commit;

end;

/

set serveroutput on;

select * from patientmaster p
,(select lo.INITIATE_ID eid,res.lab_fk from report_results r
,ih_dw.results res
,ih_dw.dim_lab_order lo
where r.order_number = res.requisition_id
and lo.requisition_id = r.order_number
and r.order_test_code = res.order_test_code
and r.result_test_code = res.result_test_code) t1
where p.eid = t1.eid and p.lab_fk = t1.lab_fk;

select * from report_results;

select order_number,ORDER_TEST_CODE,RESULT_TEST_CODE,PERFORMING_LAB_ID,TEXTUAL_RESULT_FULL,
       PATIENT_LAST_NAME,source,ACTIVITYDATE,'N' complete from report_results rr;
       
select * from report_results rr where source = 'AL';

select order_number,ORDER_TEST_CODE,RESULT_TEST_CODE,PERFORMING_LAB_ID,TEXTUAL_RESULT_FULL,
       PATIENT_LAST_NAME,source,ACTIVITYDATE,'N' complete from report_results rr
       where activitydate = '09-JAN-24'
       and regexp;
       
select * from asr_process_run
where source = 'NC'
and activitydate = '29-MAY-24';

