select cm.*,cf.filter from condition_master cm
join condition_filters cf ON cf.condition_filter_pk = cm.condition_filter_fk
where state_fk = 14
and regexp_like(order_test_code,'^(315|327)');

select * from condition_master
where state_fk IN  ( 32,45,60);

update state_master
set status = 'inactive'
where state_master_pk IN ( 32,45,60,65);

select * from asr_process_run
where order_number = '7558BH8';

select * from results_sent_log
where order_number = '7558BH8';

select cm.*,cf.filter from condition_master cm
join condition_filters cf ON cf.condition_filter_pk = cm.condition_filter_fk
where cm.state_fk IN
(select state_master_pk from state_master
where state_abbreviation = 'MA')
and cm.status = 'active'
--and regexp_like(filter,'gtt');
and order_test_code = '310';

select state_master_pk,state_abbreviation,state from state_master
where state_abbreviation IN ('MO','MA')
and status = 'active';

select cm.*,cf.filter from condition_master cm
join condition_filters cf ON cf.condition_filter_pk = cm.condition_filter_fk
where cm.status = 'inactive'
and regexp_like(filter,'gtt');
and order_test_code = '311';

update condition_master
set status='inactive'
where condition_master_pk IN (1309);


Insert into CONDITION_MASTER (CONDITION_MASTER_PK,STATE_FK,CONDITION_FILTER_FK,ORDER_TEST_CODE,RESULT_TEST_CODE,CONDITION,VALUE_TYPE,CONDITION_VALUE,STATUS,CREATED_DATE,CREATED_BY,LAST_UPDATED_DATE,LAST_UPDATED_BY) values (848,12,4,'311',null,'All','ST',null,'inactive',to_timestamp('01-OCT-21 01.05.21.885672000 AM','DD-MON-RR HH.MI.SSXFF AM'),'staterpt',to_timestamp('30-OCT-24 03.08.50.895514000 AM','DD-MON-RR HH.MI.SSXFF AM'),'ASR_ADMIN_UPDATE');

Insert into CONDITION_MASTER (CONDITION_MASTER_PK,STATE_FK,CONDITION_FILTER_FK,ORDER_TEST_CODE,RESULT_TEST_CODE,CONDITION,VALUE_TYPE,CONDITION_VALUE,STATUS,CREATED_DATE,CREATED_BY,LAST_UPDATED_DATE,LAST_UPDATED_BY) 
values ((select max(condition_master_pk) + 1 from condition_master),1,4,'311',null,'All','ST',null,'active',systimestamp,'staterpt',systimestamp,'ASR_ADMIN_CONDITION');


update condition_master
set status = 'inactive'
where condition_master_pk = 796;

delete condition_master
where condition_master_pk = 1919;

