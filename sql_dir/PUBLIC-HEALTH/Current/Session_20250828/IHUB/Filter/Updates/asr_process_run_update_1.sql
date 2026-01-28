select * from processed_files
order by processed_date desc;

select * from file_dist_log
where created_at > trunc(sysdate)
order by created_at desc;

select source ,complete,count(1)from asr_process_run
where activitydate = '22-AUG-25'
and complete IN ('L')
group by source,complete
order by source;

select a.order_number,b.order_number,a.order_test_code,a.result_test_code,a.textual_result_full,complete from asr_process_run a 
full outer join results_sent_log_20250822 b ON b.order_number = a.order_number and b.result_test_code = a.result_test_code
where a.activitydate='22-AUG-25'
and a.source = 'IL'
--and a.order_number = '26937R4'
and complete = 'L'
order by a.order_test_code;

select * from asr_process_run
where activitydate = '26-AUG-25'
order by source;
and ;

select order_test_code,result_test_code,textual_result_full,value_type from ih_dw.results
where requisition_id = '26937R4'
and regexp_like(result_test_code,'^(315|317L|322|323|327)$');

update asr_process_run
set complete = 'N'
where source NOT IN ( 'AL')
and activitydate = '26-AUG-25'
--and activitydate = '26-AUG-25'
and complete = 'N';

update asr_process_run
set complete = 'N'
where activitydate = '26-AUG-25';
--and activitydate = '26-AUG-25'
and complete = 'N';

select * from asr_process_run
where activitydate='26-AUG-25'
and result_test_code IN ('310')
and textual_result_full = 'Nonreactive'
order by source;

create table asr_process_run_20250826_LF
as
select * from asr_process_run
where activitydate = '26-AUG-25';

select * from asr_process_run_20250826_LF;

delete asr_process_run
where activitydate = '26-AUG-25';



select * from asr_process_run_20250822_rsq
where complete = 'R'
and result_test_code IN ('310','310A');

select a.order_number,b.order_number,a.order_test_code,a.result_test_code,a.textual_result_full,complete,value_type from asr_process_run a 
full outer join results_sent_log_20250822 b ON b.order_number = a.order_number and b.result_test_code = a.result_test_code
where a.activitydate = '22-AUG-25'
--and a.complete = 'L'
and regexp_like(a.result_test_code,'^(315|317L|322|323|327)$')
and source = 'IL'
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
