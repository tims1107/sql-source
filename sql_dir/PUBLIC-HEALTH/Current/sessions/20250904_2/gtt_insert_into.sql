-- First INSERT: GTT_RESULTS_EXTRACT (Current Day Data)

begin


delete from STATERPT_OWNER.GTT_RESULTS_EXTRACT where accession_number is not null;
dbms_output.put_line('Results deleted: ' || sql%rowcount);
        commit;
        delete from STATERPT_OWNER.GTT_STAFF_RESULTS_EXTRACT where accession_number is not null;
        dbms_output.put_line('Results deleted: ' || sql%rowcount);
        commit;
        
-- gtt_results_extract insert
dbms_output.put_line('Inserting GTT_RESULTS_EXTRACT');
INSERT INTO STATERPT_OWNER.GTT_RESULTS_EXTRACT
SELECT 
  DISTINCT re.ACCESSION_NUMBER accession_no,
  f.FACILITY_ID,
  a.CID,
  dp.ethnicity ethnic_group,
  dp.RACE patient_race,
  lo.EXTERNAL_MRN mrn,
  NVL(p.lname, '') PATIENT_LAST_NAME,
  NVL(p.fname, '') PATIENT_FIRST_NAME,
  (CASE
    WHEN p.mname IS NULL THEN NULL
    WHEN UPPER(p.mname) = 'NULL' THEN NULL
    ELSE p.mname
  END) PATIENT_MIDDLE_NAME,
  (CASE
    WHEN p.DOB IS NULL THEN NULL
    WHEN test_date(p.DOB) = 'Valid' THEN
      (CASE 
        WHEN (EXTRACT(YEAR FROM SYSDATE) - TO_NUMBER(SUBSTR(REPLACE(p.DOB, '-'), 1, 4))) <= 0 THEN NULL 
        ELSE TO_DATE(p.DOB, 'YYYY-MM-DD')
      END)
    ELSE NULL	
  END) date_of_birth,
  p.sex gender,
  p.ssn patient_ssn,
  lo.ordering_physician_npi NPI,
  lo.ordering_physician_name ordering_physician_name,
  lod.REPORT_NOTES,
  lod.SPECIMEN_RECEIVED_DATE_TIME specimen_receive_date,
  lod.COLLECTION_DATE collection_date,
  lod.COLLECTION_TIME collection_time,
  lod.COLLECTION_DATE_TIME,
  lod.DRAW_FREQUENCY draw_freq,
  lod.RESULT_RPT_CHNG_DATE_TIME res_rprt_status_chng_dt_time,
  lod.ORDER_DETAIL_STATUS,
  re.ORDER_TEST_CODE,
  re.ORDER_TEST_NAME,
  re.RESULT_TEST_CODE,
  re.RESULT_TEST_NAME,
  re.RESULT_STATUS,
  re.TEXTUAL_RESULT,
  re.TEXTUAL_RESULT_FULL,
  re.NUMERIC_RESULT,
  re.UNIT_OF_MEASURE units,
  re.REFERENCE_RANGE,
  re.ABNORMAL_FLAG,
  re.RELEASE_DATE_TIME,
  TRIM(DBMS_LOB.SUBSTR(re.RESULT_COMMENT, 4000, 1)) AS RESULT_COMMENTS,
  re.PERFORMING_LAB performing_lab_id,
  lod.TEST_CATEGORY order_method,
  lod.SPECIMEN_METHOD_DESC specimen_source,
  re.REQUISITION_ID order_number,
  dl.LAB_ID logging_site,
  (CASE
    WHEN p.DOB IS NULL THEN 0
    WHEN test_date(p.DOB) = 'Valid' THEN
      (CASE 
        WHEN (EXTRACT(YEAR FROM SYSDATE) - TO_NUMBER(SUBSTR(REPLACE(p.DOB, '-'), 1, 4))) <= 0 THEN 0 
        ELSE TRUNC(MONTHS_BETWEEN(SYSDATE, TO_DATE(p.DOB, 'YYYY-MM-DD'))/12)
      END)
    ELSE NULL	
  END) age,
  f.DISPLAY_NAME facility_name,
  NULL cond_code,
  lo.PATIENT_TYPE,
  lod.ORDER_OCCURRENCE_ID source_of_comment,
  lo.INITIATE_ID patient_id,
  lo.ALTERNATE_PATIENT_ID,
  lo.REQUISITION_STATUS,
  f.ADDRESS_LINE1 facility_address1,
  f.ADDRESS_LINE2 facility_address2,
  f.CITY facility_city,
  f.STATE facility_state,
  f.ZIP facility_zip,
  f.PHONE_NUMBER facility_phone,
  p.stline1 patient_account_address1,
  p.stline2 patient_account_address2,
  p.CITY patient_account_city,
  p.STATE patient_account_state,
  p.zipcode patient_account_zip,
  (CASE
    WHEN p.phnumber IS NULL THEN NULL
    WHEN LENGTH(p.phnumber) > 10 THEN SUBSTR(p.phnumber, ((LENGTH(p.phnumber) - 10) + 1))
    ELSE p.phnumber
  END) patient_home_phone,
  (CASE 
    WHEN re.loinc_code IS NULL AND re.order_test_code = '336' THEN '48345-3' 
    WHEN re.loinc_code IS NULL AND re.order_test_code = '332' THEN '94309-2' 
    WHEN re.loinc_code IS NULL AND re.order_test_code = '331' THEN '96119-3' 
    ELSE re.loinc_code 
  END) loinc_code,
  (CASE 
    WHEN re.loinc_name IS NULL AND re.order_test_code = '336' THEN 'HIV 1+O+2 Ab:PrThr:Pt:Ser/Plas:Ord' 
    WHEN re.loinc_name IS NULL AND re.order_test_code = '332' THEN 'SARS coronavirus 2 RNA:PrThr:Pt:XXX:Ord:Probe.amp.tar' 
    WHEN re.loinc_name IS NULL AND re.order_test_code = '331' THEN 'SARS coronavirus 2 Ag:PrThr:Pt:Respiratory.upper:Ord:IA'
    ELSE re.loinc_name 
  END) loinc_name,
  re.VALUE_TYPE,
  f.EAST_WEST_FLAG,
  f.INTERNAL_EXTERNAL_FLAG,
  re.LAST_UPDATED_DATE last_update_time,
  re.RESULT_SEQUENCE sequence_no,
  f.ACCOUNT_STATUS facility_account_status,
  f.FACILITY_ACTIVE_FLAG,
  re.MICRO_ISOLATE,
  re.MICRO_ORGANISM_NAME,
  re.lab_fk,
  f.CLINICAL_MANAGER,
  dl.MEDICAL_DIRECTOR,
  f.FACILITY_ID acti_facility_id,
  f.FMC_NUMBER,
  NULL reportable_state,
  NULL source_state,
  re.observation_method device_name