SELECT * FROM 
(SELECT * FROM (SELECT gtt.* FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT gtt WHERE 1=1 
    AND gtt.order_test_code = '301' AND gtt.result_test_code = '301' AND ((upper(result_comments) LIKE upper('%Newly confirmed Positive%') or upper(result_comments) LIKE upper('%New positive%'))) 
UNION ALL 
SELECT gtt.* FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT gtt WHERE 1=1 AND gtt.order_test_code = '310' AND gtt.result_test_code = '310' AND ((upper(textual_result_full) LIKE upper('Positive%') or upper(textual_result_full) LIKE upper('Equivocal%') or upper(textual_result_full) LIKE upper('Reactive%'))) 
UNION ALL 
SELECT gtt.* FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT gtt WHERE 1=1 AND gtt.order_test_code = '312' AND gtt.result_test_code = '312' AND ((upper(textual_result_full) LIKE upper('Positive%') or upper(textual_result_full) LIKE upper('Equivocal%') or upper(textual_result_full) LIKE upper('Reactive%'))) UNION ALL SELECT gtt.* FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT gtt WHERE 1=1 AND gtt.order_test_code = '319N' AND gtt.result_test_code = '319N' AND ((upper(textual_result_full) LIKE upper('Positive%') or upper(textual_result_full) LIKE upper('Equivocal%') or upper(textual_result_full) LIKE upper('Reactive%'))) UNION ALL SELECT gtt.* FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT gtt WHERE 1=1 AND gtt.order_test_code = '9239' AND gtt.result_test_code = 'A409' AND ((upper(textual_result_full) LIKE upper('Positive%') or
upper(textual_result_full) LIKE upper('Equivocal%') or upper(textual_result_full) LIKE upper('Reactive%'))) UNION ALL SELECT gtt.* FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT gtt WHERE 1=1 AND gtt.order_test_code = '303' AND gtt.result_test_code = '303' AND ((upper(textual_result_full) LIKE upper('Positive%') or upper(textual_result_full) LIKE upper('Equivocal%') or upper(textual_result_full) LIKE upper('Reactive%'))) UNION ALL SELECT gtt.* FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT gtt WHERE 1=1 AND gtt.order_test_code = '308' AND gtt.result_test_code = '308' AND ((upper(textual_result_full) LIKE upper('Positive%') or upper(textual_result_full) LIKE upper('Equivocal%') or upper(textual_result_full) LIKE upper('Reactive%'))) UNION ALL SELECT gtt.* FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT gtt WHERE 1=1 AND gtt.order_test_code = '319C' AND gtt.result_test_code = '319T' AND ((upper(textual_result_full) LIKE upper('Positive%') or upper(textual_result_full) LIKE upper('Equivocal%') or upper(textual_result_full) LIKE upper('Reactive%'))) UNION ALL SELECT gtt.* FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT gtt WHERE 1=1 AND gtt.order_test_code = '304' AND gtt.result_test_code = '304' AND ((upper(textual_result_full) LIKE upper('Positive%') or upper(textual_result_full) LIKE upper('Equivocal%') or upper(textual_result_full) LIKE upper('Reactive%'))) UNION ALL SELECT gtt.* FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT gtt WHERE 1=1 AND
gtt.order_test_code = '310' AND gtt.result_test_code = '310A' AND ((gtt.value_type = 'ST' and gtt.textual_result_full like '%>11.00%')) UNION ALL SELECT gtt.* FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT gtt WHERE 1=1 AND gtt.order_test_code = '332' AND gtt.result_test_code = '332' AND ((upper(textual_result_full) LIKE upper('Positive%') or upper(textual_result_full) LIKE upper('Equivocal%') or upper(textual_result_full) LIKE upper('Reactive%'))) UNION ALL SELECT gtt.* FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT gtt WHERE 1=1 AND gtt.order_test_code = '336' AND gtt.result_test_code = '336' AND ((upper(textual_result_full) LIKE upper('Positive%') or upper(textual_result_full) LIKE upper('Equivocal%') or upper(textual_result_full) LIKE upper('Reactive%'))) UNION ALL SELECT gtt.* FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT gtt WHERE 1=1 AND gtt.order_test_code = '311' AND ((upper(textual_result_full) LIKE upper('%'))) UNION ALL SELECT gtt.* FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT gtt WHERE 1=1 AND gtt.order_test_code = '318' AND gtt.result_test_code = '318L' AND ((upper(textual_result_full) LIKE upper('%'))) UNION ALL SELECT gtt.* FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT gtt WHERE 1=1 AND gtt.order_test_code = '318' AND gtt.result_test_code = '318R' AND ((upper(textual_result_full) LIKE upper('%'))) UNION ALL SELECT gtt.* FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT gtt WHERE 1=1 AND gtt.order_test_code = '310' AND gtt.result_test_code = '310A'
AND ((gtt.value_type = 'NM' and gtt.numeric_result > 0.00))) WHERE patient_account_state = 'TX' AND TRUNC(release_date_time) = DATE '2025-09-02') base WHERE 1=1  AND result_status = 'F' AND (base.order_test_code != '310' OR       (SELECT COUNT(DISTINCT result_test_code)        FROM (SELECT * FROM (SELECT gtt.* FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT gtt WHERE 1=1 AND gtt.order_test_code = '301' AND gtt.result_test_code = '301' AND ((upper(result_comments) LIKE upper('%Newly confirmed Positive%') or upper(result_comments) LIKE upper('%New positive%'))) UNION ALL SELECT gtt.* FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT gtt WHERE 1=1 AND gtt.order_test_code = '310' AND gtt.result_test_code = '310' AND ((upper(textual_result_full) LIKE upper('Positive%') or upper(textual_result_full) LIKE upper('Equivocal%') or upper(textual_result_full) LIKE upper('Reactive%'))) UNION ALL SELECT gtt.* FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT gtt WHERE 1=1 AND gtt.order_test_code = '312' AND gtt.result_test_code = '312' AND ((upper(textual_result_full) LIKE upper('Positive%') or upper(textual_result_full) LIKE upper('Equivocal%') or upper(textual_result_full) LIKE upper('Reactive%'))) UNION ALL SELECT gtt.* FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT gtt WHERE 1=1 AND gtt.order_test_code = '319N' AND gtt.result_test_code = '319N' AND ((upper(textual_result_full) LIKE upper('Positive%') or upper(textual_result_full) LIKE upper('Equivocal%') or
upper(textual_result_full) LIKE upper('Reactive%'))) UNION ALL SELECT gtt.* FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT gtt WHERE 1=1 AND gtt.order_test_code = '9239' AND gtt.result_test_code = 'A409' AND ((upper(textual_result_full) LIKE upper('Positive%') or upper(textual_result_full) LIKE upper('Equivocal%') or upper(textual_result_full) LIKE upper('Reactive%'))) UNION ALL SELECT gtt.* FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT gtt WHERE 1=1 AND gtt.order_test_code = '303' AND gtt.result_test_code = '303' AND ((upper(textual_result_full) LIKE upper('Positive%') or upper(textual_result_full) LIKE upper('Equivocal%') or upper(textual_result_full) LIKE upper('Reactive%'))) UNION ALL SELECT gtt.* FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT gtt WHERE 1=1 AND gtt.order_test_code = '308' AND gtt.result_test_code = '308' AND ((upper(textual_result_full) LIKE upper('Positive%') or upper(textual_result_full) LIKE upper('Equivocal%') or upper(textual_result_full) LIKE upper('Reactive%'))) UNION ALL SELECT gtt.* FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT gtt WHERE 1=1 AND gtt.order_test_code = '319C' AND gtt.result_test_code = '319T' AND ((upper(textual_result_full) LIKE upper('Positive%') or upper(textual_result_full) LIKE upper('Equivocal%') or upper(textual_result_full) LIKE upper('Reactive%'))) UNION ALL SELECT gtt.* FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT gtt WHERE 1=1 AND gtt.order_test_code = '304' AND gtt.result_test_code = '304' AND
((upper(textual_result_full) LIKE upper('Positive%') or upper(textual_result_full) LIKE upper('Equivocal%') or upper(textual_result_full) LIKE upper('Reactive%'))) UNION ALL SELECT gtt.* FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT gtt WHERE 1=1 AND gtt.order_test_code = '310' AND gtt.result_test_code = '310A' AND ((gtt.value_type = 'ST' and gtt.textual_result_full like '%>11.00%')) UNION ALL SELECT gtt.* FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT gtt WHERE 1=1 AND gtt.order_test_code = '332' AND gtt.result_test_code = '332' AND ((upper(textual_result_full) LIKE upper('Positive%') or upper(textual_result_full) LIKE upper('Equivocal%') or upper(textual_result_full) LIKE upper('Reactive%'))) UNION ALL SELECT gtt.* FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT gtt WHERE 1=1 AND gtt.order_test_code = '336' AND gtt.result_test_code = '336' AND ((upper(textual_result_full) LIKE upper('Positive%') or upper(textual_result_full) LIKE upper('Equivocal%') or upper(textual_result_full) LIKE upper('Reactive%'))) UNION ALL SELECT gtt.* FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT gtt WHERE 1=1 AND gtt.order_test_code = '311' AND ((upper(textual_result_full) LIKE upper('%'))) UNION ALL SELECT gtt.* FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT gtt WHERE 1=1 AND gtt.order_test_code = '318' AND gtt.result_test_code = '318L' AND ((upper(textual_result_full) LIKE upper('%'))) UNION ALL SELECT gtt.* FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT gtt WHERE 1=1 AND
gtt.order_test_code = '318' AND gtt.result_test_code = '318R' AND ((upper(textual_result_full) LIKE upper('%'))) UNION ALL SELECT gtt.* FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT gtt WHERE 1=1 AND gtt.order_test_code = '310' AND gtt.result_test_code = '310A' AND ((gtt.value_type = 'NM' and gtt.numeric_result > 0.00))) WHERE patient_account_state = 'TX' AND TRUNC(release_date_time) = DATE '2025-09-02') check_310        WHERE check_310.accession_number = base.accession_number        AND check_310.order_test_code = '310') != 1) AND ROWNUM <= 200 ORDER BY accession_number, order_test_code, result_test_code;



