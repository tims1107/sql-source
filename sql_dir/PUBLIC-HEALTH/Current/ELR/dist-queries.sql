select file_name,destination_path,processed_date from processed_files
where processed_date > trunc(sysdate - 10)
and destination_path = '\\10.16.199.53\spectraHLAB_External_Interface_Results\nc_doh'
order by processed_date desc;

select file_name,destination_path,processed_date from processed_files
where processed_date > trunc(sysdate)
--and regexp_like(destination_path,'il_doh')
order by processed_date desc;


select file_name,destination_path,processed_date from processed_files
where processed_date > trunc(sysdate)
--and regexp_like(destination_path,'nc_doh')
order by processed_date desc;

select * from file_dist_log
where created_at > trunc(sysdate)
--and regexp_like(file_content,'^(File copied|File removed)','i')
order by file_name;

select * from asr_process_run
where order_test_code = '332'
and activitydate = '21-OCT-25'
order by source;

select * from file_dist_log
where created_at > trunc(sysdate)
--and regexp_like(file_name,'IL.HL7.2025')
--and file_content is null
and regexp_like(file_content,'^(FHS|MSH)')
order by created_at desc;

select * from file_dist_log
where regexp_like(file_name,'AL.HL7.2025')
--and file_content is null
and regexp_like(file_content,'^(FHS|MSH)')
order by created_at desc;

select * from asr_process_run
where complete = 'R'
and activitydate = trunc(sysdate - 1)
and source = 'NY'
order by source,order_number;

update asr_process_run
set complete = 'N'
where activitydate = trunc(sysdate - 1)
and source = 'NY';

select source ,complete,count(1)from asr_process_run
where activitydate = '22-AUG-25'
--where complete IN ('L')
group by source,complete
order by source;

select * from hl7_message
order by created_date desc;


select a.order_number,b.order_number,a.order_test_code,a.result_test_code,a.textual_result_full from asr_process_run a 
full outer join results_sent_log_20250822 b ON b.order_number = a.order_number and b.result_test_code = a.result_test_code
where a.activitydate = '22-AUG-25'
and a.complete = 'L'
and patient_account_state = 'NC'
order by a.order_test_code,a.order_number;

select source ,complete,count(1)from asr_process_run_20250822_RSQ
where activitydate = '22-AUG-25'
--where complete IN ('L')
and complete IN ('R','S')
group by source,complete
order by source;

select * from asr_process_run;

delete asr_process_run
where source is null;

select * from patientmaster 
where eid IN
(select initiate_id from ih_dw.dim_lab_order
where requisition_id IN ('0558TBS',
'0558TCS',
'0558TFS',
'0558TGS',
'0558TAS',
'0628HKS',
'0628HKS'));

select * from asr_process_run
where source = 'AK'
and activitydate = '22-AUG-25'

and complete = 'N';

select * from asr_process_run
where source= 'NC'
and complete IN ('N','F','L')
and order_test_code = '310';

select * from asr_process_run
where activitydate= '22-AUG-25'

update asr_process_run
set complete = 'R'
where order_number = '6972N78'
and complete = 'N';

select * from asr_process_run
where activitydate = '17-SEP-25'
and source = 'IL';
