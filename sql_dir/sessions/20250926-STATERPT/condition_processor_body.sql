-- SECTION 1: Package Header and Variables (CORRECTED)
CREATE OR REPLACE PACKAGE BODY STATERPT_OWNER.condition_processor AS
    -- Package variables
    g_session_initialized BOOLEAN := FALSE;
    g_gtt_record_count NUMBER := 0;
    
    -- Global variables for chunk tracking
    g_current_chunk NUMBER := 0;
    g_total_chunks NUMBER := 0;
    g_chunk_start_time TIMESTAMP;

    -- Session management procedures
    PROCEDURE initialize_session(p_last_updated_date DATE DEFAULT TRUNC(SYSDATE)) IS
        v_deleted_count NUMBER;
        v_inserted_count NUMBER;
        v_date_filter VARCHAR2(50);
    BEGIN
        -- Format the date for display
        v_date_filter := TO_CHAR(p_last_updated_date, 'YYYY-MM-DD');
        DBMS_OUTPUT.PUT_LINE('Initializing session with date filter: ' || v_date_filter);

        -- Clear existing GTT data
        DELETE FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT WHERE accession_number IS NOT NULL;
        v_deleted_count := SQL%ROWCOUNT;
        DBMS_OUTPUT.PUT_LINE('GTT_RESULTS_EXTRACT deleted: ' || v_deleted_count);
        COMMIT;

        DELETE FROM STATERPT_OWNER.GTT_STAFF_RESULTS_EXTRACT WHERE accession_number IS NOT NULL;
        v_deleted_count := SQL%ROWCOUNT;
        DBMS_OUTPUT.PUT_LINE('GTT_STAFF_RESULTS_EXTRACT deleted: ' || v_deleted_count);
        COMMIT;

        -- Populate GTT_RESULTS_EXTRACT with dynamic date filter
        DBMS_OUTPUT.PUT_LINE('Inserting GTT_RESULTS_EXTRACT with date >= ' || v_date_filter);
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
            WHERE LAST_UPDATED_DATE >= p_last_updated_date
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

        v_inserted_count := SQL%ROWCOUNT;
        DBMS_OUTPUT.PUT_LINE('GTT_RESULTS_EXTRACT inserted: ' || v_inserted_count);

        commit;

        -- Populate GTT_STAFF_RESULTS_EXTRACT with same dynamic date filter
        DBMS_OUTPUT.PUT_LINE('Inserting GTT_STAFF_RESULTS_EXTRACT with date >= ' || v_date_filter);
        INSERT INTO STATERPT_OWNER.GTT_STAFF_RESULTS_EXTRACT
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
            WHERE LAST_UPDATED_DATE >= p_last_updated_date
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

        v_inserted_count := SQL%ROWCOUNT;
        DBMS_OUTPUT.PUT_LINE('GTT_STAFF_RESULTS_EXTRACT inserted: ' || v_inserted_count);

        commit;

        g_session_initialized := TRUE;
        g_gtt_record_count := v_inserted_count;

    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            g_session_initialized := FALSE;
            RAISE;
    END initialize_session;

    PROCEDURE cleanup_session IS
    BEGIN
        g_session_initialized := FALSE;
        g_gtt_record_count := 0;

        DELETE FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT;
        DELETE FROM STATERPT_OWNER.GTT_STAFF_RESULTS_EXTRACT;
        COMMIT;
    END cleanup_session;

    FUNCTION get_session_status RETURN VARCHAR2 IS
    BEGIN
        IF g_session_initialized THEN
            RETURN 'INITIALIZED - ' || g_gtt_record_count || ' records loaded';
        ELSE
            RETURN 'NOT_INITIALIZED';
        END IF;
    END get_session_status;
