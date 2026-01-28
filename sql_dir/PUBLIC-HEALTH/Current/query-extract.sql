select patient_account_state,release_date_time from extract_results_permanent
where trunc(release_date_time) = '15-DEC-25'
order by release_date_time desc;

select source,result_test_code,complete,activitydate,count(1) from asr_process_run
where activitydate = (select trunc(max(release_date_time)) from extract_results_permanent)
--and complete = 'N'
group by source,result_test_code,complete,activitydate
order by asr_process_run.source;

delete asr_process_run
where order_number = '0054T39';

select * from EXTRACT_RESULTS_PERMANENT
order by extraction_timestamp desc;

select * from asr_process_run
where activitydate = '20-JAN-26';


update asr_process_run
set complete = 'N'
where activitydate = '20-JAN-26';

select r.created_date,r.filename,r.* from pdf_reports r
order by r.created_date desc;

select * from daily_results;
/

begin

populate_pat_results();
end;