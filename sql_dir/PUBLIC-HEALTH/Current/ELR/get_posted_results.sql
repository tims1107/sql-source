select patient_account_state,order_number, result_test_code,textual_result_full,CAST(release_date_time AS TIMESTAMP) AS full_timestamp from results_sent_log r
where last_update_time > trunc(sysdate)
order by patient_account_state,order_number;
and result_test_code = '332'
order by order_number,result_test_code;

select count(1) from daily_results
;

select * from daily_results
where result_test_code = '332';

select * from asr_process_run
where activitydate = '10-JUL-25'
and complete = 'R'
and source = 'NC';

select * from asr_process_run
where activitydate = '06-AUG-25'
--and complete IN ('S');
and result_test_code = '332';

update asr_process_run
set complete = 'G'
where order_number IN
(select order_number from asr_process_run
where activitydate = '06-AUG-25')
and result_test_code = '332'
and complete = 'S';

select * from daily_results
where result_test_code = '310';

select * from asr_process_run
where activitydate = '31-JUL-25'
and regexp_like(source, '^(AL|CA|IL|LA|MD|NC|NJ|NM|NY|OR|TX|PA)$')
and complete = 'N'
order by source;
and result_test_code = '332';

select * from asr_process_run
where activitydate = '17-JUL-25'
and result_test_code = '336';

select patient_id from daily_results r
full join pat_results p ON p.requisition_id = r.order_number
where order_number = '5365TH8';


delete daily_results;

insert into daily_results
select r.* from daily_results_PA_20250718 r;
insert into daily_results
select r.* from daily_results_PA_20250719 r;
join patientmaster pm ON pm;
where facility_state;

select r.order_number,r.order_test_code,r.result_test_code,pr.activitydate from daily_results r
join pat_results p ON p.requisition_id = r.order_number
join asr_process_run pr ON pr.order_number = r.order_number and pr.result_test_code = r.result_test_code

where patient_account_state = 'PA'
or facility_state = 'PA'
--group by order_number,r.order_test_code
order by activitydate,r.order_number,r.order_test_code;

delete daily_results
where order_number not in ('5067CN8','5067CW8','5067CX8','5067FA8','5182M08','5234G88','5234MS8','5355ZU8','54935X8','51524H8','5288CX8','5481YS8','54843V8'); 

select order_number,order_test_code,count(1) from daily_results
where performing_lab_id = 'SHREF'
group by order_number,order_test_code;

where order_number = '51524H8';

update asr_process_run
set complete = 'Q'
where activitydate = '22-JUL-25'
and result_test_code = '311L';





update asr_process_run
set complete = 'Q'
where order_number IN
(select order_number from asr_process_run
where activitydate = '23-JUL-25'
and regexp_like(source, '^(NC)$')
and complete = 'N')
and result_test_code IN ('315','317L');
group by performing_lab_id;

select result_source,performing_lab_id,result_test_code,count(1) from results_sent_log
where order_number IN
(select order_number from asr_process_run
where activitydate = '08-AUG-25'
and regexp_like(source, '^(AL|CA|IL|LA|MD|NC|NJ|NM|NY|OR|PA|TX)$')
and regexp_like(complete ,'^(R|S)'))
group by result_source,performing_lab_id,result_test_code
order by result_source;

select * from results_sent_log
where result_source = 'California CAHL7GeneratorContext'
and last_update_time > sysdate -1;

delete results_sent_log
where order_number = '5072V38';

update asr_process_run
set complete = 'N' 
where order_number = '5072V38';

select result_source,performing_lab_id,result_test_code,count(1) from results_sent_log
where order_number IN
(select order_number from asr_process_run
where activitydate = '06-AUG-25'
and NOT regexp_like(source, '^(AL|CA|IL|LA|MD|NC|NJ|NM|NY|OR|TX)$')
and regexp_like(complete ,'^(N)'))
group by result_source,performing_lab_id,result_test_code
order by result_source;

select release_date_time,performing_lab_id from daily_results r
--join pat_results l ON l.requisition_id = r.order_number
where result_test_code = '332';



select release_date_time,performing_lab_id from daily_results r
where order_number = '22465H4';
select * from pat_results;
join pat_results_p ON p.requisition_id = r.order_number;
;



/
select * from 
(SELECT 
    last_update_time,
    order_number,
    result_source,
    result_test_code,
    release_date_time,
    ROUND((CAST(last_update_time AS DATE) - CAST(release_date_time AS DATE)) * 24, 0) AS hour_diff
FROM 
    results_sent_log)
WHERE 
    --result_source = 'Illinois ILHL7GeneratorContext'
     last_update_time > '01-JUL-25 01.01.12.185418000 AM'
     
     and hour_diff < 48
     and regexp_like(result_source,'^Illinois')
     and not regexp_like(result_test_code,'^7')
     
    -- (CAST(release_date_time AS DATE) - CAST(last_update_time AS DATE)) * 24 > 5
ORDER BY 
    hour_diff desc,last_update_time;



/

delete results_sent_log
where result_source = 'New York NYHL7GeneratorContext'
and last_update_time > '06-JUL-25 01.01.12.185418000 AM';

group by RELEASE_DATE_TIME,performing_lab_id;
group by perf;
where result_test_code = '332';

select row_numberpatient_last_name,patient_first_name,eid from pat_results
group by patient_last_name,patient_first_name,eid
having count(1) > 1;

select a.order_number,a.order_test_code,a.result_test_code,p.initiate_id eid,activitydate,performing_lab_id,source from asr_process_run a 
                join vw_patient_info p ON p.order_number  = a.order_number 
                where a.activitydate = '19-JUL-25' and complete IN ('R','S')
                and performing_lab_id IN ('SE','SEREF');

select performing_lab_id,source from asr_process_run
--where order_number = '4774F48';
where complete = 'R'
and activitydate = '04-JUL-25'
and performing_lab_id like 'SH%'
group by performing_lab_id,source
order by source;