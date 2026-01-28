select * from asr_process_run
where order_number IN
(select order_number from asr_process_run
where source = 'TX'
and activitydate = '28-MAY-25')
and order_number = '3069VY8';

update asr_process_run
set complete = 'Q'
where order_number = '25176C4'
and result_test_code IN ('315','317L','322');


select * from condition_master
where state_fk IN
(select state_master_pk from state_master
where state_abbreviation = 'TX')
and order_test_code = '318';

select * from patientmaster
where eid IN
(select initiate_id from ih_dw.dim_lab_order
where requisition_id = '39596V8');

select p.* from daily_results r
join pat_results p ON p.requisition_id = r.order_number
where requisition_id = '39596V8';

update asr_process_run
set complete = 'T'
where order_number IN
(select order_number from asr_process_run
where regexp_like(patient_last_name,'\d|Test','i')
and activitydate = '27-JUL-24');

select * from asr_process_run
where order_number = '2525YF8';

commit;

/
declare v_activitydate varchar2(10) := to_char(sysdate -1,'dd-MON-yy');
v_removecnt number := 0;

begin

for rec IN (select * from asr_process_run where ACTIVITYDATE = v_activitydate 
  and complete = 'N' order by source)
  loop
  -- remove all covid negative results - set complete flag = 'Q'
    if (rec.result_test_code = '332' 
        and regexp_like(rec.textual_result_full,'Negative','i')) then
      begin
  
        v_removecnt := v_removecnt + 1;
    
        dbms_output.put_line('Set ' || rec.order_number || chr(9) || 'Covid:332');
        dbms_output.put_line(rec.source || chr(9) || rec.order_number || chr(9) || rec.result_test_code || chr(9) || v_activitydate);
      
        update asr_process_run
        set complete = 'Q'
        where order_number = rec.order_number
        and result_test_code = '332'
        and complete = 'N';
  
    end;
  end if;
  
  -- MD DOH 310A Remove
  if (rec.result_test_code = '310A' 
        and regexp_like(rec.source, 'MD')
        and rec.complete = 'N') then
      begin
  
        v_removecnt := v_removecnt + 1;
    
        dbms_output.put_line('Set ' || rec.order_number || chr(9) || 'MD DOH 310A');
        dbms_output.put_line(rec.source || chr(9) || rec.order_number || chr(9) || rec.result_test_code || chr(9) || v_activitydate);
      
        update asr_process_run
        set complete = 'Q'
        where order_number = rec.order_number
        and result_test_code = rec.result_test_code
        and complete = 'N'
        ;
  
    end;
  end if;
  
  -- Test results
  if (regexp_like(rec.patient_last_name,'[0-9]') 
        and regexp_like(rec.source, 'NJ|CA')
        and rec.complete = 'N') then
      begin
  
        v_removecnt := v_removecnt + 1;
    
        dbms_output.put_line('Set ' || rec.order_number || chr(9) || rec.patient_last_name);
        dbms_output.put_line(rec.source || chr(9) || rec.order_number || chr(9) || rec.result_test_code || chr(9) || v_activitydate);
      
        update asr_process_run
        set complete = 'T'
        where order_number = rec.order_number
        and result_test_code = rec.result_test_code
        and complete = 'N'
        ;
  
    end;
  end if;
  
  -- >25 
  if (rec.result_test_code = '317L' 
      and to_number(regexp_replace(rec.TEXTUAL_RESULT_FULL,'<|<=|>|>=','')) < 25
      ) then
    begin
  
      v_removecnt := v_removecnt + 1;
    
      dbms_output.put_line('317L <25.0 IV -> ' || rec.order_number);
      dbms_output.put_line(rec.source || chr(9) || rec.order_number || chr(9) || rec.result_test_code || chr(9) || v_activitydate || chr(9) || 'Q');
    
      update asr_process_run
      set complete = 'Q'
      where order_number = rec.order_number
      and result_test_code = '317L'
      and complete = 'N';
      
    
  
    end;
  elsif (rec.result_test_code = '317L' 
      and to_number(regexp_replace(rec.TEXTUAL_RESULT_FULL,'<|<=|>|>=','')) >= 5
      ) then
    begin
  
      v_removecnt := v_removecnt + 1;
    
      dbms_output.put_line('Set 317L  >= 25.0  -> ' || rec.order_number);
      dbms_output.put_line(rec.source || chr(9) || rec.order_number || chr(9) || rec.result_test_code || chr(9) || v_activitydate || chr(9) || 'R');
    
      update asr_process_run
      set complete = 'R'
      where order_number = rec.order_number
      and result_test_code = '317L'
      and complete = 'N';
      end;
  end if;
  
  -- Variella >=135.0 IV

  if (rec.result_test_code = '323' 
      and to_number(regexp_replace(rec.TEXTUAL_RESULT_FULL,'<|<=|>|>=','')) < 135
      and regexp_like(rec.source,'PR|IL')) then
    begin
  
      v_removecnt := v_removecnt + 1;
    
      dbms_output.put_line('Set Variella <135.0 IV -> ' || rec.order_number);
      dbms_output.put_line(rec.source || chr(9) || rec.order_number || chr(9) || rec.result_test_code || chr(9) || v_activitydate);
    
      update asr_process_run
      set complete = 'Q'
      where order_number = rec.order_number
      and result_test_code = '323'
      and complete = 'N';
  
    end;
  end if;
  
  -- >5.0 
  if (rec.result_test_code = '315' 
      and to_number(regexp_replace(rec.TEXTUAL_RESULT_FULL,'<|<=|>|>=','')) < 5
      ) then
    begin
  
      v_removecnt := v_removecnt + 1;
    
      dbms_output.put_line('Set Variella <5.0 IV -> ' || rec.order_number);
      dbms_output.put_line(rec.source || chr(9) || rec.order_number || chr(9) || rec.result_test_code || chr(9) || v_activitydate || chr(9) || 'Q');
    
      update asr_process_run
      set complete = 'Q'
      where order_number = rec.order_number
      and result_test_code = '315'
      and complete = 'N';
      
    
  
    end;
  elsif (rec.result_test_code = '315' 
      and to_number(regexp_replace(rec.TEXTUAL_RESULT_FULL,'<|<=|>|>=','')) >= 5
      and regexp_like(rec.source,'PR|IL|OH|NC|ME')) then
    begin
  
      v_removecnt := v_removecnt + 1;
    
      dbms_output.put_line('Set 315  >= 5.0  -> ' || rec.order_number);
      dbms_output.put_line(rec.source || chr(9) || rec.order_number || chr(9) || rec.result_test_code || chr(9) || v_activitydate || chr(9) || 'R');
    
      update asr_process_run
      set complete = 'R'
      where order_number = rec.order_number
      and result_test_code = '315'
      and complete = 'N';
      end;
  end if;
  
  -- >322
  if (rec.result_test_code = '322' 
      and to_number(regexp_replace(rec.TEXTUAL_RESULT_FULL,'<|<=|>|>=','')) < 9
      ) then
    begin
  
      v_removecnt := v_removecnt + 1;
    
      dbms_output.put_line('322 ' || rec.order_number);
      dbms_output.put_line(rec.source || chr(9) || rec.order_number || chr(9) || rec.result_test_code || chr(9) || v_activitydate || chr(9) || 'Q');
    
      update asr_process_run
      set complete = 'Q'
      where order_number = rec.order_number
      and result_test_code = '322'
      and complete = 'N';
      
    
  
    end;
  elsif (rec.result_test_code = '322' 
      and to_number(regexp_replace(rec.TEXTUAL_RESULT_FULL,'<|<=|>|>=','')) >= 9
      ) then
    begin
  
      v_removecnt := v_removecnt + 1;
    
      dbms_output.put_line('322 ' || rec.order_number);
      dbms_output.put_line(rec.source || chr(9) || rec.order_number || chr(9) || rec.result_test_code || chr(9) || v_activitydate || chr(9) || 'R');
    
      update asr_process_run
      set complete = 'R'
      where order_number = rec.order_number
      and result_test_code = '322'
      and complete = 'N';
      end;
  end if;
  
