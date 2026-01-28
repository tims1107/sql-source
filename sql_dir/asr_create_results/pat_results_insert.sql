-- pat_results_insert
insert into pat_results

with asr (order_number,activitydate ,result_test_code,complete,source)
  as (select order_number,activitydate ,result_test_code,complete,source
      from asr_process_run),
pat as (select  v.* from vw_pat_results v
union all 
select  v.* from VW_STAFF_RESULTS v )

select 
REQUISITION_ID,
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
join pat ON pat.requisition_id = asr.order_number
--left join vw_staff_results sr ON sr.requisition_id = asr.order_number

where complete IN ('R','S') and activitydate = to_char(sysdate - 1 ,'dd-MON-yy')
and pat.result_test_code = asr.result_test_code;

commit;

select * from pat_results;

delete pat_results;

/

select p.staff_pk,race,ethnicity,GENDER_IDENTITY,SEX_ORIENT from ih_dw.dim_STAff p
where staff_pk IN (113103);
