set serveroutput on
/
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
select r.*,p.eid,p.lname,p.fname,p.state from repo r
left outer join pat p ON p.eid = r.reid 
where p.lab_fk = r.lab_fk order by p.state,r.order_number,r.result_test_code
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

/

commit;

select source,count(1) from asr_process_run
--where regexp_like(patient_last_name,'\d')
where activitydate = '24-JUL-24'
and source IN ('AL','CA','LA','MD','NJ','NM','OR','TX')
group by source
;

update asr_process_run
set complete = 'T'
where complete = 'N'
and order_number IN ('1480PZ4','14812H4');
)
and ACTIVITYDATE = '30-APR-24'
and complete = 'C';

update asr_process_run
set complete = 'Q'
where order_number IN
(select order_number from asr_process_run
where regexp_like(order_number,'0XJ')
and activitydate = '09-APR-24');

select PERFORMING_LAB_ID from results_sent_log
where LAST_UPDATE_TIME > sysdate - .5
and result_source = 'New York NYHL7GeneratorContext'
and PERFORMING_LAB_ID like 'SH%';

select PERFORMING_LAB,lab_fk,order_test_code,order_test_name,result_test_code,result_test_name,MICRO_ORGANISM_NAME,result_status from ih_dw.results
where requisition_id = '04578S6'
and regexp_like(result_test_name,'^Isolate');

delete asr_process_run
where complete = 'N';

select * from condition_master
where state_fk IN 
(select state_master_pk from state_master
where state_abbreviation = 'NY')
and order_test_code = '308';

update condition_master
set CONDITION_FILTER_FK = 42
where condition_master_pk = 67;

select * from STATERPT_OWNER.CONDITION_FILTERS
where condition_filter_pk = 42;

select * from results_sent_log
where order_number = '0139P14';


Insert into CONDITION_FILTERS (CONDITION_FILTER_PK,CONDITION,FILTER,VALUE_TYPE,STATUS,CREATED_DATE,CREATED_BY,LAST_UPDATED_DATE,LAST_UPDATED_BY) 
values ((select max(condition_filter_pk) + 1 from condition_filters),'Positive Equivocal Reactive','(regexp_like(textual_result_full,''^Positive|^Equivocal|^Reactive'',''i''))','ST','active',systimestamp,'staterpt',systimestamp,'staterpt');

select max(condition_filter_pk) + 1 from condition_filters;

select * '(regexp_like(textual_result_full,''^Positive|^Equivocal|^Reactive'',''i''))','test' from dual;
/

with runs as (select * from asr_process_run
where source = 'NY'),
res as (select * from ih_dw.results)
select activitydate,order_number,runs.order_test_code from runs 
join res ON res.requisition_id = runs.order_number
where regexp_like(res.order_test_code,'^111')
and res.result_test_code = runs.result_test_code
order by res.last_updated_date desc,res.requisition_id;


with act as (select * from ih_dw.dw_ods_activity
where last_updated_date > sysdate - 30),
res as (select r.* from act 
join ih_dw.results r ON r.requisition_id = act.requisition_id)
select * from res where order_test_code = '111';

select * from asr_process_run
where order_number IN ('0139PY4')
and result_test_code = '336'
and regexp_like(textual_result_full,'^Positive|^Equivocal|^Reactive','i');

select * from dual 
where '(upper(textual_result_full) LIKE upper(''Positive%'') 
	or upper(textual_result_full) LIKE upper(''Equivocal%'') or upper(textual_result_full) LIKE upper(''Reactive%''))'