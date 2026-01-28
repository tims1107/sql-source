select * from asr_process_run
where activitydate = '30-SEP-25'
and source = 'NY'
and order_number = '2817H64';


create table results_sent_log_20250929_resend
as
select * from results_sent_log
where (order_number,result_test_code)
IN 
(select order_number,result_test_code from asr_process_run
where order_number IN
('76092G8','8001VT8','7854WF8','77521Z8','7883K18','7487NG8','7706YJ8','7443SB8','7858NU8','7699JT8','7605P78','7770V98',
'78563U8','7500NJ8','7861B38','7998KB8','78730N8','7784NK8','77314M8','77320G8','7820UB8','7784NC8','8005AT8','80753Z8',
'77314R8','81321C8','8121C88','80764C8','82627P8','8210AF8','82613H8','8258RA8','7699KT8','8143RB8','8143F08')
and complete in ('R','S'));

create table asr_process_run_NY_2817H64
as
select * from asr_process_run
where order_number IN
('2817H64')
and complete in ('R','S');

select * from asr_process_run_NY_2817H64;

update asr_process_run
set complete = 'N'
where (order_number,result_test_code) IN
(select order_number,result_test_code from asr_process_run_NY_2817H64);

select * from asr_process_run
where complete = 'N'
order by activitydate;

update asr_process_run  
set complete = 'R'
where complete = 'N';


delete results_sent_log
where (order_number,result_test_code) IN
(select order_number,result_test_code from asr_process_run_NY_2817H64);

select * from generator
where state_fk IN
(
select state_master_pk from state_master
where state_abbreviation = 'NY');