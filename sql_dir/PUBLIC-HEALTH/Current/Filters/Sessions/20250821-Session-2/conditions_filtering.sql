select cm.*,cf.filter from state_master sm
join condition_master cm ON cm.state_fk = sm.state_master_pk
join condition_filters cf ON cf.condition_filter_pk = cm.condition_filter_fk
where sm.state_abbreviation IN ('TX')
and order_test_code = '310';



Insert into CONDITION_MASTER (CONDITION_MASTER_PK,STATE_FK,CONDITION_FILTER_FK,ORDER_TEST_CODE,RESULT_TEST_CODE,CONDITION,VALUE_TYPE,CONDITION_VALUE,STATUS,CREATED_DATE,CREATED_BY,LAST_UPDATED_DATE,LAST_UPDATED_BY) 
values ((select max(condition_master_pk) + 1 from condition_master),12,6,'310','310A','> 0.00','NM','> 0.00','active',to_timestamp('05-APR-18 09.12.31.002427000 AM','DD-MON-RR HH.MI.SSXFF AM'),'staterpt',to_timestamp('21-JAN-21 10.30.19.000000000 AM','DD-MON-RR HH.MI.SSXFF AM'),'ASR_ADMIN');



select r.requisition_id,r.result_test_code,a.patient_last_name,r.result_test_name,r.textual_result_full from asr_process_run_20250812_bak a
join ih_dw.results r ON r.requisition_id = a.order_number
and r.result_test_code = a.result_test_code
where r.order_test_code = '332'
and activitydate = '12-AUG-25';

select distinct ps.last_name,r.requisition_id,r.result_test_code,r.result_test_name,r.textual_result_full,source_type from ih_dw.results r
join ih_dw.dim_lab_order lo ON lo.requisition_id = r.requisition_id
join VW_RESULTS_PATIENT_STAFF ps ON ps.initiate_id = lo.initiate_id
where r.order_test_code = '332'
and r.requisition_id IN ('63813C8','6403WK8')
order by r.requisition_id, r.result_test_code;