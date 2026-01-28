insert into micro_20240620_30
with act as (select requisition_id,last_updated_date from ih_dw.dw_ods_activity
),
res as (select * from ih_dw.results )
select res.* from res
join act ON act.requisition_id = res.requisition_id
where 
  act.LAST_UPDATED_DATE > '21-MAR-25 06.10.03.452950000 PM'
and res.test_category = 'MICRO'
and regexp_like(res.result_test_name,'isolate','i');

select * from micro_20240620_30
where regexp_like(order_test_name,'GC','i');

Gram Stain
Culture, Genital
Culture, GC (Gonorrhea)
Culture, Anaerobic
Culture, Fungus (Blood)

select result_sequence,result_test_name,micro_organism_name,abnormal_flag from ih_dw.results
where requisition_id = '0535H47'
and regexp_like(micro_organism_name,'^Enterobacter cloacae$','i')
and result_sequence > 2
order by result_sequence;


select max(LAST_UPDATED_DATE) from micro_20240620_30;
select min(LAST_UPDATED_DATE) from micro_20240620_30;

/

delete pat_micro_results;

select m.requisition_id,p.patient_last_name,p.patient_first_name,patient_account_address1,patient_account_city,patient_account_state,patient_account_zip,z.county,last_updated_date,m.micro_organism_name from micro_20240620_30 m
join pat_micro_results p ON p.requisition_id = m.requisition_id
join dl_zip_code z ON z.zip = p.patient_account_zip
--where rownum < 2;
where extract(year from last_updated_date) IN (2024,2025)
and patient_account_state = 'NY'
and regexp_like(micro_organism_name,'candida','i');

insert into pat_micro_results

with asr (requisition_id,result_test_code,result_test_name)
  as (select  requisition_id,result_test_code,result_test_name
      from micro_20240620_30),
pat as (select  v.* from vw_pat_results v
union all 
select  v.* from VW_STAFF_RESULTS v )



select 
distinct
asr.REQUISITION_ID,
EID,
COUNTY,
FACILITY_ID,
CID,
PATIENT_LAST_NAME,
PATIENT_FIRST_NAME,
PATIENT_MIDDLE_NAME,
DATE_OF_BIRTH,
GENDER,
PATIENT_SSN,
AGE,
PATIENT_ACCOUNT_ADDRESS1,
PATIENT_ACCOUNT_ADDRESS2,
PATIENT_ACCOUNT_CITY,
PATIENT_ACCOUNT_STATE,
PATIENT_ACCOUNT_ZIP,
PATIENT_HOME_PHONE,
FACILITY_ADDRESS1,
FACILITY_ADDRESS2,
FACILITY_CITY,
FACILITY_STATE,
FACILITY_ZIP,
FACILITY_PHONE,
EAST_WEST_FLAG,
INTERNAL_EXTERNAL_FLAG,
FACILITY_ACCOUNT_STATUS,
FACILITY_ACTIVE_FLAG,
CLINICAL_MANAGER,
MEDICAL_DIRECTOR,
ACTI_FACILITY_ID,
FMC_NUMBER,
PATIENT_RACE,
ETHNIC_GROUP,
FACILITY_NAME,
GENDER_IDENTITY,
SEX_ORIENT
from asr 
join pat ON pat.requisition_id = asr.requisition_id
;

delete pat_micro_results;

select * from micro_organism_group;


select * from pat_micro_results;

select MICRO_RESIST_CARBAPENEMS('75378J6','Enterobacter cloacae complex') from dual; 

select case when MICRO_RESIST_CARBAPENEMS('Enterobacter cloacae complex','8876W06') = 'reportable'
  then 1 else 0 end reports from dual;

/
-- CRE Rule

declare v_report smallint;

begin


delete doh_reported;

commit;

for rec IN (
select g.groupname
  ,r.patient_account_state
  ,m.requisition_id
  , m.order_test_code
  ,m.order_test_name
  ,m.result_test_code
  , m.result_test_name
  ,m.micro_organism_name
  ,m.LAST_UPDATED_DATE 
from 
  micro_20240620_30 m
join 
  pat_micro_results r ON r.requisition_id = m.requisition_id
join 
  micro_organism_filter f ON f.organismname = m.MICRO_ORGANISM_NAME
join 
  micro_organism_group g ON g.MICRO_ORGANISM_NAME = m.MICRO_ORGANISM_NAME
where regexp_like(m.result_test_name,'isolate','i')
and f.valuetype = 'ORG' 
--and patient_account_state IN ('NY','NJ','AL','TX')
order by r.patient_account_state,m.LAST_UPDATED_DATE desc)
loop

