create index nuidex_eip_pat_req ON eip_pat_results (requisition_id);

delete eip_pat_results
where rowid IN
(select rid from 
(select rowid rid,requisition_id,row_number() over (partition by requisition_id,eid order by requisition_id,eid) rn from eip_pat_results)
where rn > 1)
;

select * from eip_pat_results;

select * from
(select decode(lab_fk,5,'East',7,'South','') performing_lab,e.order_test_code,order_test_name,result_test_code,result_test_name,result_status,e.REQUISITION_ID,micro_organism_name
,DBMS_LOB.SUBSTR(e.result_comment,4000,1) result_comment
,e.LAST_UPDATED_DATE,pat.patient_account_zip,c.county,pat.patient_account_state state from MICRO_RESULTS_EXTRACT e
    
		join eip_pat_results pat ON pat.requisition_id = e.requisition_id
    join dl_zip_code c ON c.zip = pat.patient_account_zip
		where pat.patient_account_state IN ('MN'
		,'CA'
		,'NM'
		,'TN'
		,'MD'
		,'GA'
		,'CO'
		,'NY'
		,'CT'
		,'OR')
    --and regexp_like(result_test_name,'isolate','i')
    
    --and result_comment is not null
    --and regexp_like(result_comment,'ESBL','i') ;
    and e.LAST_UPDATED_DATE > to_date('01-SEP-24','dd-MON-yy')
    and e.result_status = 'F')
    where result_comment is null
    --and pat.patient_account_state = 'NY' and not regexp_like(c.county,'Monroe','i')
    order by LAST_UPDATED_DATE;
    
    
    insert into eip_pat_results

with asr (requisition_id,result_test_code,result_test_name)
  as (select  requisition_id,result_test_code,result_test_name
      from micro_results_extract),
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