Insert into CONDITION_MASTER (CONDITION_MASTER_PK,STATE_FK,CONDITION_FILTER_FK,ORDER_TEST_CODE,RESULT_TEST_CODE,CONDITION,VALUE_TYPE,CONDITION_VALUE,STATUS,CREATED_DATE,CREATED_BY,LAST_UPDATED_DATE,LAST_UPDATED_BY) values (55,3,2,'310','310','Positive Equivocal Reactive','ST',null,'active',to_timestamp('05-APR-18 09.12.31.002427000 AM','DD-MON-RR HH.MI.SSXFF AM'),'staterpt',to_timestamp('05-APR-18 09.12.31.002427000 AM','DD-MON-RR HH.MI.SSXFF AM'),'staterpt');
Insert into CONDITION_MASTER (CONDITION_MASTER_PK,STATE_FK,CONDITION_FILTER_FK,ORDER_TEST_CODE,RESULT_TEST_CODE,CONDITION,VALUE_TYPE,CONDITION_VALUE,STATUS,CREATED_DATE,CREATED_BY,LAST_UPDATED_DATE,LAST_UPDATED_BY) values 
((select max(condition_master_pk) + 1 from condition_master),14,2,'301','301','Positive Equivocal Reactive','ST',null,'active',systimestamp,'staterpt',systimestamp,'ASR_ADMIN');
Insert into CONDITION_MASTER (CONDITION_MASTER_PK,STATE_FK,CONDITION_FILTER_FK,ORDER_TEST_CODE,RESULT_TEST_CODE,CONDITION,VALUE_TYPE,CONDITION_VALUE,STATUS,CREATED_DATE,CREATED_BY,LAST_UPDATED_DATE,LAST_UPDATED_BY) values (842,3,5,'310','310A','Only >11','ST','>11.00','active',to_timestamp('27-JAN-21 11.39.11.476149000 AM','DD-MON-RR HH.MI.SSXFF AM'),'ASR_ADMIN',null,null);


