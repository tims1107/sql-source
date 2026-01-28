select * from asr_process_run
where complete = 'N'
and regexp_like(source,'^(AL|CA|IL|LA|NC|NM|NJ|NY|MD|PA|TX)$')
--and textual_result_full = 'Not Detected'
and activitydate = '15-OCT-25'
--and result_test_code = '336'
--and textual_result_full = 'Nonreactive'
order by source;

UPDATE asr_process_run
set complete = 'N'
where activitydate = '29-OCT-25'
and complete = 'R'
and source = 'IL';
and order_test_code IN ('110','111','113');

select * from asr_process_run
where source like ( 'IL')
and complete = 'N';

select to_char(release_date_time,'dd-MON-yy HH:miAM') rel_date from ih_dw.results r
join asr_process_run a ON a.order_number = r.requisition_id
where complete = 'N'
and source = 'IL' 
order by release_date_time;

select * from gtt_results_extract;

SELECT order_number,to_char(release_date_time,'DD-MON-YY HH24:MI') rel_date,a.textual_result_full 
FROM ih_dw.results r
JOIN asr_process_run a ON a.order_number = r.requisition_id and a.result_test_code = r.result_test_code
WHERE complete = 'N'
and activitydate = '21-OCT-25'
--AND source = 'IL' 
--and not regexp_like(a.textual_result_full,'Negative')
ORDER BY release_date_time desc;

create table results_sent_log_20251105_NC
as
select * from results_sent_log
where (order_number,result_test_code) IN
(select order_number,result_test_code from asr_process_run_20251105_NC
where activitydate = '05-NOV-25');

select * from asr_process_run_20251105_NC;
select * from results_sent_log_20251105_NC;

create table asr_process_run_20251105_NC
as
select * from asr_process_run
where activitydate = '05-NOV-25'
and source = 'NC';

select source,count(1) from asr_process_run_20251104
group by source
order by source;



select * from asr_process_run
where (order_number,result_test_code) IN
(select order_number,result_test_code from asr_process_run_20251104
) 
and complete = 'N';
;

update asr_process_run
set complete = 'N'
where (order_number,result_test_code) IN
(select order_number,result_test_code from asr_process_run_20251105_NC);

delete results_sent_log
where (order_number,result_test_code) IN
(select order_number,result_test_code from asr_process_run_20251105_NC);

/
 DELETE FROM asr_process_run 
    --WHERE activitydate = TO_CHAR(v_process_date, 'DD-MON-YY')
    where activitydate = '04-NOV-25'
    AND order_test_code = '310'
    AND (order_number, order_test_code) IN (
        SELECT order_number, order_test_code
        FROM asr_process_run
        --WHERE activitydate = TO_CHAR(v_process_date, 'DD-MON-YY')
        where activitydate = '04-NOV-25'
        AND order_test_code = '310'
        and order_number IN ('9203SH8',
'9366M68',
'93934H8',
'9211TU8',
'94238S8')
        GROUP BY order_number, order_test_code
        HAVING COUNT(1) = 1
    );
    
    select * from asr_process_run
    --where complete = 'N';
    where order_number IN ('9203SH8',
'9366M68',
'93934H8',
'9211TU8',
'94238S8');

Update asr_process_run
set activitydate = '04-NOV-25'
where activitydate = '04-Nov-25';


/
select * from asr_process_run
--where complete = 'N';
where activitydate = '05-NOV-25'
and complete = 'N';

select source,count(1) from asr_process_run
where (order_number) in
(select order_number from asr_process_run
where complete = 'N'
)
group by source
order by source;

select e.state_processed,to_char(release_date_time,'dd-MON-yy HH:mi') from extract_results_permanent e
where (order_number,result_test_code) NOT IN
(select order_number,result_test_code from asr_process_run_20251104);

select * from asr_process_run
where source='PA'
and ;

select source,count(1) from asr_process_run
where (order_number,result_test_code) IN
(select order_number,result_test_code from asr_process_run_20251104)
and complete = 'N'
group by source
order by source;
;

/

select release_date_time from EXTRACT_RESULTS_PERMANENT
where trunc(release_date_time) = '05-NOV-25'
and patient_account_state= 'IL';

delete EXTRACT_RESULTS_PERMANENT;

-- V3__Add_unique_constraint_extract_results_permanent.sql
DROP INDEX "STATERPT_OWNER"."IDX_EXTRACT_ORDER_RESULT";

