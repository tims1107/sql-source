select cm.*,cf.filter from condition_master cm
join condition_filters cf ON cf.condition_filter_pk = cm.condition_filter_fk
where state_fk = 62
and regexp_like(order_test_code,'^(322)');


Insert into CONDITION_MASTER (CONDITION_MASTER_PK,STATE_FK,CONDITION_FILTER_FK,ORDER_TEST_CODE,RESULT_TEST_CODE,CONDITION,VALUE_TYPE,CONDITION_VALUE,STATUS,CREATED_DATE,CREATED_BY,LAST_UPDATED_DATE,LAST_UPDATED_BY) 
values 
((select max(condition_master_pk) + 1 from condition_master),62,39,'322',322,'ST or NM','NM','9','active',systimestamp,'ASR_ADMIN_UPDATE',NULL,NULL);


delete condition_master
where condition_master_pk = 1688;