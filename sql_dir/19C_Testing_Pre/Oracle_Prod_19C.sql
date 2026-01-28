select * from asr_process_run
where source = 'NC'
and  to_date(activitydate,'dd-MON-yy') > sysdate - 20;

update asr_process_run
set complete = 'N'
where order_number = '2730ZY7';

update asr_process_run
set complete = 'R'
where activitydate = '26-SEP-24'
and complete = 'N';

delete results_sent_log 
where order_number IN ( '2730ZY7');

SELECt * from results_sent_log
where order_number IN ( '2730ZY7','2826W27');

select * from asr_process_run
--where order_number IN ( '2701GS7','2826W27');
where order_number = '2730ZY7';