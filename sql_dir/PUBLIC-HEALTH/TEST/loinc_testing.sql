select order_number,result_test_code,textual_result_full,last_update_time,patient_account_state,loinc_code from results_sent_log
where patient_account_state = 'IL'
--and regexp_like(textual_result_full,'^Positive','i')
and regexp_like(loinc_code,'^(13954-3|31204-1|5195-3|5196-1)')
and regexp_like(order_test_name,'Hep Be Ag','i')
order by last_update_time desc;

select * from ih_dw.results r
join ih_dw.dim_lab_order lo ON lo.requisition_id = r.requisition_id
join patientmaster pm ON pm.eid = lo.initiate_id
where pm.state = 'IL'
and regexp_like(loinc_code,'^(13954-3|31204-1|5195-3|5196-1)')
and r.last_updated_date > sysdate -150
order by lo.last_updated_date desc