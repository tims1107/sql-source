select * from asr_process_run
where order_number IN
('76092G8','8001VT8','7854WF8','77521Z8','7883K18','7487NG8','7706YJ8','7443SB8','7858NU8','7699JT8','7605P78','7770V98',
'78563U8','7500NJ8','7861B38','7998KB8','78730N8','7784NK8','77314M8','77320G8','7820UB8','7784NC8','8005AT8','80753Z8',
'77314R8','81321C8','8121C88','80764C8','82627P8','8210AF8','82613H8','8258RA8','7699KT8','8143RB8','8143F08')
and complete in ('R','S');

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

create table asr_process_run_20250929_resend
as
select * from asr_process_run
where order_number IN
('76092G8','8001VT8','7854WF8','77521Z8','7883K18','7487NG8','7706YJ8','7443SB8','7858NU8','7699JT8','7605P78','7770V98',
'78563U8','7500NJ8','7861B38','7998KB8','78730N8','7784NK8','77314M8','77320G8','7820UB8','7784NC8','8005AT8','80753Z8',
'77314R8','81321C8','8121C88','80764C8','82627P8','8210AF8','82613H8','8258RA8','7699KT8','8143RB8','8143F08')
and complete in ('R','S');

select * from asr_process_run_20250929_resend;

update asr_process_run
set complete = 'S'
where (order_number,result_test_code) IN
(select order_number,result_test_code from asr_process_run_20250929_resend
where complete IN ('S'));

select * from asr_process_run
where complete = 'N'
order by activitydate;

delete results_sent_log
where order_number = '8493PV8';

delete results_sent_log
where (order_number,result_test_code) IN
(select order_number,result_test_code from results_sent_log_20250929_resend);