-- SECTION 2: Helper Functions and Core Processing (CORRECTED)

    -- Helper functions
    FUNCTION is_filter_safe(p_filter VARCHAR2) RETURN BOOLEAN IS
    BEGIN
        IF p_filter IS NULL THEN
            RETURN TRUE;
        END IF;

        IF REGEXP_LIKE(UPPER(p_filter), '(DROP|DELETE|INSERT|UPDATE|CREATE|ALTER|TRUNCATE|EXEC|EXECUTE)') THEN
            RETURN FALSE;
        END IF;

        IF INSTR(p_filter, '--') > 0 OR INSTR(p_filter, '/*') > 0 THEN
            RETURN FALSE;
        END IF;

        IF INSTR(p_filter, ';') > 0 THEN
            RETURN FALSE;
        END IF;

        RETURN TRUE;
    END is_filter_safe;

    FUNCTION build_condition_filter_sql(
        p_condition_id NUMBER,
        p_order_test_code VARCHAR2,
        p_result_test_code VARCHAR2,
        p_filter VARCHAR2,
        p_condition_value VARCHAR2,
        p_value_type VARCHAR2
    ) RETURN VARCHAR2 IS
        v_sql VARCHAR2(4000);
        v_processed_filter VARCHAR2(4000);
        v_formatted_value VARCHAR2(1000);
        v_safe_otc VARCHAR2(100);
        v_safe_rtc VARCHAR2(100);
    BEGIN
        -- Sanitize input parameters
        v_safe_otc := REPLACE(REPLACE(p_order_test_code, '''', ''''''), CHR(0), '');
        v_safe_rtc := REPLACE(REPLACE(p_result_test_code, '''', ''''''), CHR(0), '');

        -- Base query without condition_master_pk - returns GTT structure
        v_sql := 'SELECT gtt.* FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT gtt WHERE 1=1';

        -- Add test code filters
        IF v_safe_otc IS NOT NULL AND LENGTH(TRIM(v_safe_otc)) > 0 THEN
            v_sql := v_sql || ' AND gtt.order_test_code = ''' || v_safe_otc || '''';
        END IF;

        IF v_safe_rtc IS NOT NULL AND LENGTH(TRIM(v_safe_rtc)) > 0 THEN
            v_sql := v_sql || ' AND gtt.result_test_code = ''' || v_safe_rtc || '''';
        END IF;

        -- Process dynamic filter with smart replacement
        IF p_filter IS NOT NULL AND LENGTH(TRIM(p_filter)) > 0 THEN
            v_processed_filter := p_filter;

            -- Replace table alias first
            v_processed_filter := REPLACE(v_processed_filter, 'r.', 'gtt.');

            -- Smart replacement based on context and value type
            IF p_condition_value IS NOT NULL THEN
                IF UPPER(p_value_type) = 'ST' THEN
                    -- For string values, check if {0} is already inside quotes
                    IF INSTR(v_processed_filter, '''%{0}%''') > 0 OR 
                       INSTR(v_processed_filter, '''{0}''') > 0 OR
                       INSTR(v_processed_filter, '''%{0}') > 0 OR
                       INSTR(v_processed_filter, '{0}%''') > 0 THEN
                        -- {0} is already inside quotes, replace without adding quotes
                        v_formatted_value := REPLACE(p_condition_value, '''', '''''');
                    ELSE
                        -- {0} is not inside quotes, add quotes
                        v_formatted_value := '''' || REPLACE(p_condition_value, '''', '''''') || '''';
                    END IF;
                ELSIF UPPER(p_value_type) = 'NM' THEN
                    -- Numeric values never need quotes
                    v_formatted_value := p_condition_value;
                ELSE
                    -- Default handling for unknown types
                    IF INSTR(v_processed_filter, '''%{0}%''') > 0 OR 
                       INSTR(v_processed_filter, '''{0}''') > 0 THEN
                        v_formatted_value := REPLACE(p_condition_value, '''', '''''');
                    ELSE
                        v_formatted_value := '''' || REPLACE(p_condition_value, '''', '''''') || '''';
                    END IF;
                END IF;
            ELSE
                v_formatted_value := 'NULL';
            END IF;

            -- Replace {0} with the formatted value
            v_processed_filter := REPLACE(v_processed_filter, '{0}', v_formatted_value);

            IF is_filter_safe(v_processed_filter) THEN
                v_sql := v_sql || ' AND (' || TRIM(v_processed_filter) || ')';
            ELSE
                DBMS_OUTPUT.PUT_LINE('SECURITY WARNING: Unsafe filter for condition ' || p_condition_id);
            END IF;
        END IF;

        RETURN v_sql;

    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error building SQL for condition ' || p_condition_id || ': ' || SQLERRM);
            RETURN 'SELECT gtt.* FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT gtt WHERE 1=0';
    END build_condition_filter_sql;

    FUNCTION get_base_condition_sql(
        p_state_abbrev VARCHAR2,
        p_process_date DATE
    ) RETURN CLOB IS
        v_final_sql CLOB := '';
        v_condition_sql VARCHAR2(4000);
        v_condition_count NUMBER := 0;
        v_state_pk NUMBER;
        v_test_code_count NUMBER := 0;

    BEGIN
        -- Get state primary key
        BEGIN
            SELECT state_master_pk 
            INTO v_state_pk
            FROM state_master 
            WHERE state_abbreviation = p_state_abbrev;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                DBMS_OUTPUT.PUT_LINE('WARNING: State ' || p_state_abbrev || ' not found in state_master');
                RETURN 'SELECT gtt.*, 0 as condition_master_pk FROM GTT_RESULTS_EXTRACT gtt WHERE 1=0';
        END;

        -- Count valid test codes for logging
        SELECT COUNT(DISTINCT cm.order_test_code)
        INTO v_test_code_count
        FROM CONDITION_MASTER cm
        JOIN CONDITION_FILTERS cf ON cm.condition_filter_fk = cf.condition_filter_pk
        WHERE cm.state_fk = v_state_pk
        AND cm.status = 'active'
        AND cf.status = 'active'
        AND cm.order_test_code IS NOT NULL
        AND LENGTH(TRIM(cm.order_test_code)) > 0;

        DBMS_OUTPUT.PUT_LINE('Found ' || v_test_code_count || ' test codes for state ' || p_state_abbrev);

        -- If no valid test codes found, return empty result
        IF v_test_code_count = 0 THEN
            DBMS_OUTPUT.PUT_LINE('WARNING: No active test codes found for state ' || p_state_abbrev);
            RETURN 'SELECT gtt.*, 0 as condition_master_pk FROM GTT_RESULTS_EXTRACT gtt WHERE 1=0';
        END IF;

        -- Build conditions directly using cursor (no string parsing needed)
        FOR rec IN (
            SELECT 
                cm.condition_master_pk,
                cm.order_test_code,
                cm.result_test_code,
                cm.condition_value,
                cm.value_type,
                cf.filter
            FROM CONDITION_MASTER cm
            JOIN CONDITION_FILTERS cf ON cm.condition_filter_fk = cf.condition_filter_pk
            WHERE cm.state_fk = v_state_pk
            AND cm.status = 'active'
            AND cf.status = 'active'
            AND cm.order_test_code IS NOT NULL
            AND LENGTH(TRIM(cm.order_test_code)) > 0
            ORDER BY cm.condition_master_pk
        ) LOOP
            v_condition_count := v_condition_count + 1;

            v_condition_sql := build_condition_filter_sql(
                rec.condition_master_pk,
                rec.order_test_code,
                rec.result_test_code,
                rec.filter,
                rec.condition_value,
                rec.value_type
            );

            IF v_condition_count = 1 THEN
                v_final_sql := v_condition_sql;
            ELSE
                v_final_sql := v_final_sql || ' UNION ALL ' || v_condition_sql || chr(10);
            END IF;
        END LOOP;

        DBMS_OUTPUT.PUT_LINE('Built ' || v_condition_count || ' conditions for state ' || p_state_abbrev);

        IF v_condition_count > 0 THEN
            -- Return SQL with integrated 310 validation logic
            RETURN 'SELECT  ' || 
    '    accession_number, facility_id, cid, ethnic_group, patient_race, external_mrn, ' || 
    '    patient_last_name, patient_first_name, patient_middle_name, date_of_birth, ' || 
    '    gender, patient_ssn, npi, ordering_physician_name, report_notes, ' || 
    '    specimen_receive_date, collection_date, collection_time, collection_date_time, ' || 
    '    draw_freq, res_rprt_status_chng_dt_time, order_detail_status, order_test_code, ' || 
    '    order_test_name, result_test_code, result_test_name, result_status, ' || 
    '    textual_result, textual_result_full, numeric_result, units, reference_range, ' || 
    '    abnormal_flag, release_date_time, result_comments, performing_lab_id, ' || 
    '    order_method, specimen_source, order_number, logging_site, age, ' || 
    '    facility_name, cond_code, patient_type, source_of_comment, patient_id, ' || 
    '    alternate_patient_id, requisition_status, facility_address1, facility_address2, ' || 
    '    facility_city, facility_state, facility_zip, facility_phone, ' || 
    '    patient_account_address1, patient_account_address2, patient_account_city, ' || 
    '    patient_account_state, patient_account_zip, patient_home_phone, loinc_code, ' || 
    '    loinc_name, value_type, east_west_flag, internal_external_flag, ' || 
    '    last_update_time, sequence_no, facility_account_status, facility_active_flag, ' || 
    '    micro_isolate, micro_organism_name, lab_fk, clinical_manager, medical_director, ' || 
    '    acti_facility_id, fmc_number, reportable_state, source_state, device_name ' || 
    'FROM ( ' ||
            'SELECT ' ||
            'base.* ,' ||
            'ROW_NUMBER() OVER (' ||
                'PARTITION BY order_number, result_test_code ' || 
                'ORDER BY accession_number, facility_id, patient_last_name ' ||
            ') as rn ' ||
       ' FROM (' || v_final_sql || ') base ' ||
                   'WHERE patient_account_state = ''' || p_state_abbrev || '''' ||
           ' AND TRUNC(release_date_time) = DATE ''' || TO_CHAR(p_process_date, 'YYYY-MM-DD') || '''';

        ELSE
            RETURN 'SELECT gtt.*, 0 as condition_master_pk FROM GTT_RESULTS_EXTRACT gtt WHERE 1=0';
        END IF;

    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error in get_base_condition_sql: ' || SQLERRM);
            RAISE;
    END get_base_condition_sql;

    FUNCTION process_state(
        p_state_abbrev VARCHAR2, 
        p_process_date DATE DEFAULT TRUNC(SYSDATE)
    ) RETURN SYS_REFCURSOR IS
        v_cursor SYS_REFCURSOR;
        v_base_sql CLOB;
    BEGIN
        IF NOT g_session_initialized THEN
            initialize_session;
        END IF;

        v_base_sql := get_base_condition_sql(p_state_abbrev, p_process_date);
        dbms_output.put_line(v_base_sql);

        OPEN v_cursor FOR v_base_sql;
        RETURN v_cursor;

    EXCEPTION
        WHEN OTHERS THEN
            IF v_cursor%ISOPEN THEN
                CLOSE v_cursor;
            END IF;
            RAISE;
    END process_state;
-- SECTION 3: Validation and 310 Functions (CORRECTED)

    FUNCTION validate_results(
        p_state_abbrev VARCHAR2,
        p_process_date DATE DEFAULT TRUNC(SYSDATE),
        p_max_records NUMBER DEFAULT 200,
        p_result_status_filter VARCHAR2 DEFAULT NULL
    ) RETURN SYS_REFCURSOR IS
        v_cursor SYS_REFCURSOR;
        v_base_sql CLOB;
        v_final_sql CLOB;
        v_status_filter VARCHAR2(100) := '';
    BEGIN
        DBMS_OUTPUT.PUT_LINE('Validating results for state: ' || p_state_abbrev || 
            ' on date: ' || TO_CHAR(p_process_date, 'YYYY-MM-DD'));

        -- Auto-initialize if not done
        IF NOT g_session_initialized THEN
            initialize_session;
        END IF;

        -- Get base condition SQL
        v_base_sql := get_base_condition_sql(p_state_abbrev, p_process_date);

        -- Build status filter as CLOB if provided
        IF p_result_status_filter IS NOT NULL THEN
            v_status_filter := TO_CLOB(' AND result_status = ''' || p_result_status_filter || '''');
            DBMS_OUTPUT.PUT_LINE('Applying result status filter: ' || p_result_status_filter);
        END IF;

        -- Build final SQL with 310 validation using SELECT *
        v_final_sql := v_base_sql || v_status_filter || ')' || chr(10) || ' where rn = 1';

        dbms_output.put_line(v_final_sql);

        OPEN v_cursor FOR v_final_sql;
        RETURN v_cursor;

    EXCEPTION
        WHEN OTHERS THEN
            IF v_cursor%ISOPEN THEN
                CLOSE v_cursor;
            END IF;
            RAISE;
    END validate_results;

    -- Function to return active states for validation
    FUNCTION get_active_states RETURN SYS_REFCURSOR IS
        v_cursor SYS_REFCURSOR;
    BEGIN
        OPEN v_cursor FOR
            SELECT state_abbreviation, state
            FROM state_master
            WHERE LENGTH(state_abbreviation) = 2
            AND entity_type = 'Abnormal'
            AND status = 'active'
            ORDER BY state_abbreviation;

        RETURN v_cursor;

    EXCEPTION
        WHEN OTHERS THEN
            -- Return empty cursor on error
            OPEN v_cursor FOR SELECT NULL state_abbreviation, NULL state FROM DUAL WHERE 1=0;
            RETURN v_cursor;
    END get_active_states;

    FUNCTION is_valid_310_record(
        p_order_number VARCHAR2,
        p_order_test_code VARCHAR2,
        p_state_abbrev VARCHAR2,
        p_process_date DATE
    ) RETURN BOOLEAN IS
        v_count NUMBER;
    BEGIN
        IF p_order_test_code != '310' THEN
            RETURN TRUE;
        END IF;

        SELECT COUNT(DISTINCT result_test_code)
        INTO v_count
        FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT
        WHERE order_number = p_order_number
        AND order_test_code = '310'
        AND result_test_code IN ('310', '310A')
        AND patient_account_state = p_state_abbrev
        AND TRUNC(release_date_time) = p_process_date
        AND result_status = 'F';

        RETURN v_count = 2;

    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error validating 310 record: ' || SQLERRM);
            RETURN FALSE;
    END is_valid_310_record;

    FUNCTION filter_310_validation(
        p_state_abbrev VARCHAR2,
        p_process_date DATE,
        p_result_status_filter VARCHAR2 DEFAULT NULL
    ) RETURN SYS_REFCURSOR IS
        v_cursor SYS_REFCURSOR;
        v_sql CLOB;
    BEGIN
        -- Build SQL with 310 validation logic embedded
        v_sql := 'SELECT * FROM (' || get_base_condition_sql(p_state_abbrev, p_process_date) || ') base ' ||
                 'WHERE (base.order_test_code != ''310'' OR ' ||
                 '(SELECT COUNT(DISTINCT sub.result_test_code) ' ||
                 'FROM (' || get_base_condition_sql(p_state_abbrev, p_process_date) || ') sub ' ||
                 'WHERE sub.order_number = base.order_number ' ||
                 'AND sub.order_test_code = ''310'' ' ||
                 'AND sub.result_test_code IN (''310'', ''310A'')) = 2)';

        -- Add result status filter if provided
        IF p_result_status_filter IS NOT NULL THEN
            v_sql := v_sql || ' AND result_status = ''' || p_result_status_filter || '''';
        END IF;

        OPEN v_cursor FOR v_sql;
        RETURN v_cursor;

    EXCEPTION
        WHEN OTHERS THEN
            IF v_cursor%ISOPEN THEN
                CLOSE v_cursor;
            END IF;
            RAISE;
    END filter_310_validation;

    -- Enhanced log_message procedure (CORRECTED - single declaration)
    PROCEDURE log_message(p_level VARCHAR2, p_message VARCHAR2) IS
        PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        -- Simple DBMS_OUTPUT fallback since logging table may not exist
        DBMS_OUTPUT.PUT_LINE(TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI:SS') || ' [' || p_level || '] ' || p_message);
        
        -- Optional: Try to log to table if it exists (wrapped in exception)
        BEGIN
            EXECUTE IMMEDIATE 'INSERT INTO condition_processor_log (log_id, log_level, message, created_date) 
                              VALUES (condition_processor_log_seq.NEXTVAL, :1, :2, SYSTIMESTAMP)'
            USING p_level, SUBSTR(p_message, 1, 4000);
            COMMIT;
        EXCEPTION
            WHEN OTHERS THEN
                NULL; -- Ignore if logging table doesn't exist
        END;
    END log_message;
-- SECTION 4: Chunked Processing Functions (CORRECTED)

    -- Fixed chunked initialization function using your existing GTT structure
    FUNCTION initialize_session_chunked(
        p_start_date DATE,
        p_end_date DATE,
        p_chunk_hours NUMBER DEFAULT 2
    ) RETURN VARCHAR2 IS
        v_current_start DATE;
        v_current_end DATE;
        v_total_records NUMBER := 0;
        v_chunk_records NUMBER;
        v_chunk_num NUMBER := 1;
        v_start_time TIMESTAMP := SYSTIMESTAMP;
        v_chunk_start_time TIMESTAMP;
        v_chunk_duration NUMBER;
        v_status VARCHAR2(4000);
        v_merge_count NUMBER;
    BEGIN
        -- Initialize tracking variables
        g_chunk_start_time := SYSTIMESTAMP;
        g_current_chunk := 0;
        g_total_chunks := CEIL((p_end_date - p_start_date) * 24 / p_chunk_hours);
        
        log_message('INFO', 'Starting chunked initialization: ' || g_total_chunks || ' chunks of ' || p_chunk_hours || ' hours each');
        
        -- Clear existing GTT data
        DELETE FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT WHERE accession_number IS NOT NULL;
        DELETE FROM STATERPT_OWNER.GTT_STAFF_RESULTS_EXTRACT WHERE accession_number IS NOT NULL;
        COMMIT;
        
        v_current_start := p_start_date;
        
        WHILE v_current_start < p_end_date LOOP
            v_chunk_start_time := SYSTIMESTAMP;
            g_current_chunk := v_chunk_num;
            
            v_current_end := v_current_start + (p_chunk_hours / 24);
            IF v_current_end > p_end_date THEN
                v_current_end := p_end_date;
            END IF;
            
            -- Log chunk start
            log_message('INFO', 'Processing chunk ' || v_chunk_num || '/' || g_total_chunks || 
                       ': ' || TO_CHAR(v_current_start, 'YYYY-MM-DD HH24:MI') || 
                       ' to ' || TO_CHAR(v_current_end, 'YYYY-MM-DD HH24:MI'));
            
            -- Insert GTT_RESULTS_EXTRACT chunk using corrected query structure
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
                WHERE LAST_UPDATED_DATE >= v_current_start
                  AND LAST_UPDATED_DATE < v_current_end
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

            v_chunk_records := SQL%ROWCOUNT;
            log_message('INFO', 'GTT_RESULTS_EXTRACT chunk inserted: ' || v_chunk_records);

            -- Insert GTT_STAFF_RESULTS_EXTRACT chunk using DIM_STAFF
            INSERT INTO STATERPT_OWNER.GTT_STAFF_RESULTS_EXTRACT
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
                WHERE LAST_UPDATED_DATE >= v_current_start
                  AND LAST_UPDATED_DATE < v_current_end
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
                
            -- MERGE staff data into main GTT (CORRECTED - using INSERT with NOT EXISTS)
            INSERT INTO STATERPT_OWNER.GTT_RESULTS_EXTRACT
            SELECT * FROM STATERPT_OWNER.GTT_STAFF_RESULTS_EXTRACT staff
            WHERE staff.last_update_time >= v_current_start
              AND staff.last_update_time < v_current_end
              AND NOT EXISTS (
                SELECT 1 FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT target
                WHERE target.order_number = staff.order_number 
                  AND target.result_test_code = staff.result_test_code
                  AND target.accession_number = staff.accession_number
              );

            v_merge_count := SQL%ROWCOUNT;
            log_message('INFO', 'Merged ' || v_merge_count || ' staff records into main GTT for chunk ' || g_current_chunk);

            -- Clear the staff GTT for the next chunk
            DELETE FROM STATERPT_OWNER.GTT_STAFF_RESULTS_EXTRACT 
            WHERE last_update_time >= v_current_start 
              AND last_update_time < v_current_end;
            
            v_total_records := v_total_records + v_chunk_records;
            
            -- Calculate chunk duration
            v_chunk_duration := EXTRACT(SECOND FROM (SYSTIMESTAMP - v_chunk_start_time));
            
            -- Log chunk completion
            log_message('INFO', 'Chunk ' || v_chunk_num || ' completed: ' || 
                       v_chunk_records || ' records in ' || 
                       ROUND(v_chunk_duration, 2) || ' seconds');
            
            COMMIT; -- Commit each chunk
            
            v_current_start := v_current_end;
            v_chunk_num := v_chunk_num + 1;
            
        END LOOP;
        
        -- Final status
        v_status := 'INITIALIZED - ' || v_total_records || ' records loaded in ' || 
                    (v_chunk_num - 1) || ' chunks over ' || 
                    ROUND(EXTRACT(SECOND FROM (SYSTIMESTAMP - v_start_time)), 2) || ' seconds';
        
        log_message('INFO', 'Chunked initialization completed: ' || v_status);
        
        -- Update session state
        g_session_initialized := TRUE;
        g_gtt_record_count := v_total_records;
        
        -- Reset tracking variables
        g_current_chunk := 0;
        g_total_chunks := 0;
        
        RETURN v_status;
        
    EXCEPTION
        WHEN OTHERS THEN
            log_message('ERROR', 'Chunked initialization failed at chunk ' || v_chunk_num || ': ' || SQLERRM);
            ROLLBACK;
            g_session_initialized := FALSE;
            RETURN 'ERROR - ' || SQLERRM;
    END initialize_session_chunked;

    FUNCTION get_chunk_progress RETURN VARCHAR2 IS
    BEGIN
        IF g_total_chunks = 0 THEN
            RETURN 'No chunked operation in progress';
        END IF;
        
        RETURN 'Chunk ' || g_current_chunk || ' of ' || g_total_chunks || 
               ' (' || ROUND((g_current_chunk / g_total_chunks) * 100, 1) || '% complete)';
    END get_chunk_progress;

    FUNCTION calculate_optimal_chunk_size(
        p_start_date DATE,
        p_end_date DATE,
        p_target_records_per_chunk NUMBER DEFAULT 500
    ) RETURN NUMBER IS
        v_total_records NUMBER;
        v_total_hours NUMBER;
        v_records_per_hour NUMBER;
        v_optimal_hours NUMBER;
    BEGIN
        -- Estimate total records in date range using your existing table structure
        SELECT COUNT(*)
        INTO v_total_records
        FROM IH_DW.DW_ODS_ACTIVITY oda
        WHERE oda.LAST_UPDATED_DATE >= p_start_date
          AND oda.LAST_UPDATED_DATE < p_end_date;
        
        IF v_total_records = 0 THEN
            RETURN 2; -- Default 2 hours if no data
        END IF;
        
        v_total_hours := (p_end_date - p_start_date) * 24;
        v_records_per_hour := v_total_records / v_total_hours;
        
        -- Calculate hours needed for target records per chunk
        v_optimal_hours := GREATEST(1, LEAST(24, p_target_records_per_chunk / v_records_per_hour));
        
        -- Round to reasonable values (1, 2, 4, 6, 8, 12, 24)
        IF v_optimal_hours <= 1.5 THEN
            RETURN 1;
        ELSIF v_optimal_hours <= 3 THEN
            RETURN 2;
        ELSIF v_optimal_hours <= 5 THEN
            RETURN 4;
        ELSIF v_optimal_hours <= 7 THEN
            RETURN 6;
        ELSIF v_optimal_hours <= 10 THEN
            RETURN 8;
        ELSIF v_optimal_hours <= 18 THEN
            RETURN 12;
        ELSE
            RETURN 24;
        END IF;
        
    EXCEPTION
        WHEN OTHERS THEN
            RETURN 2; -- Default fallback
    END calculate_optimal_chunk_size;
-- SECTION 5: Advanced Validation Functions and Package End (CORRECTED)

    FUNCTION validate_chunk_by_states(
        p_process_date DATE,
        p_max_records NUMBER DEFAULT 2000,
        p_chunk_offset NUMBER DEFAULT 0,
        p_chunk_size NUMBER DEFAULT 1000
    ) RETURN VARCHAR2 IS
        v_cursor SYS_REFCURSOR;
        v_record STATERPT_OWNER.GTT_RESULTS_EXTRACT%ROWTYPE;
        v_count NUMBER := 0;
        v_total_count NUMBER := 0;
        v_total_matched NUMBER := 0;
        v_total_unmatched NUMBER := 0;
        v_chunk_processed NUMBER := 0;
        
        -- Dynamic state array
        TYPE state_array_type IS TABLE OF VARCHAR2(2);
        v_states state_array_type;
        
        -- Validation summary variables
        v_state_results_count NUMBER;
        v_failed_results_count NUMBER;
        v_sent_results_count NUMBER;
        v_result VARCHAR2(4000);
        
    BEGIN
        log_message('INFO', 'Starting chunk validation - Offset: ' || p_chunk_offset || ', Size: ' || p_chunk_size);
        
        -- Populate states array using existing function
        DECLARE
            v_states_cursor SYS_REFCURSOR;
            v_state_abbrev VARCHAR2(2);
            v_state_name VARCHAR2(100);
        BEGIN
            v_states_cursor := condition_processor.get_active_states();
            v_states := state_array_type();
            
            LOOP
                FETCH v_states_cursor INTO v_state_abbrev, v_state_name;
                EXIT WHEN v_states_cursor%NOTFOUND;
                
                v_states.EXTEND;
                v_states(v_states.COUNT) := v_state_abbrev;
            END LOOP;
            
            CLOSE v_states_cursor;
        END;
        
        log_message('INFO', 'Processing ' || v_states.COUNT || ' active states for chunk');
        
        -- Loop through all states for this chunk
        FOR i IN 1..v_states.COUNT LOOP
            v_count := 0;
            v_state_results_count := 0;
            v_failed_results_count := 0;
            v_sent_results_count := 0;
            
            BEGIN
                -- Get filtered cursor for this state with chunk limits
                v_cursor := condition_processor.validate_results(
                    p_state_abbrev => v_states(i),
                    p_process_date => p_process_date,
                    p_max_records => p_max_records,
                    p_result_status_filter => 'F'
                );
                
                -- Process records for this state within chunk boundaries
                LOOP
                    FETCH v_cursor INTO v_record;
                    EXIT WHEN v_cursor%NOTFOUND;
                    
                    -- Skip records outside this chunk
                    IF v_chunk_processed < p_chunk_offset THEN
                        v_chunk_processed := v_chunk_processed + 1;
                        CONTINUE;
                    END IF;
                    
                    -- Stop if we've processed enough for this chunk
                    IF v_count >= p_chunk_size THEN
                        EXIT;
                    END IF;
                    
                    v_count := v_count + 1;
                    v_chunk_processed := v_chunk_processed + 1;
                    
                    -- Process individual record
                    DECLARE
                        v_exists_in_sent_log NUMBER;
                    BEGIN
                        -- Check if result exists in results_sent_log
                        SELECT COUNT(*)
                        INTO v_exists_in_sent_log
                        FROM results_sent_log
                        WHERE order_number = v_record.order_number
                        AND result_test_code = v_record.result_test_code;
                        
                        IF v_exists_in_sent_log > 0 THEN
                            v_sent_results_count := v_sent_results_count + 1;
                        ELSE
                            v_failed_results_count := v_failed_results_count + 1;
                            
                            -- MERGE into asr_process_run for unmatched records
                            MERGE INTO asr_process_run target
                            USING (
                                SELECT 
                                    v_record.order_number as order_number,
                                    v_record.order_test_code as order_test_code,
                                    v_record.result_test_code as result_test_code,
                                    v_record.performing_lab_id as performing_lab_id,
                                    v_record.textual_result_full as textual_result_full,
                                    v_record.patient_last_name as patient_last_name,
                                    v_states(i) as source,
                                    TO_CHAR(p_process_date, 'DD-MON-YY') as activitydate,
                                    'N' as complete
                                FROM DUAL
                            ) source ON (
                                target.order_number = source.order_number 
                                AND target.result_test_code = source.result_test_code
                            )
                            WHEN NOT MATCHED THEN
                                INSERT (
                                    order_number,
                                    order_test_code,
                                    result_test_code,
                                    performing_lab_id,
                                    textual_result_full,
                                    patient_last_name,
                                    source,
                                    activitydate,
                                    complete
                                ) VALUES (
                                    source.order_number,
                                    source.order_test_code,
                                    source.result_test_code,
                                    source.performing_lab_id,
                                    source.textual_result_full,
                                    source.patient_last_name,
                                    source.source,
                                    source.activitydate,
                                    source.complete
                                );
                        END IF;
                        
                    EXCEPTION
                        WHEN OTHERS THEN
                            log_message('ERROR', 'Error processing record ' || v_record.order_number || ': ' || SQLERRM);
                            v_failed_results_count := v_failed_results_count + 1;
                    END;
                    
                    -- Commit every 100 records to avoid long transactions
                    IF MOD(v_count, 100) = 0 THEN
                        COMMIT;
                    END IF;
                    
                END LOOP;
                
                CLOSE v_cursor;
                
                v_total_count := v_total_count + v_count;
                v_total_matched := v_total_matched + v_sent_results_count;
                v_total_unmatched := v_total_unmatched + v_failed_results_count;
                
                log_message('INFO', 'State ' || v_states(i) || ' - Processed: ' || v_count || 
                           ', Matched: ' || v_sent_results_count || ', Unmatched: ' || v_failed_results_count);
                
            EXCEPTION
                WHEN OTHERS THEN
                    log_message('ERROR', 'Error processing state ' || v_states(i) || ': ' || SQLERRM);
            END;
            
        END LOOP;
        
        COMMIT; -- Final commit for chunk
        
        v_result := 'Chunk processed - Total: ' || v_total_count || 
                    ', Matched: ' || v_total_matched || 
                    ', Unmatched: ' || v_total_unmatched || 
                    ', Match Rate: ' || ROUND((v_total_matched / GREATEST(v_total_count, 1)) * 100, 2) || '%';
        
        log_message('INFO', v_result);
        RETURN v_result;
        
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            v_result := 'ERROR in chunk validation: ' || SQLERRM;
            log_message('ERROR', v_result);
            RETURN v_result;
    END validate_chunk_by_states;

    FUNCTION process_chunk_state_validation_enhanced(
        p_process_date DATE,
        p_max_records NUMBER DEFAULT 2000,
        p_chunk_size NUMBER DEFAULT 1000
    ) RETURN VARCHAR2 IS
        v_total_gtt_records NUMBER;
        v_total_chunks NUMBER;
        v_chunk_result VARCHAR2(4000);
        v_overall_result VARCHAR2(4000);
        v_total_processed NUMBER := 0;
        v_total_matched NUMBER := 0;
        v_total_unmatched NUMBER := 0;
        
    BEGIN
        log_message('INFO', 'Starting enhanced state validation processing');
        log_message('INFO', 'Process Date: ' || TO_CHAR(p_process_date, 'DD-MON-YYYY'));
        
        -- Get total GTT records to determine chunk count
        SELECT COUNT(*) INTO v_total_gtt_records FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT;
        
        IF v_total_gtt_records = 0 THEN
            RETURN 'WARNING: No records found in GTT_RESULTS_EXTRACT';
        END IF;
        
        v_total_chunks := CEIL(v_total_gtt_records / p_chunk_size);
        
        log_message('INFO', 'Total GTT records: ' || v_total_gtt_records || 
                    ', Processing in ' || v_total_chunks || ' chunks of ' || p_chunk_size || ' records each');
        
        -- Process each chunk
        FOR chunk_num IN 1..v_total_chunks LOOP
            DECLARE
                v_chunk_offset NUMBER := (chunk_num - 1) * p_chunk_size;
            BEGIN
                log_message('INFO', 'Processing chunk ' || chunk_num || '/' || v_total_chunks);
                
                v_chunk_result := validate_chunk_by_states(
                    p_process_date => p_process_date,
                    p_max_records => p_max_records,
                    p_chunk_offset => v_chunk_offset,
                    p_chunk_size => p_chunk_size
                );
                
                log_message('INFO', 'Chunk ' || chunk_num || ' result: ' || v_chunk_result);
                
            EXCEPTION
                WHEN OTHERS THEN
                    log_message('ERROR', 'Error in chunk ' || chunk_num || ': ' || SQLERRM);
            END;
        END LOOP;
        
        -- Generate final summary
        SELECT 
            COUNT(*) as total_processed,
            SUM(CASE WHEN EXISTS (
                SELECT 1 FROM results_sent_log rsl 
                WHERE rsl.order_number = gre.order_number 
                AND rsl.result_test_code = gre.result_test_code
            ) THEN 1 ELSE 0 END) as total_matched
        INTO v_total_processed, v_total_matched
        FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT gre;
        
        v_total_unmatched := v_total_processed - v_total_matched;
        
        v_overall_result := 'VALIDATION COMPLETE - Processed: ' || v_total_processed || 
                           ', Matched: ' || v_total_matched || 
                           ', Unmatched: ' || v_total_unmatched || 
                           ', Overall Match Rate: ' || ROUND((v_total_matched / GREATEST(v_total_processed, 1)) * 100, 2) || '%';
        
        log_message('INFO', v_overall_result);
        RETURN v_overall_result;
        
    EXCEPTION
        WHEN OTHERS THEN
            v_overall_result := 'ERROR in enhanced state validation: ' || SQLERRM;
            log_message('ERROR', v_overall_result);
            RETURN v_overall_result;
    END process_chunk_state_validation_enhanced;

    FUNCTION initialize_and_validate_chunked(
        p_start_date DATE,
        p_end_date DATE,
        p_chunk_hours NUMBER DEFAULT 2,
        p_max_records NUMBER DEFAULT 2000,
        p_validation_chunk_size NUMBER DEFAULT 1000
    ) RETURN VARCHAR2 IS
        v_init_result VARCHAR2(4000);
        v_validation_result VARCHAR2(4000);
        v_final_result VARCHAR2(4000);
        v_process_date DATE := TRUNC(SYSDATE);
    BEGIN
        log_message('INFO', 'Starting integrated chunked population + validation');
        log_message('INFO', 'Process Date: ' || TO_CHAR(v_process_date, 'DD-MON-YYYY'));
        
        -- PHASE 1: Chunked GTT Population
        log_message('INFO', '=== PHASE 1: GTT POPULATION ===');
        v_init_result := initialize_session_chunked(p_start_date, p_end_date, p_chunk_hours);
        
        IF INSTR(v_init_result, 'ERROR') > 0 THEN
            RETURN 'INITIALIZATION FAILED: ' || v_init_result;
        END IF;
        
        log_message('INFO', 'GTT Population Result: ' || v_init_result);
        
        -- PHASE 2: State Validation Processing
        log_message('INFO', '=== PHASE 2: STATE VALIDATION ===');
        v_validation_result := process_chunk_state_validation_enhanced(
            p_process_date => v_process_date,
            p_max_records => p_max_records,
            p_chunk_size => p_validation_chunk_size
        );
        
        -- Generate final integrated result
        v_final_result := 'INTEGRATED PROCESSING COMPLETE - ' ||
                         'Init: ' || SUBSTR(v_init_result, 1, 100) || ' | ' ||
                         'Validation: ' || SUBSTR(v_validation_result, 1, 100);
        
        log_message('INFO', v_final_result);
        RETURN v_final_result;
        
    EXCEPTION
        WHEN OTHERS THEN
            v_final_result := 'ERROR in integrated processing: ' || SQLERRM;
            log_message('ERROR', v_final_result);
            RETURN v_final_result;
    END initialize_and_validate_chunked;

END condition_processor;
/