select * from asr_process_run_20250903
where activitydate = '03-SEP-25'
and source = 'NC';
and complete IN ('R','S');

select r.* from asr_process_run r
join (select * from asr_process_run
where complete = 'N') t1 ON t1.order_number = r.order_number and t1.result_test_code = r.result_test_code
order by r.source,r.order_test_code,r.order_number;

delete asr_process_run
where complete = 'N';


delete gtt_results_extract;

insert into gtt_results_extract
select * from gtt_results_extract_20250903;

commit;

select count(1) from gtt_results_extract_20250903;

create table gtt_results_extract_20250903
as
select * from gtt_results_extract;

delete asr_process_run
where activitydate = '03-SEP-25';

select source from asr_process_run_20250903
group by source;

update asr_process_run
set complete = 'N'
where order_number = '7293GH8';

delete results_sent_log
where order_number = '7293GH8';


select source,count(1) from report_results
group by source
order by source;


create table asr_process_run_20250903
as
select * from asr_process_run
where activitydate = '03-SEP-25'
and order_number IN
(select order_number from report_results
where source = 'TX'
and not regexp_like(result_test_code,'^P'))
and result_test_code not like ('111')
and source = 'TX';
and complete = 'N';

update condition_master
set status = 'inactive'
where state_fk IN
(select state_master_pk from state_master
        where length(state_abbreviation) = 2
        and entity_type = 'Abnormal'
        and status = 'active'
        and state_abbreviation = 'AL'
        --order by state_abbreviation
) and regexp_like(order_test_code,'^7');

select * from condition_filters;

update asr_process_run
set complete = 'Z'
where complete = 'N';

select * from asr_process_run
where complete IN ('Z')
and source  IN ('NY')
and activitydate = '02-SEP-25';
and order_test_code IN ('311')
order by source;

