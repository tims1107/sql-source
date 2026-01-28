select source,result_test_code,complete,count(1) from asr_process_run
where activitydate='14-AUG-25'
and complete IN ('L','F')
and source like 'NY'
group by source,result_test_code,complete
order by source,result_test_code;

select * from ih_dw.dw_ods_activity
where rownum < 5
order by last_updated_date desc;

select source,a.order_number,a.result_test_code,a.textual_result_full,complete,substr(result_comment,1,50) comments from asr_process_run a
join ih_dw.results r ON r.requisition_id = a.order_number and r.result_test_code = a.result_test_code
--where source = 'NY'
where activitydate = '14-AUG-25'
--and source NOT IN ('IL')
--and complete = 'L'
and complete IN ('R','S','Q','A','D')
--and r.result_test_code NOT IN ('111')
order by source,a.order_number;
--and regexp_like(r.textual_result_full,'Positive','i');

create table asr_process_run_20250816_RSQ
as
select * from asr_process_run
where activitydate = '16-AUG-25'
and complete = 'L';

select * from asr_process_run_20250814_LF
where activitydate='14-AUG-25'
and complete='L';

select result_test_code,source,complete,count(1) from asr_process_run_20250814_LF
where activitydate='14-AUG-25'
and order_test_code = '318'
group by result_test_code,source,complete
order by complete,result_test_code,source;
;

insert into asr_process_run_20250814_LF
select * from asr_process_run_20250815_RSQ
where order_test_code = '311'

select * from asr_process_run_20250814_RSQ
where activitydate='14-AUG-25'
and complete IN ('R','S');

select * from asr_process_run_2025081_LF



select * from asr_process_run
where complete IN ('F','L');
where activitydate = '15-AUG-25';

select * from asr_process_run_20250814_RSQ
where source = 'TX'
order by order_number,result_test_code;

select source,result_test_code,count(1) from asr_process_run_20250814_LF
where not regexp_like (result_test_code,'^P')
and complete='L'
and result_test_code='332'
group by source,result_test_code
order by source,result_test_code;

select source,result_test_code,textual_result_full from asr_process_run_20250814_LF
where not regexp_like (result_test_code,'^P')
and complete='L'
and result_test_code='332';

select source,result_test_code,textual_result_full from asr_process_run_20250814_LF
where not regexp_like (result_test_code,'^P')
and complete='L'
and regexp_like(order_test_code,'^(315|317L|322|323|327)$');


select * from report_results
where source ='NY'
and result_test_code not in ('111');

select * from asr_process_run_20250814_LF
where complete = 'L'
and source = 'NY'
and result_test_code NOT IN ('111')
order by order_number,result_test_code;
and result_test_code in ('336');

select * from asr_process_run_20250814_RSQ
where result_test_code = '336';
update asr_process_run
set complete = 'Q'
where complete IN ('F');



select * from asr_process_run
where activitydate='14-AUG-25'
and source='NC'
and result_test_code IN ('315','317L','322','323','327');

update asr_process_run
set complete='Q'
where activitydate='14-AUG-25'
and source='NC'
and result_test_code IN ('315','317L','322','323','327');

delete asr_process_run
where activitydate='16-AUG-25'
and complete = 'L';