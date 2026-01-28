select rl.* from asr_process_run p
join 
(select * from results_sent_log
where regexp_like(result_source, 'Illinois')
and last_update_time > '28-MAY-25 02.45.47.369705000 AM') rl 
ON rl.order_number = p.order_number and rl.result_test_code = p.result_test_code;


update asr_process_run
set complete = 'N'
where order_number IN
(select rl.order_number from asr_process_run p
join 
(select * from results_sent_log
where regexp_like(result_source, 'Illinois')
and last_update_time > '28-MAY-25 02.45.47.369705000 AM') rl 
ON rl.order_number = p.order_number and rl.result_test_code = p.result_test_code)
and complete IN ('R','S');

delete results_sent_log
where order_number IN 
(select order_number from asr_process_run
where activitydate = '28-MAY-25'
and source = 'IL' and complete = 'N');