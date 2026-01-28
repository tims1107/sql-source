select * from asr_process_run
where activitydate = trunc(sysdate -1)
and order_test_code = '311'
and not regexp_like (source,'^(AL|CA|IL|LA|MD|NC|NJ|NM|NY|OR|PA|TX)$')
and regexp_like(textual_result_full,'^(Not Detected)$')
order by source,order_number;

select * from asr_process_run
where activitydate = trunc(sysdate - 1)
order by source,order_number;

select * from condition_master cm
where state_fk IN
(select state_master_pk from state_master
where not regexp_like (state_abbreviation,'^(AL|CA|IL|LA|MD|NC|NJ|NM|NY|OR|PA|TX)$'))
and order_test_code = '311'
and status = 'active'
--and condition_filter_fk = 4
order by state_fk;

-- fl 336
select * from condition_master cm
where state_fk IN
(select state_master_pk from state_master
where regexp_like (state_abbreviation,'^(IN)$'))
--and regexp_like(order_test_code,'^(315|317L|322|323|327)$')
and order_test_code = '336'
and status = 'active'
order by state_fk;

Insert into CONDITION_MASTER 
(CONDITION_MASTER_PK,STATE_FK,CONDITION_FILTER_FK,ORDER_TEST_CODE,RESULT_TEST_CODE,CONDITION,VALUE_TYPE,CONDITION_VALUE,STATUS,CREATED_DATE,CREATED_BY,LAST_UPDATED_DATE,LAST_UPDATED_BY) 
values 
((select max(condition_master_pk) + 1 from condition_master),39,2,'336','336','Positive Equivocal Reactive','ST',null,'active',systimestamp,'ADMIN',systimestamp,'ADMIN');


update condition_master
set condition_filter_fk = 3,condition='Detected',last_updated_date=systimestamp,last_updated_by='update_filter'
where condition_master_pk IN
(select condition_master_pk from condition_master cm
where state_fk IN
(select state_master_pk from state_master
where not regexp_like (state_abbreviation,'^(AL|CA|IL|LA|MD|NC|NJ|NM|NY|OR|PA|TX)$'))
and order_test_code = '311'
and status = 'active'
and condition_filter_fk = 4);
order by state_fk;

update condition_master
set status = 'inactive'
where condition_master_pk IN (1742);

update condition_master
set

select * from condition_filters
where condition_filter_pk IN (3,4);
