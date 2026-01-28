-- add condition_master

select * from condition_master cm
where state_fk IN
(select state_master_pk from state_master
where state_abbreviation = 'OR')
and rownum < 2
and order_test_code = '301';

select * from state_master
where STATE_ABBREVIATION = 'NC';


Insert into CONDITION_MASTER (CONDITION_MASTER_PK,STATE_FK,CONDITION_FILTER_FK,ORDER_TEST_CODE,RESULT_TEST_CODE,CONDITION,VALUE_TYPE,CONDITION_VALUE,STATUS,CREATED_DATE,CREATED_BY,LAST_UPDATED_DATE,LAST_UPDATED_BY) 
values ((select max(condition_master_pk) + 1 from condition_master),20,2,'336','336','Positive Equivocal Reactive','ST',null,'active',systimestamp,'336',systimestamp,null);

select * from generator
where state_fk = 4;

update generator
set conversion_context = 'CAHL7GeneratorContext'
where generator_pk = 42;

select * from condition_master;
