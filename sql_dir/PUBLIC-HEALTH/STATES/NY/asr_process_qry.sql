select * from asr_process_run
where source = 'NY'
and result_test_code = '336'
and complete = 'R';

select r.requisition_id,eid,result_test_code,textual_result_full,result_comment,r.last_updated_date,pm.lname from ih_dw.results r
join ih_dw.dim_lab_order lo ON lo.requisition_id = r.requisition_id
full outer join patientmaster pm ON pm.eid = lo.initiate_id
where r.last_updated_date > sysdate -1.1
and regexp_like(result_test_code,'^(310A|310)$')
and result_status = 'F'
--and regexp_like(textual_result_full,'^(positive|>11)$','i')
and r.lab_fk = pm.lab_fk
and state = 'NJ'
order by r.requisition_id 
;

select result_test_code,count(1) from results_sent_log
where to_char(collection_date,'YY') = '24'
and patient_account_state = 'NY'
group by result_test_code
order by result_test_code;
and result_test_code = '319N';

select * from asr_process_run
where order_number IN
('2058G98'
,'1906VF8'
,'2058C28');

select * from condition_master 
where state_fk IN
(select state_master_pk

select eid from patientmaster
where state = 'NJ'
order by table_updated desc;