select * from condition_master_test
where state_fk IN
(select state_master_pk from state_master
where state_abbreviation = 'PA')
and order_test_code = '311';


Insert into CONDITION_MASTER_TEST (CONDITION_MASTER_PK,STATE_FK,CONDITION_FILTER_FK,ORDER_TEST_CODE,RESULT_TEST_CODE,CONDITION,VALUE_TYPE,CONDITION_VALUE,STATUS,CREATED_DATE,CREATED_BY,LAST_UPDATED_DATE,LAST_UPDATED_BY) 
values 
((select max(condition_master_pk) + 1 from condition_master_test),66,4,'311','311R','All','ST',null,'active',to_timestamp('31-OCT-21 09.26.18.484616000 PM','DD-MON-RR HH.MI.SSXFF AM'),'ASR_ADMIN_UPDATE',to_timestamp('31-OCT-21 09.26.18.484616000 PM','DD-MON-RR HH.MI.SSXFF AM'),'ASR_ADMIN_UPDATE');

update condition_master_test
set status = 'inactive'
where condition_master_pk = 916;