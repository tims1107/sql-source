-- Check the exact structure of GTT_RESULTS_EXTRACT table
SELECT column_name, data_type, data_length, nullable
FROM user_tab_columns 
WHERE table_name = 'GTT_RESULTS_EXTRACT'
ORDER BY column_id;

-- Count total columns
SELECT COUNT(*) as total_columns
FROM user_tab_columns 
WHERE table_name = 'GTT_RESULTS_EXTRACT';

-- Generate the correct type definition
SELECT 'CREATE OR REPLACE TYPE t_gtt_result_record AS OBJECT (' as line_1
FROM dual
UNION ALL
SELECT '    ' || column_name || ' ' || 
       CASE 
           WHEN data_type = 'VARCHAR2' THEN 'VARCHAR2(' || data_length || ')'
           WHEN data_type = 'NUMBER' THEN 'NUMBER'
           WHEN data_type = 'DATE' THEN 'DATE'
           WHEN data_type = 'CLOB' THEN 'CLOB'
           ELSE data_type
       END || 
       CASE WHEN column_id < (SELECT MAX(column_id) FROM user_tab_columns WHERE table_name = 'GTT_RESULTS_EXTRACT') 
            THEN ',' 
            ELSE '' 
       END as type_definition
FROM user_tab_columns 
WHERE table_name = 'GTT_RESULTS_EXTRACT'
ORDER BY column_id;

/

-- Corrected nested table types matching exact GTT_RESULTS_EXTRACT structure (79 columns)
DROP TYPE t_gtt_result_table FORCE;
DROP TYPE t_gtt_result_record FORCE;

CREATE OR REPLACE TYPE t_gtt_result_record AS OBJECT (
    accession_number VARCHAR2(30),
    facility_id VARCHAR2(30),
    cid VARCHAR2(5),
    ethnic_group VARCHAR2(100),
    patient_race VARCHAR2(100),
    external_mrn VARCHAR2(50),
    patient_last_name VARCHAR2(128),
    patient_first_name VARCHAR2(128),
    patient_middle_name VARCHAR2(128),
    date_of_birth DATE,
    gender VARCHAR2(10),
    patient_ssn VARCHAR2(11),
    npi VARCHAR2(15),
    ordering_physician_name VARCHAR2(150),
    report_notes VARCHAR2(4000),
    specimen_receive_date DATE,
    collection_date DATE,
    collection_time VARCHAR2(10),
    collection_date_time DATE,
    draw_freq VARCHAR2(20),
    res_rprt_status_chng_dt_time DATE,
    order_detail_status VARCHAR2(10),
    order_test_code VARCHAR2(50),
    order_test_name VARCHAR2(100),
    result_test_code VARCHAR2(50),
    result_test_name VARCHAR2(100),
    result_status VARCHAR2(10),
    textual_result VARCHAR2(4000),
    textual_result_full VARCHAR2(4000),
    numeric_result NUMBER,
    units VARCHAR2(20),
    reference_range VARCHAR2(25),
    abnormal_flag VARCHAR2(20),
    release_date_time DATE,
    result_comments CLOB,
    performing_lab_id VARCHAR2(50),
    order_method VARCHAR2(25),
    specimen_source VARCHAR2(500),
    order_number VARCHAR2(50),
    logging_site VARCHAR2(10),
    age NUMBER,
    facility_name VARCHAR2(100),
    cond_code VARCHAR2(20),
    patient_type VARCHAR2(20),
    source_of_comment VARCHAR2(100),
    patient_id VARCHAR2(50),
    alternate_patient_id VARCHAR2(100),
    requisition_status VARCHAR2(2),
    facility_address1 VARCHAR2(200),
    facility_address2 VARCHAR2(200),
    facility_city VARCHAR2(100),
    facility_state VARCHAR2(30),
    facility_zip VARCHAR2(15),
    facility_phone VARCHAR2(20),
    patient_account_address1 VARCHAR2(420),
    patient_account_address2 VARCHAR2(100),
    patient_account_city VARCHAR2(200),
    patient_account_state VARCHAR2(200),
    patient_account_zip VARCHAR2(15),
    patient_home_phone VARCHAR2(20),
    loinc_code VARCHAR2(100),
    loinc_name VARCHAR2(500),
    value_type VARCHAR2(10),
    east_west_flag VARCHAR2(2),
    internal_external_flag CHAR(1),
    last_update_time TIMESTAMP(6),
    sequence_no NUMBER,
    facility_account_status VARCHAR2(20),
    facility_active_flag CHAR(1),
    micro_isolate VARCHAR2(100),
    micro_organism_name VARCHAR2(4000),
    lab_fk NUMBER,
    clinical_manager VARCHAR2(400),
    medical_director VARCHAR2(400),
    acti_facility_id VARCHAR2(30),
    fmc_number VARCHAR2(30),
    reportable_state VARCHAR2(30),
    source_state VARCHAR2(30),
    device_name VARCHAR2(32)
);
/

