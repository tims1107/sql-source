
-- NY 336 HIV Monthly Report
select order_number,last_update_time,result_test_code,result_test_name,textual_result_full from results_sent_log r

where result_source = 'New York NYHL7GeneratorContext'
and last_update_time > '01-JAN-25 01.01.12.185418000 AM'
and result_test_code = '336'
order by last_update_time;