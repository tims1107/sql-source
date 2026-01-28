-- ========================================================================
-- MULTI-STATE VALIDATION TEST FOR CONDITION_PROCESSOR PACKAGE
-- ========================================================================
-- This test validates results across all active states using the initialized
-- GTT_RESULTS_EXTRACT table, similar to the single state test but iterating
-- through all configured states
-- ========================================================================

-- Test 6.2: Validate results for ALL active states (limited records per state)
-- Enhanced with asr_process_run MERGE operations
DECLARE
    v_states_cursor SYS_REFCURSOR;
    v_results_cursor SYS_REFCURSOR;
    v_record STATERPT_OWNER.GTT_RESULTS_EXTRACT%ROWTYPE;
    
    v_state_abbrev VARCHAR2(2);
    v_state_name VARCHAR2(100);
    v_count NUMBER := 0;
    v_total_count NUMBER := 0;
    v_state_count NUMBER := 0;
    v_max_records_per_state NUMBER := 10000; -- Limit per state for testing
    v_process_date DATE := TRUNC(SYSDATE - 1);
    
    -- Track asr_process_run operations
    v_inserted_count NUMBER := 0;
    v_updated_count NUMBER := 0;
    v_total_inserted NUMBER := 0;
    v_total_updated NUMBER := 0;
    
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== Testing Results Validation for ALL Active States ===');
    DBMS_OUTPUT.PUT_LINE('Process Date: ' || TO_CHAR(v_process_date, 'YYYY-MM-DD'));
    DBMS_OUTPUT.PUT_LINE('Max Records Per State: ' || v_max_records_per_state);
    DBMS_OUTPUT.PUT_LINE('========================================');
    
    -- Ensure session is initialized first
    IF NOT STATERPT_OWNER.condition_processor.get_session_status() LIKE '%INITIALIZED%' THEN
        DBMS_OUTPUT.PUT_LINE('Initializing session...');
        STATERPT_OWNER.condition_processor.initialize_session(SYSDATE);
    END IF;
    
    -- Get all active states
    v_states_cursor := STATERPT_OWNER.condition_processor.get_active_states();
    
    -- Loop through each active state
    LOOP
        FETCH v_states_cursor INTO v_state_abbrev, v_state_name;
        EXIT WHEN v_states_cursor%NOTFOUND;
        
        v_state_count := v_state_count + 1;
        v_count := 0;
        
        DBMS_OUTPUT.PUT_LINE('--- State ' || v_state_count || ': ' || v_state_abbrev || ' (' || v_state_name || ') ---');
        
        BEGIN
            -- Get validation results for this state
            v_results_cursor := STATERPT_OWNER.condition_processor.validate_results(
                p_state_abbrev => v_state_abbrev,
                p_process_date => v_process_date,
                p_max_records => v_max_records_per_state,
                p_result_status_filter => 'F'
            );
            
            -- Process results for this state
            v_inserted_count := 0;
            v_updated_count := 0;
            
            LOOP
                FETCH v_results_cursor INTO v_record;
                EXIT WHEN v_results_cursor%NOTFOUND;
                
                v_count := v_count + 1;
                
                -- Show first 5 records per state for visibility
                IF v_count <= 5 THEN
                    DBMS_OUTPUT.PUT_LINE('  Record ' || v_count || ': Order=' || v_record.order_number || 
                                       ', Test=' || v_record.result_test_code || 
                                       ', Patient=' || v_record.patient_last_name ||
                                       ', Facility=' || v_record.facility_name);
                END IF;
                
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
                        v_state_abbrev as source,
                        TO_CHAR(v_process_date, 'DD-MON-YY') as activitydate,
                        'N' as complete
                    FROM DUAL
                ) source ON (
                    target.order_number = source.order_number 
                    AND target.result_test_code = source.result_test_code
                    AND target.source = source.source
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
                    )
                WHEN MATCHED THEN
                    UPDATE SET
                        order_test_code = source.order_test_code,
                        performing_lab_id = source.performing_lab_id,
                        textual_result_full = source.textual_result_full,
                        patient_last_name = source.patient_last_name,
                        activitydate = source.activitydate;
                        -- do not update complete data
                        --complete = source.complete;
                
                -- Track insert vs update operations
                IF SQL%ROWCOUNT > 0 THEN
                    -- Check if it was an insert or update by looking at the merge operation
                    -- Since we can't directly detect insert vs update in MERGE, we'll count total operations
                    IF v_count = 1 THEN
                        -- For first record, check if record existed before
                        DECLARE
                            v_exists NUMBER;
                        BEGIN
                            SELECT COUNT(*) INTO v_exists
                            FROM asr_process_run
                            WHERE order_number = v_record.order_number
                            AND result_test_code = v_record.result_test_code
                            AND source = v_state_abbrev;
                            
                            IF v_exists > 0 THEN
                                v_updated_count := v_updated_count + 1;
                            ELSE
                                v_inserted_count := v_inserted_count + 1;
                            END IF;
                        END;
                    ELSE
                        -- For subsequent records, assume insert (most common case)
                        v_inserted_count := v_inserted_count + 1;
                    END IF;
                END IF;
                
            END LOOP;
            
            CLOSE v_results_cursor;
            
            v_total_count := v_total_count + v_count;
            v_total_inserted := v_total_inserted + v_inserted_count;
            v_total_updated := v_total_updated + v_updated_count;
            
            DBMS_OUTPUT.PUT_LINE('  State ' || v_state_abbrev || ' Total: ' || v_count || ' records');
            DBMS_OUTPUT.PUT_LINE('    ASR_PROCESS_RUN - Inserted: ' || v_inserted_count || ', Updated: ' || v_updated_count);
            
        EXCEPTION
            WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE('  ERROR processing state ' || v_state_abbrev || ': ' || SQLERRM);
                IF v_results_cursor%ISOPEN THEN
                    CLOSE v_results_cursor;
                END IF;
        END;
        
        -- Add separator for readability
        IF MOD(v_state_count, 5) = 0 THEN
            DBMS_OUTPUT.PUT_LINE('----------------------------------------');
        END IF;
        
    END LOOP;
    
    CLOSE v_states_cursor;
    
    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('MULTI-STATE VALIDATION SUMMARY:');
    DBMS_OUTPUT.PUT_LINE('Total States Processed: ' || v_state_count);
    DBMS_OUTPUT.PUT_LINE('Total Records Found: ' || v_total_count);
    DBMS_OUTPUT.PUT_LINE('Average Records Per State: ' || ROUND(v_total_count / GREATEST(v_state_count, 1), 2));
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('ASR_PROCESS_RUN OPERATIONS:');
    DBMS_OUTPUT.PUT_LINE('Total Records Inserted: ' || v_total_inserted);
    DBMS_OUTPUT.PUT_LINE('Total Records Updated: ' || v_total_updated);
    DBMS_OUTPUT.PUT_LINE('Total ASR Operations: ' || (v_total_inserted + v_total_updated));
    DBMS_OUTPUT.PUT_LINE('');
    
    -- Clean up single 310 order test codes after all processing
    DBMS_OUTPUT.PUT_LINE('Cleaning up invalid 310 records (single results)...');
    
    DELETE FROM asr_process_run 
    WHERE activitydate = TO_CHAR(v_process_date, 'DD-MON-YY')
    AND order_test_code = '310'
    AND (order_number, order_test_code) IN (
        SELECT order_number, order_test_code
        FROM asr_process_run
        WHERE activitydate = TO_CHAR(v_process_date, 'DD-MON-YY')
        AND order_test_code = '310'
        GROUP BY order_number, order_test_code
        HAVING COUNT(1) = 1
    );
    
    DBMS_OUTPUT.PUT_LINE('Deleted ' || SQL%ROWCOUNT || ' invalid 310 records (orders with single results)');
    
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Changes committed to database');
    DBMS_OUTPUT.PUT_LINE('========================================');
    
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('ERROR in multi-state validation: ' || SQLERRM);
        IF v_states_cursor%ISOPEN THEN
            CLOSE v_states_cursor;
        END IF;
        IF v_results_cursor%ISOPEN THEN
            CLOSE v_results_cursor;
        END IF;
END;
/