end loop;

dbms_output.put_line('Remove count: ' || v_removecnt);
 

end;

/

commit;

update asr_process_run
set complete = 'Q'
where order_number = '14482W4'
and result_test_code = '111';

-- Get ELR Data

select source,complete,count(1) from asr_process_run
where regexp_like(source,'AL|CA|LA|MD|NJ|NM|NY|OR|TX|NC')
and activitydate = to_char(sysdate -1,'dd-MON-yy')
and complete IN ('R','S','N','Q','T')
group by source,complete
order by source;

select * from asr_process_run
--where activitydate = '09-APR-25'
where order_number = '08359M8';
and complete = 'N';

update asr_process_run
set complete = 'R'
where order_number = '08359M8';


select * from results_sent_log
where order_number in ('1483F47');

select result_comment from ih_dw.results
where requisition_id IN ('13180A4','SW91102');

select * from asr_process_run
where order_number = '13919N4';


update asr_process_run
set complete = 'R'
--select * from asr_process_run
where complete = 'N'
and activitydate = to_char(sysdate -1,'dd-MON-yy')
and source = 'NY';


select * from results_sent_log
where order_number IN ('2109VZ7','2517CY7');




select * from asr_process_tracking
where regexp_like(process_name,'(ASR_PROCESS_$)')
order by last_updated desc;

