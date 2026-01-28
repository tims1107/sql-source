select cm.*,cf.filter from condition_master cm
join condition_filters cf ON cf.condition_filter_pk = cm.condition_filter_fk
where state_fk = 14
and regexp_like(order_test_code,'^(315|327)');



select max(condition_filter_pk) from condition_filters
where condition_filter_pk = 51;

update condition_master
set condition_value = 1,value_type = 'NM'
where condition_master_pk = 1922;

SELECT 'TO_NUMBER(REGEXP_SUBSTR(gtt.textual_result_full, ''[0-9]+(\.[0-9]+)?'')) >= {0}' FROM dual;

Insert into CONDITION_FILTERS (CONDITION_FILTER_PK,CONDITION,FILTER,VALUE_TYPE,STATUS,CREATED_DATE,CREATED_BY,LAST_UPDATED_DATE,LAST_UPDATED_BY) 
values ((select max(condition_filter_pk) + 1 from condition_filters),'ST or NM','TO_NUMBER(REGEXP_SUBSTR(gtt.textual_result_full, ''[0-9]+(\.[0-9]+)?'')) >= {0}','ST','active',systimestamp,'ASR_ADMIN_UPDATE',systimestamp,'ASR_ADMIN_UPDATE');


select * from results_sent_log
where order_number IN
(select * from asr_process_run
where source = 'IL'
and activitydate = '22-AUG-25');


Insert into CONDITION_MASTER (CONDITION_MASTER_PK,STATE_FK,CONDITION_FILTER_FK,ORDER_TEST_CODE,RESULT_TEST_CODE,CONDITION,VALUE_TYPE,CONDITION_VALUE,STATUS,CREATED_DATE,CREATED_BY,LAST_UPDATED_DATE,LAST_UPDATED_BY) 
values ((select max(condition_master_pk) + 1 from condition_master),76,2,'336','336','Positive Equivocal Reactive','ST',null,'active',systimestamp,'ASR_ADMIN_UPDATE',NULL,NULL);


Insert into CONDITION_MASTER (CONDITION_MASTER_PK,STATE_FK,CONDITION_FILTER_FK,ORDER_TEST_CODE,RESULT_TEST_CODE,CONDITION,VALUE_TYPE,CONDITION_VALUE,STATUS,CREATED_DATE,CREATED_BY,LAST_UPDATED_DATE,LAST_UPDATED_BY) 
values 
((select max(condition_master_pk) + 1 from condition_master),14,51,'317L','317L','ST or NM','ST',1,'active',systimestamp,'ASR_ADMIN_UPDATE',NULL,NULL);


delete condition_master
where condition_master_pk = 1688;