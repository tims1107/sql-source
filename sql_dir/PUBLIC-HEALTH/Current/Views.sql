CREATE OR REPLACE VIEW VW_ACTIVITY_RESULTS_SUMMARY AS
SELECT 
    a.requisition_id,
    r.last_updated_date,
    r.order_test_code,
    r.order_test_name,
    r.result_test_code,
    r.result_test_name,
    1 as result_count  -- Each row represents one result record
FROM IH_DW.DW_ODS_ACTIVITY a
INNER JOIN IH_DW.RESULTS r ON a.requisition_id = r.requisition_id
INNER 
where result_status = 'F';

/
select * from 
(SELECT 
    
    re.result_test_code,
    lod.test_category,
    COALESCE(dp.patient_pk, ds.staff_pk) as patient_pk,
    COALESCE(dp.first_name, ds.first_name) as first_name,
    COALESCE(dp.last_name, ds.last_name) as last_name,
    COALESCE(dp.race, ds.race) as race,
    COALESCE(dp.ethnicity, ds.ethnicity) as ethnicity,
    COALESCE(dp.state, 'N/A') as state,
    COALESCE(dp.dob, ds.dob) as dob,
    -- Add other fields you need
    CASE WHEN dp.patient_pk IS NOT NULL THEN 'PATIENT' ELSE 'STAFF' END as source_type
    ,lo.requisition_id
    ,re.result_status
    ,re.last_updated_date
    ,re.performing_lab
    ,re.textual_result_full
FROM ih_dw.results re 
join ih_dw.dim_lab_order lo ON lo.requisition_id = re.requisition_id and re.LAB_ORDER_FK = lo.LAB_ORDER_PK
JOIN ih_dw.dim_lab_order_details lod ON lod.lab_order_fk = lo.lab_order_pk and re.LAB_ORDER_DETAILS_FK = lod.LAB_ORDER_DETAILS_PK
JOIN IH_DW.SPECTRA_MRN_ASSOCIATIONS asso ON lo.SPECTRA_MRN_ASSC_FK = asso.SPECTRA_MRN_ASSC_pk
LEFT JOIN ih_dw.dim_patient dp ON dp.SPECTRA_MRN_FK = asso.SPECTRA_MRN_fK 
                                AND dp.FACILITY_FK = asso.FACILITY_fK
LEFT JOIN ih_dw.dim_staff ds ON ds.SPECTRA_MRN_FK = asso.SPECTRA_MRN_fK 
                              AND ds.FACILITY_FK = asso.FACILITY_fK
                              AND dp.patient_pk IS NULL  -- Only join staff when patient not found
)

--where test_category IN ('IMMUNO')
where last_updated_date > trunc(sysdate -2)
and result_test_code IN ('310','310A')
and result_status = 'F'

--group by result_test_code,state
order by state;

select * from asr_process_run;

/

select * from 
(SELECT 
    
    re.result_test_code,
    lod.test_category,
    COALESCE(dp.patient_pk, ds.staff_pk) as patient_pk,
    COALESCE(dp.first_name, ds.first_name) as first_name,
    COALESCE(dp.last_name, ds.last_name) as last_name,
    COALESCE(dp.state, 'N/A') as state,
    COALESCE(dp.dob, ds.dob) as dob,
    -- Add other fields you need
    CASE WHEN dp.patient_pk IS NOT NULL THEN 'PATIENT' ELSE 'STAFF' END as source_type
    ,lo.requisition_id
    ,re.result_status
FROM ih_dw.results re 
join ih_dw.dim_lab_order lo ON lo.requisition_id = re.requisition_id and re.LAB_ORDER_FK = lo.LAB_ORDER_PK
JOIN ih_dw.dim_lab_order_details lod ON lod.lab_order_fk = lo.lab_order_pk and re.LAB_ORDER_DETAILS_FK = lod.LAB_ORDER_DETAILS_PK
JOIN IH_DW.SPECTRA_MRN_ASSOCIATIONS asso ON lo.SPECTRA_MRN_ASSC_FK = asso.SPECTRA_MRN_ASSC_pk
LEFT JOIN ih_dw.dim_patient dp ON dp.SPECTRA_MRN_FK = asso.SPECTRA_MRN_fK 
                                AND dp.FACILITY_FK = asso.FACILITY_fK
LEFT JOIN ih_dw.dim_staff ds ON ds.SPECTRA_MRN_FK = asso.SPECTRA_MRN_fK 
                              AND ds.FACILITY_FK = asso.FACILITY_fK
                              AND dp.patient_pk IS NULL  -- Only join staff when patient not found
--where lod.test_category IN ('IMMUNO')
where re.last_updated_date > trunc(sysdate -2)
and re.result_test_code IN ('310','310A'))
where state = 'CA'
order by state;

select order_test_code,result_test_code,result_status,count(1) from ih_dw.results
--where requisition_id = '64017M8'
where order_test_code = '310'
and last_updated_date > trunc(sysdate -2)
group by order_test_code,result_test_code,result_status;
and result_status = 'P';

/
 
order by lo.last_updated_date desc;

SELECT 
    COALESCE(dp.patient_pk, ds.staff_pk) as patient_pk,
    COALESCE(dp.first_name, ds.first_name) as first_name,
    COALESCE(dp.last_name, ds.last_name) as last_name,
    --COALESCE(dp.date_of_birth, ds.date_of_birth) as date_of_birth,
    -- Add other fields you need
    CASE WHEN dp.patient_pk IS NOT NULL THEN 'PATIENT' ELSE 'STAFF' END as source_type
FROM ih_dw.dim_lab_order lo
JOIN ih_dw.dim_lab_order_details lod ON lod.lab_order_fk = lo.lab_order_pk
JOIN IH_DW.SPECTRA_MRN_ASSOCIATIONS asso ON lo.SPECTRA_MRN_ASSC_FK = asso.SPECTRA_MRN_ASSC_pk
LEFT JOIN ih_dw.dim_patient dp ON dp.SPECTRA_MRN_FK = asso.SPECTRA_MRN_fK 
                                AND dp.FACILITY_FK = asso.FACILITY_fK
LEFT JOIN ih_dw.dim_staff ds ON ds.SPECTRA_MRN_FK = asso.SPECTRA_MRN_fK 
                              AND ds.FACILITY_FK = asso.FACILITY_fK
                              AND dp.patient_pk IS NULL  -- Only join staff when patient not found
WHERE rownum < 10;