CREATE OR REPLACE TYPE t_gtt_result_table AS TABLE OF t_gtt_result_record;
/

-- Test the corrected types
DECLARE
    v_test_record t_gtt_result_record;
    v_test_table t_gtt_result_table := t_gtt_result_table();
BEGIN
    -- Test with correct number of arguments (79 NULLs)
    v_test_record := t_gtt_result_record(
        NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,  -- 1-10
        NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,  -- 11-20
        NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,  -- 21-30
        NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,  -- 31-40
        NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,  -- 41-50
        NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,  -- 51-60
        NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,  -- 61-70
        NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL        -- 71-79
    );
    
    v_test_table.EXTEND;
    v_test_table(1) := v_test_record;
    
    DBMS_OUTPUT.PUT_LINE('? CORRECTED TYPES CREATED SUCCESSFULLY - 79 columns');
    
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('? ERROR: ' || SQLERRM);
END;
/

-- Test new 310 rule - Refactored with nested table deduplication approach
DECLARE
    v_build_cursor SYS_REFCURSOR;
    v_validation_cursor SYS_REFCURSOR;
    v_record STATERPT_OWNER.GTT_RESULTS_EXTRACT%ROWTYPE;
    v_build_count NUMBER := 0;
    v_validation_count NUMBER := 0;
    v_total_count NUMBER := 0;
    v_total_matched NUMBER := 0;
    v_total_unmatched NUMBER := 0;
    v_process_date DATE := TRUNC(SYSDATE - 1);
    
    -- Dynamic state array populated from state_master table
    TYPE state_array_type IS TABLE OF VARCHAR2(2);
    v_states state_array_type;
    
    -- Validation summary variables
    v_state_results_count NUMBER;
    v_failed_results_count NUMBER;
    v_sent_results_count NUMBER;
    
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== COMPREHENSIVE 310 VALIDATION FOR ALL STATES (NESTED TABLE APPROACH) ===');
    DBMS_OUTPUT.PUT_LINE('Process Date: ' || TO_CHAR(v_process_date, 'DD-MON-YYYY'));
    DBMS_OUTPUT.PUT_LINE('');
    
    -- Initialize session
    BEGIN
        condition_processor.initialize_session(v_process_date);
        DBMS_OUTPUT.PUT_LINE('Session initialized: ' || condition_processor.get_session_status());
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('ERROR initializing session: ' || SQLERRM);
            RETURN;
    END;
    
    -- Populate states array using condition_processor package function
    DECLARE
        v_states_cursor SYS_REFCURSOR;
        v_state_abbrev VARCHAR2(2);
        v_state_name VARCHAR2(100);
        v_single_state VARCHAR2(2) := 'NC';
        
    BEGIN
        v_states_cursor := condition_processor.get_active_states();
        
        -- Initialize collection
        v_states := state_array_type();
        
        LOOP
            FETCH v_states_cursor INTO v_state_abbrev, v_state_name;
            EXIT WHEN v_states_cursor%NOTFOUND;
            IF (v_state_abbrev = v_single_state) THEN
                v_states.EXTEND;
                v_states(v_states.COUNT) := v_single_state;
                EXIT; -- Only need NC for this test
            END IF;
        END LOOP;
        
        CLOSE v_states_cursor;
    END;
    
    DBMS_OUTPUT.PUT_LINE('Found ' || v_states.COUNT || ' active states to validate');
    DBMS_OUTPUT.PUT_LINE('');
    
    -- Loop through all states
    FOR i IN 1..v_states.COUNT LOOP
        v_build_count := 0;
        v_validation_count := 0;
        v_state_results_count := 0;
        v_failed_results_count := 0;
        v_sent_results_count := 0;
        
        DBMS_OUTPUT.PUT_LINE('--- STATE: ' || v_states(i) || ' (USING NESTED TABLE DEDUPLICATION) ---');
        
        BEGIN
            -- STEP 1: Get build cursor (all filtered results) - USING NEW NESTED TABLE FUNCTION
            DBMS_OUTPUT.PUT_LINE('  STEP 1: Build Cursor (All Filtered Results - Deduplicated via Nested Tables)');
            v_build_cursor := condition_processor.process_state_nested(
                p_state_abbrev => v_states(i),
                p_process_date => v_process_date
            );
            
            -- Count build cursor results
            LOOP
                FETCH v_build_cursor INTO v_record;
                EXIT WHEN v_build_cursor%NOTFOUND;
                v_build_count := v_build_count + 1;
                
                -- Display first 5 build results
                IF v_build_count <= 35 THEN
                    DBMS_OUTPUT.PUT_LINE('    Build ' || v_build_count || ': ' || 
                        NVL(TO_CHAR(v_record.order_number), 'NULL') || ' | ' || 
                        NVL(TO_CHAR(v_record.order_test_code), 'NULL') || ' | ' || 
                        NVL(TO_CHAR(v_record.result_test_code), 'NULL') || ' | ' ||
                        NVL(TO_CHAR(v_record.result_status), 'NULL'));
                END IF;
            END LOOP;
            CLOSE v_build_cursor;
            
            DBMS_OUTPUT.PUT_LINE('    Build cursor total (deduplicated): ' || v_build_count);
            
            -- STEP 2: Get 310 validation cursor (filtered results)
            DBMS_OUTPUT.PUT_LINE('  STEP 2: 310 Validation Cursor (310-Validated Results)');
            v_validation_cursor := condition_processor.filter_310_validation(
                p_state_abbrev => v_states(i),
                p_process_date => v_process_date,
                p_result_status_filter => 'F'
            );
            
            -- Process validation cursor results
            LOOP
                FETCH v_validation_cursor INTO v_record;
                EXIT WHEN v_validation_cursor%NOTFOUND;
                
                v_validation_count := v_validation_count + 1;
                
                -- Check if this result exists in results_sent_log
                DECLARE
                    v_exists_in_sent_log NUMBER;
                BEGIN
                    SELECT COUNT(*)
                    INTO v_exists_in_sent_log
                    FROM results_sent_log
                    WHERE order_number = v_record.order_number
                    AND result_test_code = v_record.result_test_code;
                    
                    IF v_exists_in_sent_log > 0 THEN
                        v_sent_results_count := v_sent_results_count + 1;
                    ELSE
                        v_failed_results_count := v_failed_results_count + 1; 
                        
                        -- MERGE statement to insert/update asr_process_run
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
                                TO_CHAR(v_process_date, 'DD-MON-YY') as activitydate,
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
                    
                    -- Display first 35 validation results
                    IF v_validation_count <= 35 THEN
                        DBMS_OUTPUT.PUT_LINE('    Valid ' || v_validation_count || ': ' || 
                            NVL(TO_CHAR(v_record.order_number), 'NULL') || ' | ' || 
                            NVL(TO_CHAR(v_record.order_test_code), 'NULL') || ' | ' || 
                            NVL(TO_CHAR(v_record.result_test_code), 'NULL') || ' | ' ||
                            NVL(TO_CHAR(v_record.result_status), 'NULL') || ' | ' ||
                            NVL(SUBSTR(v_record.textual_result, 1, 20), 'NULL') || ' | ' ||
                            CASE WHEN v_exists_in_sent_log > 0 THEN 'IN_SENT_LOG' ELSE 'NOT_IN_SENT_LOG' END);
                    END IF;
                    
                EXCEPTION
                    WHEN OTHERS THEN
                        DBMS_OUTPUT.PUT_LINE('    ERROR checking record ' || v_validation_count || ': ' || SQLERRM);
                        v_failed_results_count := v_failed_results_count + 1;
                END;
            END LOOP;
            
            CLOSE v_validation_cursor;
            
            -- Calculate filtering statistics
            DECLARE
                v_filtered_count NUMBER := v_build_count - v_validation_count;
                v_filter_percentage NUMBER := 0;
            BEGIN
                IF v_build_count > 0 THEN
                    v_filter_percentage := ROUND((v_filtered_count / v_build_count) * 100, 2);
                END IF;
                
                DBMS_OUTPUT.PUT_LINE('  FILTERING ANALYSIS (WITH NESTED TABLE DEDUPLICATION):');
                DBMS_OUTPUT.PUT_LINE('    Build cursor results (deduplicated): ' || v_build_count);
                DBMS_OUTPUT.PUT_LINE('    Validation cursor results: ' || v_validation_count);
                DBMS_OUTPUT.PUT_LINE('    Records filtered by 310 validation: ' || v_filtered_count);
                DBMS_OUTPUT.PUT_LINE('    Filter percentage: ' || v_filter_percentage || '%');
            END;
            
            -- Display summary for this state
            DBMS_OUTPUT.PUT_LINE('  SUMMARY - Total 310-Valid Results: ' || v_validation_count || 
                               ', Found in sent_log: ' || v_sent_results_count || 
                               ', Missing from sent_log: ' || v_failed_results_count || 
                               ', Match Rate: ' || ROUND((v_sent_results_count / GREATEST(v_validation_count, 1)) * 100, 1) || '%');
            
            v_total_count := v_total_count + v_validation_count;
            v_total_matched := v_total_matched + v_sent_results_count;
            v_total_unmatched := v_total_unmatched + v_failed_results_count;
            
        EXCEPTION
            WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE('  ERROR for state ' || v_states(i) || ': ' || SQLERRM);
                IF v_build_cursor%ISOPEN THEN
                    CLOSE v_build_cursor;
                END IF;
                IF v_validation_cursor%ISOPEN THEN
                    CLOSE v_validation_cursor;
                END IF;
        END;
        
        DBMS_OUTPUT.PUT_LINE('');
    END LOOP;
    
    DBMS_OUTPUT.PUT_LINE('=== OVERALL SUMMARY (NESTED TABLE APPROACH) ===');
    DBMS_OUTPUT.PUT_LINE('States processed: ' || v_states.COUNT);
    DBMS_OUTPUT.PUT_LINE('Total 310-validated records processed: ' || v_total_count);
    DBMS_OUTPUT.PUT_LINE('Total matched in sent_log: ' || v_total_matched);
    DBMS_OUTPUT.PUT_LINE('Total missing from sent_log: ' || v_total_unmatched);
    DBMS_OUTPUT.PUT_LINE('Overall match rate: ' || ROUND((v_total_matched / GREATEST(v_total_count, 1)) * 100, 2) || '%');
    DBMS_OUTPUT.PUT_LINE('NOTE: Results are now properly deduplicated using nested table approach');
    
    -- Cleanup session
    BEGIN
        condition_processor.cleanup_session();
        DBMS_OUTPUT.PUT_LINE('Session cleaned up successfully');
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('WARNING: Session cleanup failed: ' || SQLERRM);
    END;
    