FROM IH_DW.RESULTS re
INNER JOIN (
  SELECT DISTINCT requisition_id
  FROM IH_DW.DW_ODS_ACTIVITY
  WHERE LAST_UPDATED_DATE >= TRUNC(SYSDATE)
) activity_filter ON re.requisition_id = activity_filter.requisition_id
INNER JOIN IH_DW.DIM_LAB_ORDER lo ON lo.requisition_id = re.requisition_id
  AND re.LAB_ORDER_FK = lo.LAB_ORDER_PK
INNER JOIN IH_DW.DIM_LAB_ORDER_DETAILS lod ON re.LAB_ORDER_DETAILS_FK = lod.LAB_ORDER_DETAILS_PK
  AND lo.LAB_ORDER_PK = lod.LAB_ORDER_FK
INNER JOIN STATERPT_OWNER.PatientMaster p ON lo.initiate_id = p.eid
  AND p.lab_fk = re.lab_fk
INNER JOIN IH_DW.DIM_ACCOUNT a ON lo.account_fk = a.account_pk
INNER JOIN IH_DW.DIM_FACILITY f ON a.facility_fk = f.facility_pk
INNER JOIN IH_DW.DIM_LAB dl ON re.lab_fk = dl.lab_pk
  AND lo.lab_fk = dl.lab_pk
INNER JOIN IH_DW.SPECTRA_MRN_ASSOCIATIONS asso ON lo.SPECTRA_MRN_ASSC_FK = asso.SPECTRA_MRN_ASSC_pk
INNER JOIN IH_DW.DIM_PATIENT dp ON dp.SPECTRA_MRN_FK = asso.SPECTRA_MRN_fK 
  AND dp.FACILITY_FK = asso.FACILITY_fK;
  
