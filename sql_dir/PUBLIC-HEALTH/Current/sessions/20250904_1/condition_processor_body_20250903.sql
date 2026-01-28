CREATE OR REPLACE PACKAGE BODY condition_processor AS
    -- Package variables
    g_session_initialized BOOLEAN := FALSE;
    g_gtt_record_count NUMBER := 0;
    
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
            
            -- Debug output
--            DBMS_OUTPUT.PUT_LINE('Condition ' || p_condition_id || ':');
--            DBMS_OUTPUT.PUT_LINE('  Original filter: ' || p_filter);
--            DBMS_OUTPUT.PUT_LINE('  Value Type: ' || NVL(p_value_type, 'NULL'));
--            DBMS_OUTPUT.PUT_LINE('  Raw Value: ' || NVL(p_condition_value, 'NULL'));
--            DBMS_OUTPUT.PUT_LINE('  Formatted Value: ' || v_formatted_value);
--            DBMS_OUTPUT.PUT_LINE('  Final filter: ' || v_processed_filter);
            
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
    
 -- ================================================================
-- IMPROVED get_base_condition_sql FUNCTION
-- Dynamically loads test codes from condition_master table
-- Replaces original hardcoded REGEXP_LIKE approach
-- ================================================================

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
            v_final_sql := v_final_sql || ' UNION ALL ' || v_condition_sql;
        END IF;
    END LOOP;
    
    DBMS_OUTPUT.PUT_LINE('Built ' || v_condition_count || ' conditions for state ' || p_state_abbrev);
    
    IF v_condition_count > 0 THEN
        RETURN 'SELECT * FROM (' || v_final_sql || ') ' ||
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



--    FUNCTION get_base_condition_sql(
--        p_state_abbrev VARCHAR2,
--        p_process_date DATE
--    ) RETURN CLOB IS
--        v_final_sql CLOB := '';
--        v_condition_sql VARCHAR2(4000);
--        v_condition_count NUMBER := 0;
--    BEGIN
--        FOR rec IN (
--            SELECT 
--                cm.condition_master_pk,
--                cm.order_test_code,
--                cm.result_test_code,
--                cm.condition_value,
--                cm.value_type,
--                cf.filter
--            FROM CONDITION_MASTER cm
--            JOIN CONDITION_FILTERS cf ON cm.condition_filter_fk = cf.condition_filter_pk
--            WHERE cm.state_fk = (SELECT state_master_pk FROM state_master WHERE state_abbreviation = p_state_abbrev)
--            AND cm.status = 'active'
--            AND cf.status = 'active'
--            AND REGEXP_LIKE(cm.order_test_code, '^(301|303|304|310|311|319N|312|318|332|336|322|315|317L|323|327)$')
--            ORDER BY cm.condition_master_pk
--        ) LOOP
--            v_condition_count := v_condition_count + 1;
--            
--            v_condition_sql := build_condition_filter_sql(
--                rec.condition_master_pk,
--                rec.order_test_code,
--                rec.result_test_code,
--                rec.filter,
--                rec.condition_value,
--                rec.value_type
--            );
--            
--            IF v_condition_count = 1 THEN
--                v_final_sql := v_condition_sql;
--            ELSE
--                v_final_sql := v_final_sql || ' UNION ALL ' || v_condition_sql;
--            END IF;
--        END LOOP;
--        
--        IF v_condition_count > 0 THEN
--            RETURN 'SELECT * FROM (' || v_final_sql || ') ' ||
--                   'WHERE patient_account_state = ''' || p_state_abbrev || '''' ||
--                   ' AND TRUNC(release_date_time) = DATE ''' || TO_CHAR(p_process_date, 'YYYY-MM-DD') || '''';
--        ELSE
--            RETURN 'SELECT gtt.*, 0 as condition_master_pk FROM GTT_RESULTS_EXTRACT gtt WHERE 1=0';
--        END IF;
--        
--    EXCEPTION
--        WHEN OTHERS THEN
--            DBMS_OUTPUT.PUT_LINE('Error in get_base_condition_sql: ' || SQLERRM);
--            RAISE;
--    END get_base_condition_sql;
    
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
    
    -- Build status filter if provided
    IF p_result_status_filter IS NOT NULL THEN
        v_status_filter := ' AND result_status = ''' || p_result_status_filter || '''';
        DBMS_OUTPUT.PUT_LINE('Applying result status filter: ' || p_result_status_filter);
    END IF;
    
    -- Build final SQL with 310 validation using SELECT *
    v_final_sql := 'SELECT * FROM (' || v_base_sql || ') base ' ||
        'WHERE 1=1 ' || v_status_filter ||
        -- Add 310 validation: exclude records where order_test_code 310 has only 1 result_test_code
        ' AND (base.order_test_code != ''310'' OR ' ||
        '      (SELECT COUNT(DISTINCT result_test_code) ' ||
        '       FROM (' || v_base_sql || ') check_310 ' ||
        '       WHERE check_310.accession_number = base.accession_number ' ||
        '       AND check_310.order_test_code = ''310'') != 1) ' ||
        'AND ROWNUM <= ' || p_max_records ||
        ' ORDER BY accession_number, order_test_code, result_test_code';
    
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
    
END condition_processor;