v_report := 0;

if(rec.groupname = 'ID') then
  v_report := 1;
else
select case when MICRO_RESIST_CARBAPENEMS(rec.micro_organism_name,rec.requisition_id) = 'reportable'
  then 1 else 0 end reports  into v_report from dual;
end if;



insert into doh_reported (order_number,condition,source,reportable,reporttype,createdat,completed) 
  values 
(rec.requisition_id,rec.micro_organism_name,rec.patient_account_state,v_report,rec.groupname,systimestamp,'N');
  
dbms_output.put_line(rec.patient_account_state || chr(9) || rec.requisition_id || chr(9) || v_report);

end loop;

end;

/

select g.groupname
  ,r.patient_account_state
  ,m.requisition_id
  , m.order_test_code
  ,m.order_test_name
  ,m.result_test_code
  , m.result_test_name
  ,m.micro_organism_name
  ,m.LAST_UPDATED_DATE 
from 
  micro_20240620_30 m
join 
  pat_micro_results r ON r.requisition_id = m.requisition_id
join 
  micro_organism_filter f ON f.organismname = m.MICRO_ORGANISM_NAME
join 
  micro_organism_group g ON g.MICRO_ORGANISM_NAME = m.MICRO_ORGANISM_NAME
where regexp_like(m.result_test_name,'isolate','i')
and f.valuetype = 'ORG'
--and m.micro_organism_name = 'Neisseria gonorrhoeae'
and patient_account_state IN ('IL')
order by r.patient_account_state,m.LAST_UPDATED_DATE desc;
/

select requisition_id,TEXTUAL_RESULT_FULL,abnormal_flag,VALUE_TYPE,order_test_code,result_test_code,LAST_UPDATED_DATE from ih_dw.results
where regexp_like(order_test_code,'305')
and LAST_UPDATED_DATE > sysdate - 30
;

select requisition_id,TEXTUAL_RESULT_FULL,abnormal_flag,VALUE_TYPE,order_test_code,order_test_name,result_test_code,result_test_name,LAST_UPDATED_DATE,MICRO_ORGANISM_NAME,result_test_name from ih_dw.results
where regexp_like(order_test_code,'305')
and LAST_UPDATED_DATE > sysdate - 300
;


select r.patient_account_state,m.requisition_id, m.result_test_name,m.micro_organism_name,m.LAST_UPDATED_DATE from micro_20240620_30 m;

create table micro_organism_group
as
select row_number() over (order by t1.micro_organism_name) groupid,t1.micro_organism_name,'CRE' groupname from
(select m.micro_organism_name from micro_20240620_30 m
join pat_micro_results r ON r.requisition_id = m.requisition_id
join micro_organism_filter f ON f.organismname = m.MICRO_ORGANISM_NAME
where regexp_like(m.result_test_name,'isolate','i')
and f.valuetype = 'ORG' --and patient_account_state IN ('NY','NJ','AL','TX')
group by micro_organism_name) t1;

select * from micro_organism_group;

update micro_organism_group
set groupname = 'ID'
where groupid IN (1,6,10,12,8,13,14);

select * from micro_organism_group;

select order_test_code,order_test_name from micro_20240620_30
group by order_test_code,order_test_name
order by order_test_name;

select * from 
(select order_test_code,order_test_name,MICRO_ORGANISM_NAME,REQUISITION_ID from micro_20240620_30
where regexp_like(result_test_name,'isolate','i')
and MICRO_ORGANISM_NAME IN
(select organismname from STATERPT_OWNER.MICRO_ORGANISM_FILTER)
and result_status = 'F'
group by order_test_code,order_test_name,MICRO_ORGANISM_NAME,REQUISITION_ID) r
join micro_organism_group g ON g.MICRO_ORGANISM_NAME = r.MICRO_ORGANISM_NAME
and groupname = 'ID'
order by ORDER_TEST_CODE
;