update gtt_results_extract
set numeric_result = 1.1
where order_number = '68508A8'
and result_test_code = '310A';

/

SELECT order_number,result_test_code,numeric_result,textual_result_full FROM (SELECT gtt.* FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT gtt WHERE 1=1 AND gtt.order_test_code = '301' AND gtt.result_test_code = '301' AND ((upper(result_comments) LIKE upper('%Newly confirmed Positive%') or upper(result_comments) LIKE upper('%New positive%'))) UNION ALL SELECT gtt.* FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT gtt WHERE 1=1 AND gtt.order_test_code = '310' AND gtt.result_test_code = '310' AND ((upper(textual_result_full) LIKE upper('Positive%') or upper(textual_result_full) LIKE upper('Equivocal%') or upper(textual_result_full) LIKE upper('Reactive%')))
 UNION ALL SELECT gtt.* FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT gtt WHERE 1=1 AND gtt.order_test_code = '312' AND gtt.result_test_code = '312' AND ((upper(textual_result_full) LIKE upper('Positive%') or upper(textual_result_full) LIKE upper('Equivocal%') or upper(textual_result_full) LIKE upper('Reactive%')))
 UNION ALL SELECT gtt.* FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT gtt WHERE 1=1 AND gtt.order_test_code = '319N' AND gtt.result_test_code = '319N' AND ((upper(textual_result_full) LIKE upper('Positive%') or upper(textual_result_full) LIKE upper('Equivocal%') or upper(textual_result_full) LIKE upper('Reactive%')))
 UNION ALL SELECT gtt.* FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT gtt WHERE 1=1 AND gtt.order_test_code = '9239' AND gtt.result_test_code = 'A409' AND ((upper(textual_result_full) LIKE upper('Positive%') or upper(textual_result_full) LIKE upper('Equivocal%') or upper(textual_result_full) LIKE upper('Reactive%')))
 UNION ALL SELECT gtt.* FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT gtt WHERE 1=1 AND gtt.order_test_code = '303' AND gtt.result_test_code = '303' AND ((upper(textual_result_full) LIKE upper('Positive%') or upper(textual_result_full) LIKE upper('Equivocal%') or upper(textual_result_full) LIKE upper('Reactive%')))
 UNION ALL SELECT gtt.* FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT gtt WHERE 1=1 AND gtt.order_test_code = '308' AND gtt.result_test_code = '308' AND ((upper(textual_result_full) LIKE upper('Positive%') or upper(textual_result_full) LIKE upper('Equivocal%') or upper(textual_result_full) LIKE upper('Reactive%')))
 UNION ALL SELECT gtt.* FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT gtt WHERE 1=1 AND gtt.order_test_code = '319C' AND gtt.result_test_code = '319T' AND ((upper(textual_result_full) LIKE upper('Positive%') or upper(textual_result_full) LIKE upper('Equivocal%') or upper(textual_result_full) LIKE upper('Reactive%')))
 UNION ALL SELECT gtt.* FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT gtt WHERE 1=1 AND gtt.order_test_code = '304' AND gtt.result_test_code = '304' AND ((upper(textual_result_full) LIKE upper('Positive%') or upper(textual_result_full) LIKE upper('Equivocal%') or upper(textual_result_full) LIKE upper('Reactive%')))
 UNION ALL SELECT gtt.* FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT gtt WHERE 1=1 AND gtt.order_test_code = '310' AND gtt.result_test_code = '310A' AND ((gtt.value_type = 'ST' and gtt.textual_result_full like '%>11.00%'))
 UNION ALL SELECT gtt.* FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT gtt WHERE 1=1 AND gtt.order_test_code = '332' AND gtt.result_test_code = '332' AND ((upper(textual_result_full) LIKE upper('Positive%') or upper(textual_result_full) LIKE upper('Equivocal%') or upper(textual_result_full) LIKE upper('Reactive%')))
 UNION ALL SELECT gtt.* FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT gtt WHERE 1=1 AND gtt.order_test_code = '336' AND gtt.result_test_code = '336' AND ((upper(textual_result_full) LIKE upper('Positive%') or upper(textual_result_full) LIKE upper('Equivocal%') or upper(textual_result_full) LIKE upper('Reactive%')))
 UNION ALL SELECT gtt.* FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT gtt WHERE 1=1 AND gtt.order_test_code = '311' AND ((upper(textual_result_full) LIKE upper('%')))
 UNION ALL SELECT gtt.* FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT gtt WHERE 1=1 AND gtt.order_test_code = '318' AND gtt.result_test_code = '318L' AND ((upper(textual_result_full) LIKE upper('%')))
 UNION ALL SELECT gtt.* FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT gtt WHERE 1=1 AND gtt.order_test_code = '318' AND gtt.result_test_code = '318R' AND ((upper(textual_result_full) LIKE upper('%')))
 UNION ALL SELECT gtt.* FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT gtt WHERE 1=1 AND gtt.order_test_code = '310' AND gtt.result_test_code = '310A' AND ((gtt.value_type = 'NM' and gtt.numeric_result > 0.00))
) base WHERE patient_account_state = 'TX' AND TRUNC(release_date_time) = DATE '2025-09-02' AND (base.order_test_code != '310' OR (SELECT COUNT(DISTINCT result_test_code) FROM GTT_RESULTS_EXTRACT orig_gtt WHERE orig_gtt.accession_number = base.accession_number AND orig_gtt.order_test_code = '310' AND orig_gtt.result_test_code IN ('310', '310A') AND orig_gtt.patient_account_state = 'TX' AND TRUNC(orig_gtt.release_date_time) = DATE '2025-09-02') = 2);



