select initiate_id,performing_lab,textual_result_full from ih_dw.results r
join ih_dw.dim_lab_order lo ON lo.requisition_id = r.requisition_id
where r.requisition_id = '5828GC7';

select * from patientmaster
where eid = '8000524445';

select order_test_code,cmt.condition,condition_value,filter from condition_master_test cmt
full outer join condition_filters cf ON cf.condition_filter_pk = cmt.condition_filter_fk
where state_fk IN
(select state_master_pk from state_master
where state_abbreviation = 'PA')

--and cmt.status = 'active'
order by order_test_code;
and order_test_code IN ('332');

select * from condition_filters
where condition IN ('East','South');

select order_number,loinc_code,loinc_name,order_test_code,result_test_code,textual_result_full,units,reference_range,specimen_source from results_sent_log
where last_update_time > sysdate - 1
order by last_update_time desc;

select * from condition_filters;

update condition_master_test
set condition = 'Positive Equivocal Reactive'
,condition_filter_fk = 2
where condition_master_pk = 1787;

select * from condition_filters;

select * from asr_process_run
where order_number = '1626HY8'
and complete = 'N';

update asr_process_run
set complete = 'R'
where order_number = '1626HY8'
and complete = 'N';

select * from results_sent_log
where order_number = '1626HY8';


delete condition_master_test
where condition_master_pk IN (31,1001);

REM INSERTING into CONDITION_MASTER_TEST
SET DEFINE OFF;
Insert into CONDITION_MASTER_TEST (CONDITION_MASTER_PK,STATE_FK,CONDITION_FILTER_FK,ORDER_TEST_CODE,RESULT_TEST_CODE,CONDITION,VALUE_TYPE,CONDITION_VALUE,STATUS,CREATED_DATE,CREATED_BY,LAST_UPDATED_DATE,LAST_UPDATED_BY) 
values ((select max(condition_master_pk) + 1 from condition_master_test),4,4,'311','311R','All','ST',null,'active',to_timestamp('31-OCT-21 11.40.38.747507000 PM','DD-MON-RR HH.MI.SSXFF AM'),'ASR_ADMIN_UPDATE',to_timestamp('31-OCT-21 11.40.38.747507000 PM','DD-MON-RR HH.MI.SSXFF AM'),'ASR_ADMIN_UPDATE');