END;
/

-- Test new 310 rule - Refactored with nested table deduplication approach
DECLARE
    v_build_cursor SYS_REFCURSOR;
    v_validation_cursor SYS_REFCURSOR;
    v_record STATERPT_OWNER.GTT_RESULTS_EXTRACT%ROWTYPE;
    v_build_count NUMBER := 0;
    v_validation_count NUMBER := 0;
    v_total_count NUMBER := 0;
    v_total_matched NUMBER := 0;
    v_total_unmatched NUMBER := 0;
    v_process_date DATE := TRUNC(SYSDATE - 1);
    
    -- Dynamic state array populated from state_master table
    TYPE state_array_type IS TABLE OF VARCHAR2(2);
    v_states state_array_type;
    
    -- Validation summary variables
    v_state_results_count NUMBER;
    v_failed_results_count NUMBER;
    v_sent_results_count NUMBER;
    
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== COMPREHENSIVE 310 VALIDATION FOR ALL STATES (NESTED TABLE APPROACH) ===');
    DBMS_OUTPUT.PUT_LINE('Process Date: ' || TO_CHAR(v_process_date, 'DD-MON-YYYY'));
    DBMS_OUTPUT.PUT_LINE('');
    
    -- Initialize session
    BEGIN
        condition_processor.initialize_session(v_process_date);
        DBMS_OUTPUT.PUT_LINE('Session initialized: ' || condition_processor.get_session_status());
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('ERROR initializing session: ' || SQLERRM);
            RETURN;
    END;
    
    -- Populate states array using condition_processor package function
    DECLARE
        v_states_cursor SYS_REFCURSOR;
        v_state_abbrev VARCHAR2(2);
        v_state_name VARCHAR2(100);
        v_single_state VARCHAR2(2) := 'NC';
        
    BEGIN
        v_states_cursor := condition_processor.get_active_states();
        
        -- Initialize collection
        v_states := state_array_type();
        
        LOOP
            FETCH v_states_cursor INTO v_state_abbrev, v_state_name;
            EXIT WHEN v_states_cursor%NOTFOUND;
            IF (v_state_abbrev = v_single_state) THEN
                v_states.EXTEND;
                v_states(v_states.COUNT) := v_single_state;
                EXIT; -- Only need NC for this test
            END IF;
        END LOOP;
        
        CLOSE v_states_cursor;
    END;
    
    DBMS_OUTPUT.PUT_LINE('Found ' || v_states.COUNT || ' active states to validate');
    DBMS_OUTPUT.PUT_LINE('');
    
    -- Loop through all states
    FOR i IN 1..v_states.COUNT LOOP
        v_build_count := 0;
        v_validation_count := 0;
        v_state_results_count := 0;
        v_failed_results_count := 0;
        v_sent_results_count := 0;
        
        DBMS_OUTPUT.PUT_LINE('--- STATE: ' || v_states(i) || ' (USING NESTED TABLE DEDUPLICATION) ---');
        
        BEGIN
            -- STEP 1: Get build cursor (all filtered results) - USING NEW NESTED TABLE FUNCTION
            DBMS_OUTPUT.PUT_LINE('  STEP 1: Build Cursor (All Filtered Results - Deduplicated via Nested Tables)');
            v_build_cursor := condition_processor.process_state_nested(
                p_state_abbrev => v_states(i),
                p_process_date => v_process_date
            );
            
            -- Count build cursor results
            LOOP
                FETCH v_build_cursor INTO v_record;
                EXIT WHEN v_build_cursor%NOTFOUND;
                v_build_count := v_build_count + 1;
                
                -- Display first 5 build results
                IF v_build_count <= 35 THEN
                    DBMS_OUTPUT.PUT_LINE('    Build ' || v_build_count || ': ' || 
                        NVL(TO_CHAR(v_record.order_number), 'NULL') || ' | ' || 
                        NVL(TO_CHAR(v_record.order_test_code), 'NULL') || ' | ' || 
                        NVL(TO_CHAR(v_record.result_test_code), 'NULL') || ' | ' ||
                        NVL(TO_CHAR(v_record.result_status), 'NULL'));
                END IF;
            END LOOP;
            CLOSE v_build_cursor;
            
            DBMS_OUTPUT.PUT_LINE('    Build cursor total (deduplicated): ' || v_build_count);
            
            -- STEP 2: Get 310 validation cursor (filtered results)
            DBMS_OUTPUT.PUT_LINE('  STEP 2: 310 Validation Cursor (310-Validated Results)');
            v_validation_cursor := condition_processor.filter_310_validation(
                p_state_abbrev => v_states(i),
                p_process_date => v_process_date,
                p_result_status_filter => 'F'
            );
            
            -- Process validation cursor results
            LOOP
                FETCH v_validation_cursor INTO v_record;
                EXIT WHEN v_validation_cursor%NOTFOUND;
                
                v_validation_count := v_validation_count + 1;
                
                -- Check if this result exists in results_sent_log
                DECLARE
                    v_exists_in_sent_log NUMBER;
                BEGIN
                    SELECT COUNT(*)
                    INTO v_exists_in_sent_log
                    FROM results_sent_log
                    WHERE order_number = v_record.order_number
                    AND result_test_code = v_record.result_test_code;
                    
                    IF v_exists_in_sent_log > 0 THEN
                        v_sent_results_count := v_sent_results_count + 1;
                    ELSE
                        v_failed_results_count := v_failed_results_count + 1; 
                        
                        -- MERGE statement to insert/update asr_process_run
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
                                TO_CHAR(v_process_date, 'DD-MON-YY') as activitydate,
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
                    
                    -- Display first 35 validation results
                    IF v_validation_count <= 35 THEN
                        DBMS_OUTPUT.PUT_LINE('    Valid ' || v_validation_count || ': ' || 
                            NVL(TO_CHAR(v_record.order_number), 'NULL') || ' | ' || 
                            NVL(TO_CHAR(v_record.order_test_code), 'NULL') || ' | ' || 
                            NVL(TO_CHAR(v_record.result_test_code), 'NULL') || ' | ' ||
                            NVL(TO_CHAR(v_record.result_status), 'NULL') || ' | ' ||
                            NVL(SUBSTR(v_record.textual_result, 1, 20), 'NULL') || ' | ' ||
                            CASE WHEN v_exists_in_sent_log > 0 THEN 'IN_SENT_LOG' ELSE 'NOT_IN_SENT_LOG' END);
                    END IF;
                    
                EXCEPTION
                    WHEN OTHERS THEN
                        DBMS_OUTPUT.PUT_LINE('    ERROR checking record ' || v_validation_count || ': ' || SQLERRM);
                        v_failed_results_count := v_failed_results_count + 1;
                END;
            END LOOP;
            
            CLOSE v_validation_cursor;
            
            -- Calculate filtering statistics
            DECLARE
                v_filtered_count NUMBER := v_build_count - v_validation_count;
                v_filter_percentage NUMBER := 0;
            BEGIN
                IF v_build_count > 0 THEN
                    v_filter_percentage := ROUND((v_filtered_count / v_build_count) * 100, 2);
                END IF;
                
                DBMS_OUTPUT.PUT_LINE('  FILTERING ANALYSIS (WITH NESTED TABLE DEDUPLICATION):');
                DBMS_OUTPUT.PUT_LINE('    Build cursor results (deduplicated): ' || v_build_count);
                DBMS_OUTPUT.PUT_LINE('    Validation cursor results: ' || v_validation_count);
                DBMS_OUTPUT.PUT_LINE('    Records filtered by 310 validation: ' || v_filtered_count);
                DBMS_OUTPUT.PUT_LINE('    Filter percentage: ' || v_filter_percentage || '%');
            END;
            
            -- Display summary for this state
            DBMS_OUTPUT.PUT_LINE('  SUMMARY - Total 310-Valid Results: ' || v_validation_count || 
                               ', Found in sent_log: ' || v_sent_results_count || 
                               ', Missing from sent_log: ' || v_failed_results_count || 
                               ', Match Rate: ' || ROUND((v_sent_results_count / GREATEST(v_validation_count, 1)) * 100, 1) || '%');
            
            v_total_count := v_total_count + v_validation_count;
            v_total_matched := v_total_matched + v_sent_results_count;
            v_total_unmatched := v_total_unmatched + v_failed_results_count;
            
        EXCEPTION
            WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE('  ERROR for state ' || v_states(i) || ': ' || SQLERRM);
                IF v_build_cursor%ISOPEN THEN
                    CLOSE v_build_cursor;
                END IF;
                IF v_validation_cursor%ISOPEN THEN
                    CLOSE v_validation_cursor;
                END IF;
        END;
        
        DBMS_OUTPUT.PUT_LINE('');
    END LOOP;
    
    DBMS_OUTPUT.PUT_LINE('=== OVERALL SUMMARY (NESTED TABLE APPROACH) ===');
    DBMS_OUTPUT.PUT_LINE('States processed: ' || v_states.COUNT);
    DBMS_OUTPUT.PUT_LINE('Total 310-validated records processed: ' || v_total_count);
    DBMS_OUTPUT.PUT_LINE('Total matched in sent_log: ' || v_total_matched);
    DBMS_OUTPUT.PUT_LINE('Total missing from sent_log: ' || v_total_unmatched);
    DBMS_OUTPUT.PUT_LINE('Overall match rate: ' || ROUND((v_total_matched / GREATEST(v_total_count, 1)) * 100, 2) || '%');
    DBMS_OUTPUT.PUT_LINE('NOTE: Results are now properly deduplicated using nested table approach');
    
    -- Cleanup session
    BEGIN
        condition_processor.cleanup_session();
        DBMS_OUTPUT.PUT_LINE('Session cleaned up successfully');
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('WARNING: Session cleanup failed: ' || SQLERRM);
    END;
    
END;
/


