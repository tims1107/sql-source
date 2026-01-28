select * from
(select decode(lab_fk,5,'East',7,'South','') performing_lab,e.order_test_code,order_test_name,result_test_code,result_test_name,result_status,e.REQUISITION_ID,micro_organism_name
,DBMS_LOB.SUBSTR(e.result_comment,4000,1) result_comment
,e.LAST_UPDATED_DATE,pat.patient_account_zip,c.county,pat.patient_account_state state from MICRO_RESULTS_EXTRACT e
    
		join eip_pat_results pat ON pat.requisition_id = e.requisition_id
    join dl_zip_code c ON c.zip = pat.patient_account_zip
		--where e.LAST_UPDATED_DATE > to_date('01-SEP-24','dd-MON-yy')
    where e.result_status = 'F'
    and not regexp_like(result_test_name,'Culture Result')
    --and regexp_like(result_test_name,'isolate','i')
    ) results
    where regexp_like(micro_organism_name,'Acinetobacter','i')
    and state = 'NY'
    and regexp_like(result_test_name,'isolate','i');
    
    /

select * from
(select decode(lab_fk,5,'East',7,'South','') performing_lab,e.order_test_code,order_test_name,result_test_code,result_test_name,result_status,e.REQUISITION_ID,micro_organism_name
,DBMS_LOB.SUBSTR(e.result_comment,4000,1) result_comment
,e.LAST_UPDATED_DATE,pat.patient_account_zip,c.county,pat.patient_account_state state from MICRO_RESULTS_EXTRACT e
    
		join eip_pat_results pat ON pat.requisition_id = e.requisition_id
    join dl_zip_code c ON c.zip = pat.patient_account_zip
		--where e.LAST_UPDATED_DATE > to_date('01-SEP-24','dd-MON-yy')
    where e.result_status = 'F'
    and not regexp_like(result_test_name,'Culture Result')
    --and regexp_like(result_test_name,'isolate','i')
    ) results
    join 
(select * from condition_master
where state_fk IN (
select state_master_pk from state_master
where entity_type = 'EIP'
and state = 'MUGSI')) mssa ON mssa.condition_value = results.state;
--and requisition_id = '1263VY4';
where (regexp_like(results.micro_organism_name,
'^Methicillin Resistant Staphylococcus aureus|^Staphylococcus aureu|^Streptococcus pyogenes \(Beta Hemolytic Streptococci Group A\)','i')
or 
regexp_like(results.micro_organism_name,
'^Streptococcus agalactiae \(Beta Hemolytic Streptococci Group B\)|^Streptococcus pneumoniae|^Haemophilus influenzae|^Neisseria meningitidis','i'))
and 
not regexp_like(results.result_test_code,'^731$|^734$')

/
select state,micro_organism_name from
(select decode(lab_fk,5,'East',7,'South','') performing_lab,e.order_test_code,order_test_name,result_test_code,result_test_name,result_status,e.REQUISITION_ID,micro_organism_name
,DBMS_LOB.SUBSTR(e.result_comment,4000,1) result_comment
,e.LAST_UPDATED_DATE,pat.patient_account_zip,c.county,pat.patient_account_state state from MICRO_RESULTS_EXTRACT e
    
		join eip_pat_results pat ON pat.requisition_id = e.requisition_id
    join dl_zip_code c ON c.zip = pat.patient_account_zip)
where state = 'NY'
group by state,micro_organism_name
order by micro_organism_name;

where state IN
(select condition_value from condition_master
where state_fk IN (
select state_master_pk from state_master
where entity_type = 'EIP'
and state IN ( 'MSSA','MRSA','MUGSI','MSSA')))
group by state,micro_organism_name
order by state;
;