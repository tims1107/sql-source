select order_number,order_test_code,result_test_code,loinc_code,last_update_time from results_sent_log
where loinc_code = '42595-9'
and last_update_time > TO_TIMESTAMP('08-JUN-24 12.00.00.000000000 AM', 'DD-MON-RR HH.MI.SS.FF9 PM')
order by last_update_time desc,order_number;

