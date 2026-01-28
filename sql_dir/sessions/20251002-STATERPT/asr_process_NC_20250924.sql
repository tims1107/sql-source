select * from asr_process_run
where activitydate = '25-SEP-25'
and complete IN ('R','S')
and not regexp_like(order_test_code,'^(317L|315|322|323|327)$')
and source = 'NC';


select * from asr_process_NC_20250924;

select * from asr_process_run
where activitydate = '24-SEP-25'
and source = 'NC'
and complete IN ('N');

select * from asr_process_run
where complete IN ('N');

create table asr_process_NC_20250925
as
select * from asr_process_run
where activitydate = '25-SEP-25'
and complete IN ('R','S')
and not regexp_like(order_test_code,'^(317L|315|322|323|327)$')
and source = 'NC'
order by activitydate,order_number;

update asr_process_run
set complete = 'N'
where (order_number,result_test_code) IN
(select order_number,result_test_code from asr_process_NC_20250924);

update asr_process_run
set complete = 'S'
where (order_number,result_test_code) IN
(select order_number,result_test_code from asr_process_NC_20250924)
and result_test_code IN ('332');
;

update asr_process_run
set complete = 'R'
where (order_number,result_test_code) IN
(select order_number,result_test_code from asr_process_CA_20250923);

-- create results_sent_log backup
create table results_sent_log_NC_20250925
as
select * from results_sent_log
where (order_number,result_test_code) IN
(select order_number,result_test_code from asr_process_NC_20250925);

select order_number,result_test_code,to_char(release_date_time,'yyyyMMddHH24mi') rel_date from results_sent_log_NC_20250924;


-- Quick calculation for total minutes difference
SELECT order_number,result_test_code,to_char(release_date_time,'yyyyMMddHH24mi') rel_date,
ROUND((TO_DATE('202509250200', 'YYYYMMDDHH24MI') - TO_DATE(to_char(release_date_time,'yyyyMMddHH24mi'), 'YYYYMMDDHH24MI')) * 1440, 0) AS minutes_diff
FROM results_sent_log_NC_20250924;

SELECT 
  order_number,
  result_test_code,
  to_char(release_date_time,'yyyyMMddHH24mi') rel_date,
  ROUND((TO_DATE('202509250000', 'YYYYMMDDHH24MI') - TO_DATE(to_char(release_date_time,'yyyyMMddHH24mi'), 'YYYYMMDDHH24MI')) * 1440, 0) AS minutes_diff,
  FLOOR((TO_DATE('202509250000', 'YYYYMMDDHH24MI') - TO_DATE(to_char(release_date_time,'yyyyMMddHH24mi'), 'YYYYMMDDHH24MI')) * 24) AS hours_diff,
  MOD(ROUND((TO_DATE('202509250000', 'YYYYMMDDHH24MI') - TO_DATE(to_char(release_date_time,'yyyyMMddHH24mi'), 'YYYYMMDDHH24MI')) * 1440, 0), 60) AS remaining_minutes,
  FLOOR((TO_DATE('202509250000', 'YYYYMMDDHH24MI') - TO_DATE(to_char(release_date_time,'yyyyMMddHH24mi'), 'YYYYMMDDHH24MI')) * 24) || 'h ' ||
  MOD(ROUND((TO_DATE('202509250000', 'YYYYMMDDHH24MI') - TO_DATE(to_char(release_date_time,'yyyyMMddHH24mi'), 'YYYYMMDDHH24MI')) * 1440, 0), 60) || 'm' AS formatted_diff
FROM results_sent_log_NC_20250924;

