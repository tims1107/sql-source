select * from results_sent_log
where patient_account_state = 'PA'
and result_test_code IN ('301','310')
and LAST_UPDATE_TIME > sysdate - 10;

select * from asr_process_run
where ORDER_NUMBER = '11539B7';

update asr_process_run
set complete = 'N'
where ORDER_NUMBER = '11539B7';

delete results_sent_log
where ORDER_NUMBER = '11539B7';

select  r.result_test_code,lo.*,order_test_name from ih_dw.results r
join vw_pat_results lo ON lo.requisition_id = r.requisition_id
where r.requisition_id = '1ER4ZT7'
and r.result_test_code = '525';

select * from vw_pat_results
where REQUISITION_ID = 'MD05101';


select order_test_code,order_test_name,result_test_code,result_test_name from results_sent_log
where regexp_like(order_test_code,'^3|^7')
and regexp_like(result_test_name,'isolate','i')
group by order_test_code,order_test_name,result_test_code,result_test_name
order by order_test_code;

/

  CREATE OR REPLACE FORCE VIEW "STATERPT_OWNER"."VW_PAT_RESULTS" ("RESULT_TEST_CODE", "REQUISITION_ID", "EID", "COUNTY", "FACILITY_ID", "CID", "PATIENT_LAST_NAME", "PATIENT_FIRST_NAME", "PATIENT_MIDDLE_NAME", "DATE_OF_BIRTH", "GENDER", "PATIENT_SSN", "AGE", "PATIENT_ACCOUNT_ADDRESS1", "PATIENT_ACCOUNT_ADDRESS2", "PATIENT_ACCOUNT_CITY", "PATIENT_ACCOUNT_STATE", "PATIENT_ACCOUNT_ZIP", "PATIENT_HOME_PHONE", "FACILITY_ADDRESS1", "FACILITY_ADDRESS2", "FACILITY_CITY", "FACILITY_STATE", "FACILITY_ZIP", "FACILITY_PHONE", "EAST_WEST_FLAG", "INTERNAL_EXTERNAL_FLAG", "FACILITY_ACCOUNT_STATUS", "FACILITY_ACTIVE_FLAG", "CLINICAL_MANAGER", "MEDICAL_DIRECTOR", "ACTI_FACILITY_ID", "FMC_NUMBER", "PATIENT_RACE", "ETHNIC_GROUP", "SEX_ORIENT", "GENDER_IDENTITY", "FACILITY_NAME") AS 
  select r.result_test_code,r.requisition_id,pm.EID,zc.county,f.FACILITY_ID,a.cid, 
                    nvl(pm.lname, '') PATIENT_LAST_NAME, 
                    nvl(pm.fname, '') PATIENT_FIRST_NAME, 
                   
                    CASE 
                    WHEN pm.mname is null THEN null 
                    WHEN upper(pm.mname) = 'NULL' THEN null 
                    ELSE pm.mname 
                    END 
                    PATIENT_MIDDLE_NAME,           
                    
                    
                    CASE 
                    WHEN pm.DOB is null THEN null 
                    WHEN test_date(pm.DOB) = 'Valid' THEN 
                    
                    CASE  
                    WHEN (EXTRACT(YEAR FROM sysdate) - to_number(SUBSTR(replace(pm.DOB, '-'), 1, 4))) <= 0 THEN NULL  
                    ELSE to_date(pm.DOB, 'YYYY-MM-DD') 
                    END 
                  
                    ELSE NULL	 
                    END 
                    date_of_birth,         
                    pm.sex gender, 
                    pm.ssn patient_ssn,
                  
                    CASE 
                    WHEN pm.DOB is null THEN 0 
                    WHEN test_date(pm.DOB) = 'Valid' THEN 
                    
                    CASE  
                    WHEN (EXTRACT(YEAR FROM sysdate) - to_number(SUBSTR(replace(pm.DOB, '-'), 1, 4))) <= 0 THEN 0  
                    ELSE trunc(months_between(sysdate, to_date(pm.DOB, 'YYYY-MM-DD'))/12) 
                    END 
                    
                    ELSE NULL	 
                    END 
                    age, 
                    pm.stline1 patient_account_address1, 
                    pm.stline2 patient_account_address2, 
                    pm.CITY patient_account_city, 
                    pm.STATE patient_account_state, 
                    pm.zipcode patient_account_zip, 
                    
                    CASE 
                    WHEN pm.phnumber is null THEN null 
                    WHEN length(pm.phnumber) > 10 THEN substr(pm.phnumber, ((length(pm.phnumber) - 10) + 1)) 
                    ELSE pm.phnumber 
                    END 
                    patient_home_phone,
                    f.ADDRESS_LINE1 facility_address1, 
                    f.ADDRESS_LINE2 facility_address2,
                    f.CITY facility_city, 
                    f.STATE facility_state,
                    f.ZIP facility_zip, 
                    f.PHONE_NUMBER facility_phone, 
                    f.EAST_WEST_FLAG,
                    f.INTERNAL_EXTERNAL_FLAG, 
                    f.ACCOUNT_STATUS facility_account_status,
                    f.FACILITY_ACTIVE_FLAG, 
                    f.CLINICAL_MANAGER, 
                    dl.MEDICAL_DIRECTOR, 
                    f.FACILITY_ID acti_facility_id,
                    f.FMC_NUMBER, 
                    
                    
                    CASE
                    WHEN  dp.race is null THEN 'UNKNOWN' 
                    ELSE dp.race 
                    END 
                    patient_race,
                    
                    CASE
                    WHEN  dp.ethnicity is null THEN 'UNKNOWN' 
                    ELSE dp.ethnicity 
                    END 
                    ethnic_group, 
                    sex_orient,
                    gender_identity,
                    f.Display_Name facility_name 
                    from ih_dw.results r
join IH_DW.DIM_LAB_ORDER lo   ON lo.requisition_id =r.requisition_id
--join ih_dw.results r ON r.LAB_ORDER_FK = lo.LAB_ORDER_PK and lo.REQUISITION_ID = r.REQUISITION_ID 
                    join IH_DW.dim_account a ON a.ACCOUNT_PK = lo.ACCOUNT_FK
                    join IH_DW.SPECTRA_MRN_ASSOCIATIONS asso ON asso.SPECTRA_MRN_ASSC_PK = lo.SPECTRA_MRN_ASSC_FK  
                    join IH_DW.DIM_FACILITY f ON f.FACILITY_PK = a.FACILITY_FK 
                    left outer join patientmaster pm ON pm.eid = lo.INITIATE_ID
                    left outer join STATERPT_OWNER.DL_ZIP_CODE zc ON zc.ZIP = pm.ZIPCODE 
                    join IH_DW.DIM_PATIENT dp ON dp.spectra_mrn_fk = asso.spectra_mrn_fk
                    and pm.lab_fk = r.lab_fk  and dp.FACILITY_FK = asso.FACILITY_fK 
                    join IH_DW.DIM_LAB dl on dl.LAB_PK = lo.LAB_FK;