and f.valuetype = 'ORG' and patient_account_state IN ('NY','NJ','AL','TX');

drop table doh_reported;

create table doh_reported
(order_number varchar2(16)
,condition varchar2(256)
,source varchar2(2)
,reportable smallint
,reporttype varchar2(8)
,specimen_method_code
,
,createdat timestamp(6)
,completed varchar2(1));

select * from STATERPT_OWNER.DOH_REPORTED
where REPORTABLE = 1
order by source;

create table apply_rules
(rulename varchar2(64)
,ruleabbrev varchar2(8)
,createdat timestamp(6)
);

select min(LAST_UPDATED_DATE) from micro_20240620_30;

/

select order_test_code,order_test_name from micro_20240620_30
where regexp_like(micro_organism_name,'Vibrio','i')
group by order_test_code,order_test_name;


/

select * from doh_reported;

select * from snomed_master;

select  lo.initiate_id,m.ACCESSION_NUMBER,d.reporttype,d.source,m.order_test_code,m.order_test_name,m.result_test_code,m.result_test_name,m.abnormal_flag,m.TEXTUAL_RESULT_FULL,lod.specimen_method_code
,lod.specimen_source_desc
,lod.SPECIMEN_SOURCE_CODE
,specimen_container_code,specimen_container_desc from micro_20240620_30 a
join ih_dw.results m ON m.REQUISITION_ID = a.REQUISITION_ID
join ih_dw.dim_lab_order lo ON lo.requisition_id = m.requisition_id
join ih_dw.dim_lab_order_details lod ON lod.lab_order_fk = lo.LAB_ORDER_PK
left outer join DOH_REPORTED d ON d.order_number = m.requisition_id
--where d.source = 'NC' and d.reportable = 1
--where m.REQUISITION_ID = '1445H77'
where regexp_like(m.result_test_name, 'isolate','i')
--where regexp_like(m.accession_number, '^65','i')
and m.requisition_id = '11928K4'
and specimen_method_code is not null
order by m.accession_number,m.result_test_code,m.result_sequence ;

select initiate_id,r.lab_fk,lo.* from ih_dw.results r
join ih_dw.dim_lab_order lo ON lo.requisition_id = r.requisition_id
where r.requisition_id = '2161CA7';

select * from patientmaster
where eid = '8003294873';

select * from ih_dw.dim_patient
where facility_id = 'A121691'
and last_name = 'DAYE';

select * from micro_organism_filter;

select requisition_id,MICRO_ORGANISM_NAME,
(case when regexp_like(r.result_test_name,'isolate','i') 
  then 'ISOLATE' 
  else 'DRUG' END) fld,
  
  
  LAST_UPDATED_DATE from ih_dw.results r

where requisition_id = '11927B4'
--and regexp_like(result_test_name,'isolate','i')
and result_status = 'F'
and r.MICRO_ORGANISM_NAME is not null;

select * from doh_reported;

select r.MICRO_ORGANISM_NAME,r.ACCESSION_NUMBER,r.order_test_code,r.order_test_name,r.result_test_code,r.result_test_name,r.abnormal_flag,r.TEXTUAL_RESULT_FULL,lod.specimen_method_code
,lod.specimen_source_desc
,lod.SPECIMEN_SOURCE_CODE
,specimen_container_code,specimen_container_desc from ih_dw.results r
join ih_dw.dim_lab_order lo ON lo.requisition_id = r.requisition_id
join ih_dw.dim_lab_order_details lod ON lod.lab_order_fk = lo.LAB_ORDER_PK
--where r.REQUISITION_ID IN
--(select REQUISITION_ID from IH_DW.DW_ODS_ACTIVITY
--where LAST_UPDATED_DATE > sysdate - 30)
where r.requisition_id = '0524NNS'
and regexp_like(r.result_test_name, 'isolate','i')
and lod.SPECIMEN_METHOD_CODE is not null;

select * from ih_dw.results
where REQUISITION_ID = '0524NNS';

select * from snomed_master;

select * from asr_process_run
where complete = 'N'
order by activitydate;

update asr_process_run
set complete = 'N'
--where complete = 'N';
where order_number = '11928A4';



