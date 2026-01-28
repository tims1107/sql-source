select * from condition_master_test
where state_fk IN
(select state_master_pk from state_master
where state_abbreviation = 'IL')
and order_test_code = '303';


update CONDITION_MASTER_TEST 
set condition_filter_fk = 4
    ,condition = 'All'
    ,last_updated_date = systimestamp
where condition_master_pk = 200;

    ,(CONDITION_MASTER_PK,STATE_FK,CONDITION_FILTER_FK,ORDER_TEST_CODE,RESULT_TEST_CODE,CONDITION,VALUE_TYPE,CONDITION_VALUE,STATUS,CREATED_DATE,CREATED_BY,LAST_UPDATED_DATE,LAST_UPDATED_BY) values (194,14,4,'301','301','All','ST',null,'active',to_timestamp('05-APR-18 09.12.31.002427000 AM','DD-MON-RR HH.MI.SSXFF AM'),'staterpt',to_timestamp('05-APR-18 09.12.31.002427000 AM','DD-MON-RR HH.MI.SSXFF AM'),'staterpt');