-- gtt_results_extract insert
dbms_output.put_line('Inserting GTT_STAFF_RESULTS_EXTRACT');
INSERT INTO STATERPT_OWNER.GTT_RESULTS_EXTRACT
SELECT 
  DISTINCT re.ACCESSION_NUMBER accession_no,
  f.FACILITY_ID,
  a.CID,
  dp.ethnicity ethnic_group,
  dp.RACE patient_race,
  lo.EXTERNAL_MRN mrn,
  NVL(p.lname, '') PATIENT_LAST_NAME,
  NVL(p.fname, '') PATIENT_FIRST_NAME,
  (CASE
    WHEN p.mname IS NULL THEN NULL
    WHEN UPPER(p.mname) = 'NULL' THEN NULL
    ELSE p.mname
  END) PATIENT_MIDDLE_NAME,
  (CASE
    WHEN p.DOB IS NULL THEN NULL
    WHEN test_date(p.DOB) = 'Valid' THEN
      (CASE 
        WHEN (EXTRACT(YEAR FROM SYSDATE) - TO_NUMBER(SUBSTR(REPLACE(p.DOB, '-'), 1, 4))) <= 0 THEN NULL 
        ELSE TO_DATE(p.DOB, 'YYYY-MM-DD')
      END)
    ELSE NULL	
  END) date_of_birth,
  p.sex gender,
  p.ssn patient_ssn,
  lo.ordering_physician_npi NPI,
  lo.ordering_physician_name ordering_physician_name,
  lod.REPORT_NOTES,
  lod.SPECIMEN_RECEIVED_DATE_TIME specimen_receive_date,
  lod.COLLECTION_DATE collection_date,
  lod.COLLECTION_TIME collection_time,
  lod.COLLECTION_DATE_TIME,
  lod.DRAW_FREQUENCY draw_freq,
  lod.RESULT_RPT_CHNG_DATE_TIME res_rprt_status_chng_dt_time,
  lod.ORDER_DETAIL_STATUS,
  re.ORDER_TEST_CODE,
  re.ORDER_TEST_NAME,
  re.RESULT_TEST_CODE,
  re.RESULT_TEST_NAME,
  re.RESULT_STATUS,
  re.TEXTUAL_RESULT,
  re.TEXTUAL_RESULT_FULL,
  re.NUMERIC_RESULT,
  re.UNIT_OF_MEASURE units,
  re.REFERENCE_RANGE,
  re.ABNORMAL_FLAG,
  re.RELEASE_DATE_TIME,
  TRIM(DBMS_LOB.SUBSTR(re.RESULT_COMMENT, 4000, 1)) AS RESULT_COMMENTS,
  re.PERFORMING_LAB performing_lab_id,
  lod.TEST_CATEGORY order_method,
  lod.SPECIMEN_METHOD_DESC specimen_source,
  re.REQUISITION_ID order_number,
  dl.LAB_ID logging_site,
  (CASE
    WHEN p.DOB IS NULL THEN 0
    WHEN test_date(p.DOB) = 'Valid' THEN
      (CASE 
        WHEN (EXTRACT(YEAR FROM SYSDATE) - TO_NUMBER(SUBSTR(REPLACE(p.DOB, '-'), 1, 4))) <= 0 THEN 0 
        ELSE TRUNC(MONTHS_BETWEEN(SYSDATE, TO_DATE(p.DOB, 'YYYY-MM-DD'))/12)
      END)
    ELSE NULL	
  END) age,
  f.DISPLAY_NAME facility_name,
  NULL cond_code,
  lo.PATIENT_TYPE,
  lod.ORDER_OCCURRENCE_ID source_of_comment,
  lo.INITIATE_ID patient_id,
  lo.ALTERNATE_PATIENT_ID,
  lo.REQUISITION_STATUS,
  f.ADDRESS_LINE1 facility_address1,
  f.ADDRESS_LINE2 facility_address2,
  f.CITY facility_city,
  f.STATE facility_state,
  f.ZIP facility_zip,
  f.PHONE_NUMBER facility_phone,
  p.stline1 patient_account_address1,
  p.stline2 patient_account_address2,
  p.CITY patient_account_city,
  p.STATE patient_account_state,
  p.zipcode patient_account_zip,
  (CASE
    WHEN p.phnumber IS NULL THEN NULL
    WHEN LENGTH(p.phnumber) > 10 THEN SUBSTR(p.phnumber, ((LENGTH(p.phnumber) - 10) + 1))
    ELSE p.phnumber
  END) patient_home_phone,
  (CASE 
    WHEN re.loinc_code IS NULL AND re.order_test_code = '336' THEN '48345-3' 
    WHEN re.loinc_code IS NULL AND re.order_test_code = '332' THEN '94309-2' 
    WHEN re.loinc_code IS NULL AND re.order_test_code = '331' THEN '96119-3' 
    ELSE re.loinc_code 
  END) loinc_code,
  (CASE 
    WHEN re.loinc_name IS NULL AND re.order_test_code = '336' THEN 'HIV 1+O+2 Ab:PrThr:Pt:Ser/Plas:Ord' 
    WHEN re.loinc_name IS NULL AND re.order_test_code = '332' THEN 'SARS coronavirus 2 RNA:PrThr:Pt:XXX:Ord:Probe.amp.tar' 
    WHEN re.loinc_name IS NULL AND re.order_test_code = '331' THEN 'SARS coronavirus 2 Ag:PrThr:Pt:Respiratory.upper:Ord:IA'
    ELSE re.loinc_name 
  END) loinc_name,
  re.VALUE_TYPE,
  f.EAST_WEST_FLAG,
  f.INTERNAL_EXTERNAL_FLAG,
  re.LAST_UPDATED_DATE last_update_time,
  re.RESULT_SEQUENCE sequence_no,
  f.ACCOUNT_STATUS facility_account_status,
  f.FACILITY_ACTIVE_FLAG,
  re.MICRO_ISOLATE,
  re.MICRO_ORGANISM_NAME,
  re.lab_fk,
  f.CLINICAL_MANAGER,
  dl.MEDICAL_DIRECTOR,
  f.FACILITY_ID acti_facility_id,
  f.FMC_NUMBER,
  NULL reportable_state,
  NULL source_state,
  re.observation_method device_name
