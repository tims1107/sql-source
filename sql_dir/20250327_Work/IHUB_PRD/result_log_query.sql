select patient_account_state,result_test_code,performing_lab_id,count(1) from results_sent_log
where last_update_time > sysdate - .5
group by patient_account_state,result_test_code,performing_lab_id
order by patient_account_state,performing_lab_id,result_test_code;