/
SELECT 
  order_number,
  result_test_code,
  '''' || to_char(release_date_time,'yyyyMMddHH24mi') AS rel_date,
  
  -- 24-hour delivery deadline
  release_date_time + 1 AS delivery_deadline,
  '''' || to_char(release_date_time + 1, 'yyyyMMddHH24mi') AS delivery_deadline_formatted,
  
  -- Time differences from current time (202509250200)
  ROUND((TO_DATE('202509260200', 'YYYYMMDDHH24MI') - TO_DATE(to_char(release_date_time,'yyyyMMddHH24mi'), 'YYYYMMDDHH24MI')) * 1440, 0) AS minutes_diff,
  FLOOR((TO_DATE('202509260200', 'YYYYMMDDHH24MI') - TO_DATE(to_char(release_date_time,'yyyyMMddHH24mi'), 'YYYYMMDDHH24MI')) * 24) AS hours_diff,
  
  -- Time remaining until deadline
  ROUND((TO_DATE(to_char(release_date_time + 1, 'yyyyMMddHH24mi'), 'YYYYMMDDHH24MI') - TO_DATE('202509260200', 'YYYYMMDDHH24MI')) * 1440, 0) AS minutes_until_deadline,
  FLOOR((TO_DATE(to_char(release_date_time + 1, 'yyyyMMddHH24mi'), 'YYYYMMDDHH24MI') - TO_DATE('202509260200', 'YYYYMMDDHH24MI')) * 24) AS hours_until_deadline,
  
  -- Status check
  CASE 
    WHEN TO_DATE('202509260200', 'YYYYMMDDHH24MI') > (release_date_time + 1) THEN 'OVERDUE'
    WHEN TO_DATE('202509260200', 'YYYYMMDDHH24MI') > (release_date_time + 0.75) THEN 'WARNING'
    ELSE 'ON TIME'
  END AS delivery_status
  
FROM results_sent_log_NC_20250925;

/

delete results_sent_log
where (order_number,result_test_code) IN
(select order_number,result_test_code from asr_process_NC_20250924);

update condition_master
set status = 'inactive'
where regexp_like(order_test_code,'^(315|317L|322|323|327)$');



select * from asr_process_run
where activitydate = trunc(sysdate -1)
and order_test_code = '311'
and not regexp_like (source,'^(AL|CA|IL|LA|MD|NC|NJ|NM|NY|OR|PA|TX)$')
and regexp_like(textual_result_full,'^(Not Detected)$')
order by source,order_number;

update asr_process_run
set complete = 'Q'
where (order_number,result_test_code) IN
(select order_number,result_test_code from asr_process_run
where activitydate = trunc(sysdate -1)
and order_test_code = '311'
and not regexp_like (source,'^(AL|CA|IL|LA|MD|NC|NJ|NM|NY|OR|PA|TX)$')
and regexp_like(textual_result_full,'^(Not Detected)$')
and complete = 'N');

delete results_sent_log
where (order_number,result_test_code) IN
(select order_number,result_test_code from asr_process_run
where activitydate = trunc(sysdate -1)
and order_test_code = '311'
and not regexp_like (source,'^(AL|CA|IL|LA|MD|NC|NJ|NM|NY|OR|PA|TX)$')
and regexp_like(textual_result_full,'^(Not Detected)$')
and complete = 'Q');


order by source,order_number;

select result_test_code,textual_result_full from gtt_results_extract
where order_number = '8076B58'
and order_test_code = '310';

update asr_process_run
set complete = 'Q'
where source = 'NC'
and complete = 'N';

delete asr_process_PA_20250919
where complete not in ('R');

create table asr_process_CA_20250919
as
select * from asr_process_run
where activitydate = '19-SEP-25'
--and complete IN ('N')
and not regexp_like(order_test_code,'^(317L|315|322|323|327)$')
and source = 'PA'
order by activitydate,order_number;


update asr_process_run
set complete = 'N'
where (order_number,result_test_code) IN
(select order_number,result_test_code from asr_process_PA_20250919);

update asr_process_run
set complete = 'R'
where (order_number,result_test_code) IN
(select order_number,result_test_code from asr_process_PA_20250919);


create table results_sent_log_PA_20250919
as
select * from results_sent_log
where (order_number,result_test_code) IN
(select order_number,result_test_code from asr_process_PA_20250919);

delete results_sent_log
where (order_number,result_test_code) IN
(select order_number,result_test_code from asr_process_PA_20250919);

select source,order_number,result_test_code from asr_process_run
where complete = 'D'
and activitydate = trunc(sysdate -1 )
group by order_number,source,result_test_code
order by source,result_test_code;

select * from asr_process_run
where complete = 'N';


-- Change NC Context
-- NCHL7GeneratorContext 
-- Old context CAHL7GeneratorContext

select * from generator
where state_fk IN
(select state_master_pk from state_master
where state_abbreviation = 'NC');

update generator
set conversion_context = 'NCHL7GeneratorContext'
where generator_pk = 42;