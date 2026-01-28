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

-- Test basic type functionality
DECLARE
    v_test_table t_gtt_result_table := t_gtt_result_table();
BEGIN
    DBMS_OUTPUT.PUT_LINE('Types created successfully - test passed');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Type test failed: ' || SQLERRM);
END;
/

-- Create standalone functions instead of package functions to avoid dependency issues

-- Function 1: Simplified get_base_condition_sql (no deduplication)
CREATE OR REPLACE FUNCTION get_base_condition_sql_simple(
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
            RETURN 'SELECT gtt.* FROM GTT_RESULTS_EXTRACT gtt WHERE 1=0';
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
        RETURN 'SELECT gtt.* FROM GTT_RESULTS_EXTRACT gtt WHERE 1=0';
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
        
        v_condition_sql := condition_processor.build_condition_filter_sql(
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
            -- Simple UNION ALL - no deduplication here
            v_final_sql := v_final_sql || ' UNION ALL ' || v_condition_sql || chr(10);
        END IF;
    END LOOP;
    
    DBMS_OUTPUT.PUT_LINE('Built ' || v_condition_count || ' conditions for state ' || p_state_abbrev);
    
    IF v_condition_count > 0 THEN
        -- Return simple query with state and date filters - no deduplication
        RETURN 'SELECT * FROM (' || v_final_sql || ') base ' ||
               'WHERE patient_account_state = ''' || p_state_abbrev || '''' ||
               ' AND TRUNC(release_date_time) = DATE ''' || TO_CHAR(p_process_date, 'YYYY-MM-DD') || '''';
    ELSE
        RETURN 'SELECT gtt.* FROM GTT_RESULTS_EXTRACT gtt WHERE 1=0';
    END IF;
    
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error in get_base_condition_sql_simple: ' || SQLERRM);
        RAISE;
END get_base_condition_sql_simple;
/

-- Function 2: Load cursor into nested table
CREATE OR REPLACE FUNCTION load_cursor_to_table(
    p_state_abbrev VARCHAR2,
    p_process_date DATE
) RETURN t_gtt_result_table IS
    v_results t_gtt_result_table := t_gtt_result_table();
    v_cursor SYS_REFCURSOR;
    v_sql CLOB;
    v_record t_gtt_result_record;
BEGIN
    -- Get the SQL without deduplication
    v_sql := get_base_condition_sql_simple(p_state_abbrev, p_process_date);
    
    -- Open cursor and fetch all records
    OPEN v_cursor FOR v_sql;
    
    LOOP
        FETCH v_cursor INTO 
            v_record.accession_number, v_record.facility_id, v_record.cid,
            v_record.ethnic_group, v_record.patient_race, v_record.mrn,
            v_record.patient_last_name, v_record.patient_first_name, v_record.patient_middle_name,
            v_record.date_of_birth, v_record.gender, v_record.patient_ssn,
            v_record.npi, v_record.ordering_physician_name, v_record.report_notes,
            v_record.specimen_receive_date, v_record.collection_date, v_record.collection_time,
            v_record.collection_date_time, v_record.draw_freq, v_record.res_rprt_status_chng_dt_time,
            v_record.order_detail_status, v_record.order_test_code, v_record.order_test_name,
            v_record.result_test_code, v_record.result_test_name, v_record.result_status,
            v_record.textual_result, v_record.textual_result_full, v_record.numeric_result,
            v_record.units, v_record.reference_range, v_record.abnormal_flag,
            v_record.release_date_time, v_record.result_comments, v_record.performing_lab_id,
            v_record.order_method, v_record.specimen_source, v_record.order_number,
            v_record.logging_site, v_record.age, v_record.facility_name,
            v_record.cond_code, v_record.patient_type, v_record.source_of_comment,
            v_record.patient_id, v_record.alternate_patient_id, v_record.requisition_status,
            v_record.facility_address1, v_record.facility_address2, v_record.facility_city,
            v_record.facility_state, v_record.facility_zip, v_record.facility_phone,
            v_record.patient_account_address1, v_record.patient_account_address2, v_record.patient_account_city,
            v_record.patient_account_state, v_record.patient_account_zip, v_record.patient_home_phone,
            v_record.loinc_code, v_record.loinc_name, v_record.value_type,
            v_record.east_west_flag, v_record.internal_external_flag, v_record.last_update_time,
            v_record.sequence_no, v_record.facility_account_status, v_record.facility_active_flag,
            v_record.micro_isolate, v_record.micro_organism_name, v_record.lab_fk,
            v_record.clinical_manager, v_record.medical_director, v_record.acti_facility_id,
            v_record.fmc_number, v_record.reportable_state, v_record.source_state,
            v_record.device_name;
            
        EXIT WHEN v_cursor%NOTFOUND;
        
        -- Add to collection
        v_results.EXTEND;
        v_results(v_results.COUNT) := v_record;
    END LOOP;
    
    CLOSE v_cursor;
    
    DBMS_OUTPUT.PUT_LINE('Loaded ' || v_results.COUNT || ' records into nested table');
    RETURN v_results;
    
EXCEPTION
    WHEN OTHERS THEN
        IF v_cursor%ISOPEN THEN
            CLOSE v_cursor;
        END IF;
        RAISE;
END load_cursor_to_table;
/

-- Function 3: Deduplication function using nested table
CREATE OR REPLACE FUNCTION deduplicate_results(
    p_results t_gtt_result_table
) RETURN t_gtt_result_table PIPELINED IS
    v_seen_keys VARCHAR2(32767) := '|';
    v_key VARCHAR2(200);
    v_result t_gtt_result_record;
BEGIN
    -- Loop through all results
    FOR i IN 1..p_results.COUNT LOOP
        v_result := p_results(i);
        
        -- Create unique key for deduplication (order_number + result_test_code)
        v_key := '|' || v_result.order_number || '_' || v_result.result_test_code || '|';
        
        -- Check if we've seen this key before
        IF INSTR(v_seen_keys, v_key) = 0 THEN
            -- New record - add to seen keys and pipe out
            v_seen_keys := v_seen_keys || v_key;
            PIPE ROW(v_result);
        END IF;
    END LOOP;
    
    RETURN;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error in deduplicate_results: ' || SQLERRM);
        RAISE;
END deduplicate_results;
/

-- Function 4: Main processing function using nested table approach
CREATE OR REPLACE FUNCTION process_state_nested(
    p_state_abbrev VARCHAR2, 
    p_process_date DATE DEFAULT TRUNC(SYSDATE)
) RETURN SYS_REFCURSOR IS
    v_cursor SYS_REFCURSOR;
    v_results t_gtt_result_table;
BEGIN
    -- Check if session is initialized
    IF condition_processor.get_session_status() != 'INITIALIZED' THEN
        condition_processor.initialize_session(p_process_date);
    END IF;
    
    -- Step 1: Load all matching records into nested table
    v_results := load_cursor_to_table(p_state_abbrev, p_process_date);
    
    -- Step 2: Return deduplicated results as cursor
    OPEN v_cursor FOR
        SELECT * FROM TABLE(deduplicate_results(v_results));
    
    RETURN v_cursor;
    
EXCEPTION
    WHEN OTHERS THEN
        IF v_cursor%ISOPEN THEN
            CLOSE v_cursor;
        END IF;
        RAISE;
END process_state_nested;
/

-- Debug the nested table initialization issue
DECLARE
    v_test_record t_gtt_result_record;
    v_test_table t_gtt_result_table := t_gtt_result_table();
    v_cursor SYS_REFCURSOR;
    v_sql CLOB;
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== DEBUGGING NESTED TABLE INITIALIZATION ===');
    
    -- Test 1: Can we create an empty record?
    BEGIN
        v_test_record := t_gtt_result_record(
            NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
            NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
            NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
            NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
            NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
            NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
            NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
            NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
        );
        DBMS_OUTPUT.PUT_LINE('? Test 1 PASSED: Can create empty record');
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('? Test 1 FAILED: Cannot create empty record: ' || SQLERRM);
            RETURN;
    END;
    
    -- Test 2: Can we add record to table?
    BEGIN
        v_test_table.EXTEND;
        v_test_table(1) := v_test_record;
        DBMS_OUTPUT.PUT_LINE('? Test 2 PASSED: Can add record to table');
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('? Test 2 FAILED: Cannot add record to table: ' || SQLERRM);
            RETURN;
    END;
    
    -- Test 3: Can we fetch from a simple cursor?
    BEGIN
        v_sql := 'SELECT * FROM GTT_RESULTS_EXTRACT WHERE ROWNUM <= 1';
        OPEN v_cursor FOR v_sql;
        
        FETCH v_cursor INTO 
            v_test_record.accession_number, v_test_record.facility_id, v_test_record.cid,
            v_test_record.ethnic_group, v_test_record.patient_race, v_test_record.mrn,
            v_test_record.patient_last_name, v_test_record.patient_first_name, v_test_record.patient_middle_name,
            v_test_record.date_of_birth, v_test_record.gender, v_test_record.patient_ssn,
            v_test_record.npi, v_test_record.ordering_physician_name, v_test_record.report_notes,
            v_test_record.specimen_receive_date, v_test_record.collection_date, v_test_record.collection_time,
            v_test_record.collection_date_time, v_test_record.draw_freq, v_test_record.res_rprt_status_chng_dt_time,
            v_test_record.order_detail_status, v_test_record.order_test_code, v_test_record.order_test_name,
            v_test_record.result_test_code, v_test_record.result_test_name, v_test_record.result_status,
            v_test_record.textual_result, v_test_record.textual_result_full, v_test_record.numeric_result,
            v_test_record.units, v_test_record.reference_range, v_test_record.abnormal_flag,
            v_test_record.release_date_time, v_test_record.result_comments, v_test_record.performing_lab_id,
            v_test_record.order_method, v_test_record.specimen_source, v_test_record.order_number,
            v_test_record.logging_site, v_test_record.age, v_test_record.facility_name,
            v_test_record.cond_code, v_test_record.patient_type, v_test_record.source_of_comment,
            v_test_record.patient_id, v_test_record.alternate_patient_id, v_test_record.requisition_status,
            v_test_record.facility_address1, v_test_record.facility_address2, v_test_record.facility_city,
            v_test_record.facility_state, v_test_record.facility_zip, v_test_record.facility_phone,
            v_test_record.patient_account_address1, v_test_record.patient_account_address2, v_test_record.patient_account_city,
            v_test_record.patient_account_state, v_test_record.patient_account_zip, v_test_record.patient_home_phone,
            v_test_record.loinc_code, v_test_record.loinc_name, v_test_record.value_type,
            v_test_record.east_west_flag, v_test_record.internal_external_flag, v_test_record.last_update_time,
            v_test_record.sequence_no, v_test_record.facility_account_status, v_test_record.facility_active_flag,
            v_test_record.micro_isolate, v_test_record.micro_organism_name, v_test_record.lab_fk,
            v_test_record.clinical_manager, v_test_record.medical_director, v_test_record.acti_facility_id,
            v_test_record.fmc_number, v_test_record.reportable_state, v_test_record.source_state,
            v_test_record.device_name;
            
        IF v_cursor%FOUND THEN
            DBMS_OUTPUT.PUT_LINE('? Test 3 PASSED: Can fetch into record from cursor');
            DBMS_OUTPUT.PUT_LINE('  Sample data: ' || NVL(v_test_record.order_number, 'NULL') || ' | ' || NVL(v_test_record.result_test_code, 'NULL'));
        ELSE
            DBMS_OUTPUT.PUT_LINE('? Test 3 INFO: No data found in GTT_RESULTS_EXTRACT');
        END IF;
        
        CLOSE v_cursor;
        
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('? Test 3 FAILED: Cannot fetch from cursor: ' || SQLERRM);
            IF v_cursor%ISOPEN THEN
                CLOSE v_cursor;
            END IF;
            RETURN;
    END;
    
    DBMS_OUTPUT.PUT_LINE('=== ALL TESTS PASSED - NESTED TABLE TYPES ARE WORKING ===');
    
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('FATAL ERROR: ' || SQLERRM);
END;
/