FROM IH_DW.RESULTS re
INNER JOIN (
  SELECT DISTINCT requisition_id
  FROM IH_DW.DW_ODS_ACTIVITY
  WHERE LAST_UPDATED_DATE >= TRUNC(SYSDATE)
) activity_filter ON re.requisition_id = activity_filter.requisition_id
INNER JOIN IH_DW.DIM_LAB_ORDER lo ON lo.requisition_id = re.requisition_id
  AND re.LAB_ORDER_FK = lo.LAB_ORDER_PK
INNER JOIN IH_DW.DIM_LAB_ORDER_DETAILS lod ON re.LAB_ORDER_DETAILS_FK = lod.LAB_ORDER_DETAILS_PK
  AND lo.LAB_ORDER_PK = lod.LAB_ORDER_FK
INNER JOIN STATERPT_OWNER.PatientMaster p ON lo.initiate_id = p.eid
  AND p.lab_fk = re.lab_fk
INNER JOIN IH_DW.DIM_ACCOUNT a ON lo.account_fk = a.account_pk
INNER JOIN IH_DW.DIM_FACILITY f ON a.facility_fk = f.facility_pk
INNER JOIN IH_DW.DIM_LAB dl ON re.lab_fk = dl.lab_pk
  AND lo.lab_fk = dl.lab_pk
INNER JOIN IH_DW.SPECTRA_MRN_ASSOCIATIONS asso ON lo.SPECTRA_MRN_ASSC_FK = asso.SPECTRA_MRN_ASSC_pk
INNER JOIN IH_DW.DIM_STAFF dp ON dp.SPECTRA_MRN_FK = asso.SPECTRA_MRN_fK 
  AND dp.FACILITY_FK = asso.FACILITY_fK;


end;
/
-- merge gtt tables

select count(1) from gtt_results_extract;
select count(1) from gtt_staff_results_extract;

