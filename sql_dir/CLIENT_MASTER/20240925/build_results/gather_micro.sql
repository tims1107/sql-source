

select * from 
(select order_test_code,order_test_name,MICRO_ORGANISM_NAME,REQUISITION_ID from micro_20240620_30
where regexp_like(result_test_name,'isolate','i')
and MICRO_ORGANISM_NAME IN
(select organismname from STATERPT_OWNER.MICRO_ORGANISM_FILTER)
and result_status = 'F'
group by order_test_code,order_test_name,MICRO_ORGANISM_NAME,REQUISITION_ID) r
join micro_organism_group g ON g.MICRO_ORGANISM_NAME = r.MICRO_ORGANISM_NAME
--and groupname = 'ID'
order by ORDER_TEST_CODE
;

select result_sequence, result_test_code, result_test_name,abnormal_flag from ih_dw.results
where requisition_id IN ('9212YZ6')
and abnormal_flag IN ('R','I')
order by result_sequence;

select m.requisition_id,lo.lab_order_pk,lod.specimen_method_code,lod.specimen_source_desc,m.MICRO_ORGANISM_NAME
,g.groupname from STATERPT_OWNER.PAT_MICRO_RESULTS p
join  micro_20240620_30 m ON m.requisition_id = p.requisition_id
join ih_dw.dim_lab_order lo ON lo.requisition_id = m.requisition_id
join ih_dw.dim_lab_order_details lod ON lod.lab_order_fk = lo.LAB_ORDER_PK
join micro_organism_filter f ON f.ORGANISMNAME = m.MICRO_ORGANISM_NAME
join micro_organism_group g ON g.MICRO_ORGANISM_NAME = m.MICRO_ORGANISM_NAME
--and groupname = 'ID'

where patient_account_state = 'NC'
and regexp_like(result_test_name, 'isolate','i')
and specimen_source_code is not null;

select lo.initiate_id,r.MICRO_ORGANISM_NAME,r.ACCESSION_NUMBER,r.order_test_code,r.order_test_name,r.result_test_code,r.result_test_name,r.abnormal_flag,r.TEXTUAL_RESULT_FULL,lod.specimen_method_code
,lod.specimen_source_desc
,lod.SPECIMEN_SOURCE_CODE
,specimen_container_code,specimen_container_desc from ih_dw.results r
join ih_dw.dim_lab_order lo ON lo.requisition_id = r.requisition_id
join ih_dw.dim_lab_order_details lod ON lod.lab_order_fk = lo.LAB_ORDER_PK
--where r.REQUISITION_ID IN
--(select REQUISITION_ID from IH_DW.DW_ODS_ACTIVITY
--where LAST_UPDATED_DATE > sysdate - 30)
where r.requisition_id = '11927X4'
--and regexp_like(r.result_test_name, 'isolate','i')
and lod.SPECIMEN_METHOD_CODE is not null;




select * from patientmaster_nc
--select * from patientmaster
where eid = '8001799981';

/
declare v_cre smallint := 0;

begin

for rec IN (select m.requisition_id,lo.lab_order_pk,lod.specimen_method_code,lod.specimen_source_desc,m.MICRO_ORGANISM_NAME
,g.groupname from STATERPT_OWNER.PAT_MICRO_RESULTS p
join  micro_20240620_30 m ON m.requisition_id = p.requisition_id
join ih_dw.dim_lab_order lo ON lo.requisition_id = m.requisition_id
join ih_dw.dim_lab_order_details lod ON lod.lab_order_fk = lo.LAB_ORDER_PK
join micro_organism_filter f ON f.ORGANISMNAME = m.MICRO_ORGANISM_NAME
join micro_organism_group g ON g.MICRO_ORGANISM_NAME = m.MICRO_ORGANISM_NAME
--and groupname = 'ID'

where patient_account_state = 'NC'
and regexp_like(result_test_name, 'isolate','i')
and specimen_source_code is not null)

loop

dbms_output.put_line(rec.requisition_id);

for cre_rec IN (select result_sequence, result_test_code, result_test_name,abnormal_flag from ih_dw.results
where requisition_id = rec.requisition_id
and abnormal_flag IN ('R','I')
and regexp_like(result_test_name,'PENEM','i')
order by result_sequence)
loop
  
  v_cre := v_cre + 1;
  
  if(v_cre > 1) then
  dbms_output.put_line(cre_rec.result_test_name);
  end if;
  
end loop;

v_cre := 0;

end loop;


end;

/

select * from generator
where CONVERSION_CONTEXT = 'NCHL7GeneratorContext';

update generator
set CONVERSION_CONTEXT = 'CAHL7GeneratorContext'
where generator_pk = 42;