delete asr_process_tracking
where regexp_like(process_name,'(ASR_PROCESS_$)');

select complete,source,order_test_code,count(1) from asr_process_run
where regexp_like(source,'NY')
and activitydate = to_char(sysdate -1,'dd-MON-yy')
--and complete IN ('N')
group by complete,source,ORDER_TEST_CODE
order by source;


select * from results_sent_log
where order_number = '1386GB7';

select * from condition_master
where state_fk IN
(select state_master_pk from state_master
where state_abbreviation = 'NC')
and status = 'active';
and condition_master_pk = 1877;

update condition_master
set status = 'inactive',value_type = 'NM',condition = '>=',result_test_code = null
where condition_master_pk = 1877;

select patient_home_phone from results_sent_log
where LAST_UPDATE_TIME > sysdate -1
and length(patient_home_phone) = 10;

update condition_master
set status = 'inactive'
where condition_master_pk = 1009;

select * from asr_process_run
where complete = 'N'
and regexp_like(PATIENT_LAST_NAME,'-')
and source = 'NJ';

update asr_process_run
set complete = 'T'
where complete = 'N'
and regexp_like(PATIENT_LAST_NAME,'-');
and source = 'NC' 
and result_test_code = '323';

-- remaining
select * from asr_process_run
where activitydate = to_char(sysdate -1,'dd-MON-yy')
and complete ='N'
order by source;

select * from asr_process_run
where result_test_code = '323'
and to_number(regexp_replace(TEXTUAL_RESULT_FULL,'<|<=|>|>=','')) < 125
and complete = 'R';


/
 -- add condition
 select * from condition_master
 where state_fk IN
 (select state_master_pk from state_master
 where state_abbreviation = 'TX')
 and result_test_code = '336';
 
 select * from condition_master
 where state_fk IN
 (select state_master_pk from state_master
 where state_abbreviation = 'TX');
 
 
Insert into CONDITION_MASTER (CONDITION_MASTER_PK,STATE_FK,CONDITION_FILTER_FK,ORDER_TEST_CODE,RESULT_TEST_CODE,CONDITION,VALUE_TYPE,CONDITION_VALUE,STATUS,CREATED_DATE,CREATED_BY,LAST_UPDATED_DATE,LAST_UPDATED_BY) 
values ((select max(condition_master_pk) + 1 from condition_master),12,2,'336','336','Positive Equivocal Reactive','ST',null,'active',systimestamp,'ADMIN',systimestamp,'ADMIN');


/