/

select value_type,order_number,order_test_code,result_test_code,textual_result_full,value_type,result_status,trunc(release_date_time),trunc(sysdate - 1) from gtt_results_extract
--where patient_account_state = 'AL'
--where order_test_code IN ('301','310','311','318')
where trunc(release_date_time) = trunc(sysdate - 1)
--and textual_result_full in ('Positive')
--and order_method NOT IN ('MICRO')
and regexp_like(order_test_code,'^310')
and patient_account_state='TX'
and order_number IN ('68508A8')
and result_status = 'F';

SELECT    sm.state_abbreviation,
        sm.state,
        cm.state_fk,
            cm.condition_master_pk,
            cf.condition_filter_pk,
            cm.order_test_code,
            cm.result_test_code,
            cm.condition_value,
            cm.value_type,  -- Add this field
            cm.status,
            cf.filter
        FROM CONDITION_MASTER cm
        JOIN CONDITION_FILTERS cf ON cm.condition_filter_fk = cf.condition_filter_pk
        join state_master sm ON sm.state_master_pk = cm.state_fk
        where length(state_abbreviation) = 2
        and entity_type = 'Abnormal'
        AND cm.order_test_code = '311'
        and state_abbreviation in ('AL','IL','CA','NY','MI')
       
        AND cm.status = 'active'
        AND cf.status = 'active'
        order by state;
        
        select state_abbreviation,state,state_master_pk from state_master
        where length(state_abbreviation) = 2
        and entity_type = 'Abnormal'
        and status = 'active'
        --and state_abbreviation = 'FM'
        order by state_abbreviation
        ;
        
        delete condition_master
--select * from condition_master
--where state_fk = 24;
where condition_master_pk IN (1097,1589,1349,1350,1741,154,1753,1754,876,1367,910,
893,1440,1679,944,1571,1625,1483,1114);
        
select * from condition_master
where result_test_code = '310A';
        
select * from state_master
        where state_abbreviation = 'AR';

Insert into CONDITION_MASTER (CONDITION_MASTER_PK,STATE_FK,CONDITION_FILTER_FK,ORDER_TEST_CODE,RESULT_TEST_CODE,CONDITION,VALUE_TYPE,CONDITION_VALUE,STATUS,CREATED_DATE,CREATED_BY,LAST_UPDATED_DATE,LAST_UPDATED_BY) 
values ((select max(condition_master_pk) + 1 from condition_master),26,6,'310','310A','> 0.00','NM','> 0.00','active',systimestamp,'ASR_ADMIN_UPDATE',systimestamp,'ASR_ADMIN_UPDATE');




select max(condition_filter_pk) from condition_filters
where condition_filter_pk = 51;

update condition_master
set condition_value = 1,value_type = 'NM',condition_value
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