declare v_out number;

begin

  SP_ASR_EIP_RESULTS_EXTRACT(11,2025,v_out);
  
  
end;

/

select pm.state,e.* from micro_results_extract e
join ih_dw.dim_lab_order lo ON lo.requisition_id = e.requisition_id
join patientmaster pm ON pm.eid = lo.initiate_id and e.lab_fk = pm.lab_fk
where regexp_like(micro_organism_name,'Streptococcus agalactiae')
and regexp_like(pm.state,'^(CA|CO|CT|GA|MD|MN|NM|NY|OR|TN)$')
order by state;
and pm.state = 'GA';
group by requisition_id,micro_organism_name
order by micro_organism_name;
where requisition_id = '4444MV8';

select * from micro_organism_filter;

select * from micro_identified;

select * from snomed_master;

select * from micro_organism_group;

select e.* from micro_organism_filter e
where valuetype = 'ORG';
join micro_identified i ON i.organism_name = e.organismname;
where cre IN ('N','Y');

select requisition_id,micro_organism_name,result_test_code,result_test_name,i.cre from micro_results_extract e
join micro_identified i ON i.organism_name = e.micro_organism_name
where cre IN ('N','Y')
and regexp_like(result_test_name,'Isolate #','i')
order by micro_organism_name,requisition_id;

select e.requisition_id,e.last_updated_date,e.release_date_time,pm.*,zc.county,e.result_test_name,mi.* from micro_results_extract e
join ih_dw.dim_lab_order lo ON lo.requisition_id = e.requisition_id
join patientmaster pm ON pm.eid = lo.initiate_id and pm.lab_fk = e.lab_fk
join dl_zip_code zc ON zc.zip = pm.zipcode
join micro_identified mi ON mi.organism_name = e.micro_organism_name
where regexp_like(result_test_name,'Isolate #','i')
and regexp_like(pm.state,'^(CA|CO|CT|GA|MD|MN|NM|NY|OR|TN)$')
and result_status = 'F'
--and cre = 'N'
--and e.requisition_id IN ('33374R8','4003Z18')
order by e.micro_organism_name;

select * from micro_results_extract;

delete micro_results_extract
--select last_updated_date,release_date_time,result_test_code,result_test_name,micro_organism from micro_results_extract
where requisition_id IN ('33374R8',
'4003Z18');

select * from micro_results_extract;

select sm.state_abbreviation,cm.state_fk,cm.condition,cm.condition_value,cf.filter,cm.status from condition_master cm
join state_master sm ON sm.state_master_pk = cm.state_fk
join condition_filters cf ON cf.condition_filter_pk = cm.condition_filter_fk
where state_abbreviation IN ('MUGSI','ABC','MRSA','MSSA','CDIFF')
and cm.condition IN ('State In')
order by state_abbreviation,condition_value;

where requisition_id = '4444MV8';