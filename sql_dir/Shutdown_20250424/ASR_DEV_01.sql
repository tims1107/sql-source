select r.requisition_id,order_test_code,textual_result_full,r.last_updated_date,r.lab_fk,performing_lab,result_status,lo.ordering_physician_npi from ih_dw.results r
join ih_dw.dim_lab_order lo ON lo.requisition_id = r.requisition_id
where r.requisition_id IN ('96686EK','96686TK','96686DK','96686BK','96680FK')
and regexp_like(order_test_code, '^(111|110|113|310|312|301|303|304|308|311|318)$')
and (((r.lab_fk = 5) and (r.performing_lab like 'SH%' or r.performing_lab like 'HE%')) or ((r.lab_fk = 5) and (r.performing_lab like 'SE%' or r.performing_lab like 'HE%')) or ((r.lab_fk = 5) and (r.performing_lab = 'OUTSEND')))
and textual_result like '%' 
order by r.requisition_id,order_test_code desc;

select last_updated_date,result_test_code,micro_organism_name,result_test_name from ih_dw.results
where requisition_id = '96680FK';

select '(((r.lab_fk = 5) and (r.performing_lab like ' || '''SH%''' || ' or r.performing_lab like ' || '''HE%''' || ')) or ((r.lab_fk = 5) and (r.performing_lab like ' || '''SE%''' || 
' or r.performing_lab like ' || '''HE%''' || ')) or ((r.lab_fk = 5) and (r.performing_lab = ' || '''OUTSEND''' || ')))' from dual;

update condition_filters
set filter = '(((rs.lab_fk = 5) and (rs.performing_lab_id like ' || '''SH%''' || ' or rs.performing_lab_id like ' || '''HE%''' || ')) or ((rs.lab_fk = 5) and (rs.performing_lab_id like ' || '''SE%''' || 
' or rs.performing_lab_id like ' || '''HE%''' || ')) or ((rs.lab_fk = 5) and (rs.performing_lab_id = ' || '''OUTSEND''' || ')))'
where condition_filter_pk = 29;

select * from condition_master_test
where state_fk IN
(select state_master_pk from state_master
where state_abbreviation = 'PA')
and order_test_code IN ('332');

select * FROM   
			STATERPT_OWNER.ASR_PROCESS_TRACKING
		WHERE  
			ASR_PROCESS_TRACKING.process_name = 'ASR_PROCESS_PA'
			and ASR_PROCESS_TRACKING.status = '0'
            order by start_time desc;
            
select * from condition_filters;

select state_fk,condition_filter_fk,order_test_code from condition_master_test
where order_test_code = '332'
and state_fk = 14;

select * from results_sent_log
where results_sent_log.patient_account_state = 'NC';

select * from condition_filters
where condition_filter_pk = 50;

update condition_master_test
set condition = 'All 318 NM',value_type = 'ST'
where condition_master_pk = 1918;


Insert into CONDITION_FILTERS (CONDITION_FILTER_PK,CONDITION,FILTER,VALUE_TYPE,STATUS,CREATED_DATE,CREATED_BY,LAST_UPDATED_DATE,LAST_UPDATED_BY) 
values ((select max(condition_filter_pk) + 1 from condition_filters),'All','(upper(textual_result_full) LIKE upper(''%''))','NM','active',to_timestamp('05-APR-25 09.09.49.284184000 AM','DD-MON-RR HH.MI.SSXFF AM'),'staterpt',to_timestamp('05-APR-25 09.09.49.284184000 AM','DD-MON-RR HH.MI.SSXFF AM'),'staterpt');

update condition_filters
set condition = 'All 318 NM',filter = 'regexp_like(order_test_code,''^(318|311)$'')'
,value_type = 'ST'
where condition_filter_pk = 50;

select * from generator
where state_fk IN
(select state_master_pk from state_master
where state_abbreviation = 'NC');

update generator
set conversion_context = 'NCHL7GeneratorContext'
where generator_pk = 42;

Insert into CONDITION_MASTER_TEST (CONDITION_MASTER_PK,STATE_FK,CONDITION_FILTER_FK,ORDER_TEST_CODE,RESULT_TEST_CODE,CONDITION,VALUE_TYPE,CONDITION_VALUE,STATUS,CREATED_DATE,CREATED_BY,LAST_UPDATED_DATE,LAST_UPDATED_BY) 
values ((select max(condition_master_pk) + 1 from condition_master_test),14,50,'318',null,'All','NM',null,'active',to_timestamp('29-JAN-25 03.27.57.491882000 PM','DD-MON-RR HH.MI.SSXFF AM'),'ADMIN',to_timestamp('29-JAN-25 03.27.57.491882000 PM','DD-MON-RR HH.MI.SSXFF AM'),'ADD COND');

 
/
declare p_out number;

begin

 SP_ASR_PROC_TRACK_RESULTS_G('IL',p_out);
end;

/

select * from gtt_results_extract rs
where (((rs.lab_fk = 5) and (rs.performing_lab_id like 'SH%' or rs.performing_lab_id like 'HE%')) or ((rs.lab_fk = 5) and (rs.performing_lab_id like'SE%'
 or rs.performing_lab_id like 'HE%' )) or ((rs.lab_fk = 5) and (rs.performing_lab_id ='OUTSEND')))
 and order_number = '96686DK';

select order_number,patient_account_state,order_test_code,result_test_code,textual_result_full from gtt_results_extract
where regexp_like(order_test_code,'^(301|303|304|308|310|311|312|318|319N|319C|332|336)$')
and not regexp_like(result_test_code,'^P')
order by order_number,order_test_code;
where order_number = '96686DK';