merge into 
                STATERPT_OWNER.GTT_RESULTS_EXTRACT dest
            using (
                  select
                  distinct(ACCESSION_NUMBER),
                  FACILITY_ID,
                  CID,
                  ETHNIC_GROUP,
                  PATIENT_RACE,
                  EXTERNAL_MRN,
                  PATIENT_LAST_NAME,
                  PATIENT_FIRST_NAME,
                  PATIENT_MIDDLE_NAME,
                  DATE_OF_BIRTH,
                  GENDER,
                  PATIENT_SSN,
                  NPI,
                  ORDERING_PHYSICIAN_NAME,
                  REPORT_NOTES,
                  SPECIMEN_RECEIVE_DATE,
                  COLLECTION_DATE,
                  COLLECTION_TIME,
                  COLLECTION_DATE_TIME,
                  DRAW_FREQ,
                  RES_RPRT_STATUS_CHNG_DT_TIME,
                  ORDER_DETAIL_STATUS,
                  ORDER_TEST_CODE,
                  ORDER_TEST_NAME,
                  RESULT_TEST_CODE,
                  RESULT_TEST_NAME,
                  RESULT_STATUS,
                  TEXTUAL_RESULT,
                  TEXTUAL_RESULT_FULL,
                  NUMERIC_RESULT,
                  UNITS,
                  REFERENCE_RANGE,
                  ABNORMAL_FLAG,
                  RELEASE_DATE_TIME,
                  --RESULT_COMMENTS,
                  trim(dbms_lob.substr( result_comments, 4000, 1 )) as result_comments,
                  PERFORMING_LAB_ID,
                  ORDER_METHOD,
                  SPECIMEN_SOURCE,
                  ORDER_NUMBER,
                  LOGGING_SITE,
                  AGE,
                  FACILITY_NAME,
                  COND_CODE,
                  PATIENT_TYPE,
                  SOURCE_OF_COMMENT,
                  PATIENT_ID,
                  ALTERNATE_PATIENT_ID,
                  REQUISITION_STATUS,
                  FACILITY_ADDRESS1,
                  FACILITY_ADDRESS2,
                  FACILITY_CITY,
                  FACILITY_STATE,
                  FACILITY_ZIP,
                  FACILITY_PHONE,
                  PATIENT_ACCOUNT_ADDRESS1,
                  PATIENT_ACCOUNT_ADDRESS2,
                  PATIENT_ACCOUNT_CITY,
                  PATIENT_ACCOUNT_STATE,
                  PATIENT_ACCOUNT_ZIP,
                  PATIENT_HOME_PHONE,
                  LOINC_CODE,
                  LOINC_NAME,
                  VALUE_TYPE,
                  EAST_WEST_FLAG,
                  INTERNAL_EXTERNAL_FLAG,
                  LAST_UPDATE_TIME,
                  SEQUENCE_NO,
                  FACILITY_ACCOUNT_STATUS,
                  FACILITY_ACTIVE_FLAG,
                  MICRO_ISOLATE,
                  MICRO_ORGANISM_NAME,
                  LAB_FK,
                  CLINICAL_MANAGER,
                  MEDICAL_DIRECTOR,
                  ACTI_FACILITY_ID,
                  FMC_NUMBER,
                  REPORTABLE_STATE,
                  DEVICE_NAME
                  from
                      STATERPT_OWNER.GTT_STAFF_RESULTS_EXTRACT            
            ) src
            on (
            dest.accession_number = src.accession_number
            AND dest.facility_id = src.facility_id
            AND dest.patient_id = src.patient_id
            AND dest.order_test_name = src.order_test_name 
            AND dest.order_test_code = src.order_test_code 
            AND dest.textual_result_full = src.textual_result_full
            AND dest.last_update_time = src.last_update_time 
            )
            when MATCHED then
                update
                    set dest.cond_code = src.cond_code
            when NOT MATCHED then
            insert (
                  dest.ACCESSION_NUMBER,
                  dest.FACILITY_ID,
                  dest.CID,
                  dest.ETHNIC_GROUP,
                  dest.PATIENT_RACE,
                  dest.EXTERNAL_MRN,
                  dest.PATIENT_LAST_NAME,
                  dest.PATIENT_FIRST_NAME,
                  dest.PATIENT_MIDDLE_NAME,
                  dest.DATE_OF_BIRTH,
                  dest.GENDER,
                  dest.PATIENT_SSN,
                  dest.NPI,
                  dest.ORDERING_PHYSICIAN_NAME,
                  dest.REPORT_NOTES,
                  dest.SPECIMEN_RECEIVE_DATE,
                  dest.COLLECTION_DATE,
                  dest.COLLECTION_TIME,
                  dest.COLLECTION_DATE_TIME,
                  dest.DRAW_FREQ,
                  dest.RES_RPRT_STATUS_CHNG_DT_TIME,
                  dest.ORDER_DETAIL_STATUS,
                  dest.ORDER_TEST_CODE,
                  dest.ORDER_TEST_NAME,
                  dest.RESULT_TEST_CODE,
                  dest.RESULT_TEST_NAME,
                  dest.RESULT_STATUS,
                  dest.TEXTUAL_RESULT,
                  dest.TEXTUAL_RESULT_FULL,
                  dest.NUMERIC_RESULT,
                  dest.UNITS,
                  dest.REFERENCE_RANGE,
                  dest.ABNORMAL_FLAG,
                  dest.RELEASE_DATE_TIME,
                  dest.RESULT_COMMENTS,
                  dest.PERFORMING_LAB_ID,
                  dest.ORDER_METHOD,
                  dest.SPECIMEN_SOURCE,
                  dest.ORDER_NUMBER,
                  dest.LOGGING_SITE,
                  dest.AGE,
                  dest.FACILITY_NAME,
                  dest.COND_CODE,
                  dest.PATIENT_TYPE,
                  dest.SOURCE_OF_COMMENT,
                  dest.PATIENT_ID,
                  dest.ALTERNATE_PATIENT_ID,
                  dest.REQUISITION_STATUS,
                  dest.FACILITY_ADDRESS1,
                  dest.FACILITY_ADDRESS2,
                  dest.FACILITY_CITY,
                  dest.FACILITY_STATE,
                  dest.FACILITY_ZIP,
                  dest.FACILITY_PHONE,
                  dest.PATIENT_ACCOUNT_ADDRESS1,
                  dest.PATIENT_ACCOUNT_ADDRESS2,
                  dest.PATIENT_ACCOUNT_CITY,
                  dest.PATIENT_ACCOUNT_STATE,
                  dest.PATIENT_ACCOUNT_ZIP,
                  dest.PATIENT_HOME_PHONE,
                  dest.LOINC_CODE,
                  dest.LOINC_NAME,
                  dest.VALUE_TYPE,
                  dest.EAST_WEST_FLAG,
                  dest.INTERNAL_EXTERNAL_FLAG,
                  dest.LAST_UPDATE_TIME,
                  dest.SEQUENCE_NO,
                  dest.FACILITY_ACCOUNT_STATUS,
                  dest.FACILITY_ACTIVE_FLAG,
                  dest.MICRO_ISOLATE,
                  dest.MICRO_ORGANISM_NAME,
                  dest.LAB_FK,
                  dest.CLINICAL_MANAGER,
                  dest.MEDICAL_DIRECTOR,
                  dest.ACTI_FACILITY_ID,
                  dest.FMC_NUMBER,
                  dest.REPORTABLE_STATE,
                  dest.DEVICE_NAME
            )values (
                  src.ACCESSION_NUMBER,
                  src.FACILITY_ID,
                  src.CID,
                  src.ETHNIC_GROUP,
                  src.PATIENT_RACE,
                  src.EXTERNAL_MRN,
                  src.PATIENT_LAST_NAME,
                  src.PATIENT_FIRST_NAME,
                  src.PATIENT_MIDDLE_NAME,
                  src.DATE_OF_BIRTH,
                  src.GENDER,
                  src.PATIENT_SSN,
                  src.NPI,
                  src.ORDERING_PHYSICIAN_NAME,
                  src.REPORT_NOTES,
                  src.SPECIMEN_RECEIVE_DATE,
                  src.COLLECTION_DATE,
                  src.COLLECTION_TIME,
                  src.COLLECTION_DATE_TIME,
                  src.DRAW_FREQ,
                  src.RES_RPRT_STATUS_CHNG_DT_TIME,
                  src.ORDER_DETAIL_STATUS,
                  src.ORDER_TEST_CODE,
                  src.ORDER_TEST_NAME,
                  src.RESULT_TEST_CODE,
                  src.RESULT_TEST_NAME,
                  src.RESULT_STATUS,
                  src.TEXTUAL_RESULT,
                  src.TEXTUAL_RESULT_FULL,
                  src.NUMERIC_RESULT,
                  src.UNITS,
                  src.REFERENCE_RANGE,
                  src.ABNORMAL_FLAG,
                  src.RELEASE_DATE_TIME,
                  src.RESULT_COMMENTS,
                  src.PERFORMING_LAB_ID,
                  src.ORDER_METHOD,
                  src.SPECIMEN_SOURCE,
                  src.ORDER_NUMBER,
                  src.LOGGING_SITE,
                  src.AGE,
                  src.FACILITY_NAME,
                  src.COND_CODE,
                  src.PATIENT_TYPE,
                  src.SOURCE_OF_COMMENT,
                  src.PATIENT_ID,
                  src.ALTERNATE_PATIENT_ID,
                  src.REQUISITION_STATUS,
                  src.FACILITY_ADDRESS1,
                  src.FACILITY_ADDRESS2,
                  src.FACILITY_CITY,
                  src.FACILITY_STATE,
                  src.FACILITY_ZIP,
                  src.FACILITY_PHONE,
                  src.PATIENT_ACCOUNT_ADDRESS1,
                  src.PATIENT_ACCOUNT_ADDRESS2,
                  src.PATIENT_ACCOUNT_CITY,
                  src.PATIENT_ACCOUNT_STATE,
                  src.PATIENT_ACCOUNT_ZIP,
                  src.PATIENT_HOME_PHONE,
                  src.LOINC_CODE,
                  src.LOINC_NAME,
                  src.VALUE_TYPE,
                  src.EAST_WEST_FLAG,
                  src.INTERNAL_EXTERNAL_FLAG,
                  src.LAST_UPDATE_TIME,
                  src.SEQUENCE_NO,
                  src.FACILITY_ACCOUNT_STATUS,
                  src.FACILITY_ACTIVE_FLAG,
                  src.MICRO_ISOLATE,
                  src.MICRO_ORGANISM_NAME,
                  src.LAB_FK,
                  src.CLINICAL_MANAGER,
                  src.MEDICAL_DIRECTOR,
                  src.ACTI_FACILITY_ID,
                  src.FMC_NUMBER,
                  src.PATIENT_ACCOUNT_STATE,
                  src.DEVICE_NAME
            );


