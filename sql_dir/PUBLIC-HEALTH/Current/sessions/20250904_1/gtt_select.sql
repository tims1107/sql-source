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
            WHERE LAST_UPDATED_DATE >= trunc(sysdate - )
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