ALTER TABLE "STATERPT_OWNER"."EXTRACT_RESULTS_PERMANENT" 
ADD CONSTRAINT "UK_EXTRACT_ORDER_RESULT" 
UNIQUE ("ORDER_NUMBER", "RESULT_TEST_CODE");

/

update asr_process_run
set complete = 'R'
where (order_number,result_test_code) IN
(select order_number,result_test_code from results_sent_log_20251031
where order_test_code = '311');

delete results_sent_log
where (order_number,result_test_code) IN
(select order_number,result_test_code from results_sent_log_20251031
where order_test_code = '311');

select order_number,order_test_code,result_test_code from results_sent_log
where last_update_time > sysdate - .1
and result_test_code = '311L';

select * from asr_process_run
where result_test_code = '336'
and source = 'NY'
and textual_result_full = 'Reactive'
and not regexp_like(patient_last_name,'test','i')
order by to_date(activitydate,'dd-MON-yy');

select * from asr_process_run
where result_test_code = '332'
and activitydate = trunc(sysdate )
and complete = 'S';

select result_test_code,textual_result_full from ih_dw.results
where regexp_like(result_test_code,'^P1')
and requisition_id = '9087BZ8';

select * from prompt_table;

select source,count(1) from asr_process_run
where complete = 'N'
group by source
order by source;

delete asr_process_run
where complete = 'N'
and activitydate = '04-NOV-25';

select * from asr_process_run
where complete = 'N'
and activitydate = '04-NOV-25'
and source = 'TX';


select result_test_code,count(1) from asr_process_run
where activitydate = trunc(sysdate)
and source = 'IL'
group by result_test_code;

update asr_process_run
set complete = 'R'
where (order_number,result_test_code) in
(select order_number,result_test_code from asr_process_run
where complete = 'N'
and source = 'IL'
and activitydate = trunc(sysdate - 1));

delete results_sent_log
where (order_number,result_test_code) in
(select order_number,result_test_code from asr_process_run
where complete = 'N'
and source = 'IL'
and activitydate = trunc(sysdate - 1));

select order_number,result_test_code,last_update_time,to_char(release_date_time,'hh24:mi') rel_date from gtt_results_extract
order by last_update_time desc;

select * from asr_process_run
where complete = 'N'
and source = 'IL';



update asr_process_run
set complete = 'T'
where order_number = '2848MM4';

select * from asr_process_run
where complete = 'N'
and textual_result_full = 'Not Detected'
and activitydate = '15-OCT-25'
and regexp_like(order_test_code,'^(311|318)$')
order by source;

select * from asr_process_run
where complete = 'N'
and activitydate = '15-OCT-25'
and regexp_like(order_test_code,'^(310|301)$')
order by source;

select * from condition_filters
where condition_filter;

delete asr_process_run
where complete = 'N'
and activitydate = '14-OCT-25';

update condition_master
set status = 'inactive'
where condition_master_pk IN (1740,1576,1158,1904,1001,31);

update condition_master
set condition_filter_fk = 3,condition = 'Detected',last_updated_date = systimestamp,last_updated_by='Condition Update'
where condition_master_pk IN (1208,1206,1926,1902,
1905,31,914,916,1101,1103,931,1612,863,897,1354,880,948,1314,1427,1558,1666,1470,1296,153,161,1176,1224,
1033,1506,1390,1050,1762,1372,1452,982,984,965,1067,1140,1927,1242,1409,1278,1696,1016,1648,1084,1718,1260,
1488,1594,1630);




select sm.state_abbreviation,cm.*,cf.filter from condition_master cm
join condition_filters cf ON cf.condition_filter_pk = cm.condition_filter_fk
join state_master sm  ON sm.state_master_pk = state_fk
where state_fk IN
(select state_master_pk from state_master
where NOT regexp_like(state_abbreviation,'^(NJ|NY)$'))
and regexp_like(order_test_code,'^(311|318)$')
and not regexp_
and length(state_abbreviation) = 2
and cm.status = 'active'
order by state_abbreviation;

select * from condition_master
where;

select length(state_abbreviation),sm.state_abbreviation,cm.*,cf.filter from condition_master cm
join condition_filters cf ON cf.condition_filter_pk = cm.condition_filter_fk
join state_master sm  ON sm.state_master_pk = state_fk
where state_fk IN
(select state_master_pk from state_master
where NOT regexp_like(state_abbreviation,'^(XX)$'))
and length(state_abbreviation) = 2
and regexp_like(order_test_code,'^(315|317L|322|323|327)$')
and cm.status = 'active'
order by state_abbreviation;