/

declare
v_final_sql CLOB := '';
    v_condition_sql VARCHAR2(4000);
    v_condition_count NUMBER := 0;
    v_state_abbrev varchar2(2) := 'TX';

begin

FOR rec IN (
        SELECT 
            cm.condition_master_pk,
            cm.order_test_code,
            cm.result_test_code,
            cm.condition_value,
            cm.value_type,  -- Add this field
            cf.filter
        FROM CONDITION_MASTER cm
        JOIN CONDITION_FILTERS cf ON cm.condition_filter_fk = cf.condition_filter_pk
        WHERE cm.state_fk = (select state_master_pk from state_master where state_abbreviation = v_state_abbrev)
        AND cm.status = 'active'
        AND cf.status = 'active'
        AND regexp_like(cm.order_test_code,'^(301|303|304|310|311|319N|312|318|332|336|322|315|317L|323|327)$') 
        ORDER BY cm.condition_master_pk
    ) LOOP
        v_condition_count := v_condition_count + 1;
        
        -- Use the function with value_type parameter
        v_condition_sql := build_condition_filter_sql(
            rec.condition_master_pk,
            rec.order_test_code,
            rec.result_test_code,
            rec.filter,
            rec.condition_value,
            rec.value_type  -- Pass the value_type
        );
        
        -- Add to UNION ALL
        IF v_condition_count = 1 THEN
            v_final_sql := v_condition_sql;
        ELSE
            v_final_sql := v_final_sql || ' UNION ALL ' || v_condition_sql;
        END IF;
        
    END LOOP;
    
    -- Execute final query
    IF v_condition_count > 0 THEN
        v_final_sql := 'SELECT * FROM (' || v_final_sql || ') ' || 
                        'WHERE patient_account_state = ''' || v_state_abbrev || '''' ||
                        ' ORDER BY accession_number, order_test_code';
        
--        DBMS_OUTPUT.PUT_LINE('Processing ' || v_condition_count || ' conditions for state_fk: ' || v_state_abbrev);
--        
        dbms_output.put_line(v_final_sql);
        
        --OPEN p_recordset FOR v_final_sql;
    ELSE
        DBMS_OUTPUT.PUT_LINE('No active conditions found for state_fk: ' || v_state_abbrev);
--        OPEN p_recordset FOR 
--            SELECT gtt.*, 0 as condition_master_pk
--            FROM GTT_RESULTS_EXTRACT gtt WHERE 1=0;
    END IF;

end;

