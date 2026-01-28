
  CREATE OR REPLACE VIEW "STATERPT_OWNER"."VW_RESULTS_PATIENT_STAFF" ("RESULT_TEST_CODE", "TEST_CATEGORY", "PATIENT_PK", "FIRST_NAME", "LAST_NAME", "RACE", "ETHNICITY", "STATE", "DOB", "SOURCE_TYPE", "REQUISITION_ID", "RESULT_STATUS", "LAST_UPDATED_DATE", "PERFORMING_LAB", "TEXTUAL_RESULT_FULL", "RESULT_COMMENT", "ORDER_TEST_CODE", "INITIATE_ID","LAB_FK") AS 
  SELECT 
    re.result_test_code,
    lod.test_category,
    COALESCE(dp.patient_pk, ds.staff_pk) as patient_pk,
    COALESCE(dp.first_name, ds.first_name) as first_name,
    COALESCE(dp.last_name, ds.last_name) as last_name,
    COALESCE(dp.race, ds.race) as race,
    COALESCE(dp.ethnicity, ds.ethnicity) as ethnicity,
    pm.state,
    COALESCE(dp.dob, ds.dob) as dob,
    CASE WHEN dp.patient_pk IS NOT NULL THEN 'PATIENT' ELSE 'STAFF' END as source_type,
    lo.requisition_id,
    re.result_status,
    re.last_updated_date,
    re.performing_lab,
    re.textual_result_full,
    re.result_comment,
    re.order_test_code,
    lo.initiate_id,
    re.lab_fk
        
    
FROM ih_dw.results re 
JOIN ih_dw.dim_lab_order lo ON lo.requisition_id = re.requisition_id 
    AND re.LAB_ORDER_FK = lo.LAB_ORDER_PK
JOIN ih_dw.dim_lab_order_details lod ON lod.lab_order_fk = lo.lab_order_pk 
    AND re.LAB_ORDER_DETAILS_FK = lod.LAB_ORDER_DETAILS_PK
JOIN IH_DW.SPECTRA_MRN_ASSOCIATIONS asso ON lo.SPECTRA_MRN_ASSC_FK = asso.SPECTRA_MRN_ASSC_pk
JOIN patientmaster pm ON pm.eid = lo.initiate_id and pm.lab_fk = re.lab_fk
LEFT JOIN ih_dw.dim_patient dp ON dp.SPECTRA_MRN_FK = asso.SPECTRA_MRN_fK 
    AND dp.FACILITY_FK = asso.FACILITY_fK
LEFT JOIN ih_dw.dim_staff ds ON ds.SPECTRA_MRN_FK = asso.SPECTRA_MRN_fK 
    AND ds.FACILITY_FK = asso.FACILITY_fK
    AND dp.patient_pk IS NULL;

/

 SELECT 
    re.result_test_code,
    lod.test_category,
    COALESCE(dp.patient_pk, ds.staff_pk) as patient_pk,
    COALESCE(dp.first_name, ds.first_name) as first_name,
    COALESCE(dp.last_name, ds.last_name) as last_name,
    COALESCE(dp.race, ds.race) as race,
    COALESCE(dp.ethnicity, ds.ethnicity) as ethnicity,
    pm.state,
    COALESCE(dp.dob, ds.dob) as dob,
    CASE WHEN dp.patient_pk IS NOT NULL THEN 'PATIENT' ELSE 'STAFF' END as source_type,
    lo.requisition_id,
    re.result_status,
    re.last_updated_date,
    re.performing_lab,
    re.textual_result_full,
    re.result_comment,
    re.order_test_code,
    lo.initiate_id,
    re.lab_fk
        
    
FROM ih_dw.results re 
JOIN ih_dw.dim_lab_order lo ON lo.requisition_id = re.requisition_id 
    AND re.LAB_ORDER_FK = lo.LAB_ORDER_PK
JOIN ih_dw.dim_lab_order_details lod ON lod.lab_order_fk = lo.lab_order_pk 
    AND re.LAB_ORDER_DETAILS_FK = lod.LAB_ORDER_DETAILS_PK
JOIN IH_DW.SPECTRA_MRN_ASSOCIATIONS asso ON lo.SPECTRA_MRN_ASSC_FK = asso.SPECTRA_MRN_ASSC_pk
JOIN patientmaster pm ON pm.eid = lo.initiate_id and pm.lab_fk = re.lab_fk
LEFT JOIN ih_dw.dim_patient dp ON dp.SPECTRA_MRN_FK = asso.SPECTRA_MRN_fK 
    AND dp.FACILITY_FK = asso.FACILITY_fK
LEFT JOIN ih_dw.dim_staff ds ON ds.SPECTRA_MRN_FK = asso.SPECTRA_MRN_fK 
    AND ds.FACILITY_FK = asso.FACILITY_fK
    AND dp.patient_pk IS NULL
where re.last_updated_date > sysdate -1;

select count(1) from VW_RESULTS_PATIENT_STAFF
where last_updated_date > sysdate -1;

