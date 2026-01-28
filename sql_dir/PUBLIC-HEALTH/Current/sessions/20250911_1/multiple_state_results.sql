-- test new 310 rule
DECLARE
    v_cursor SYS_REFCURSOR;
    v_record STATERPT_OWNER.GTT_RESULTS_EXTRACT%ROWTYPE;
    v_count NUMBER := 0;
    v_total_count NUMBER := 0;
    v_total_matched NUMBER := 0;
    v_total_unmatched NUMBER := 0;
    v_process_date DATE := TRUNC(SYSDATE - 1);
    v_process number := 0;
    
    -- Dynamic state array populated from state_master table
    TYPE state_array_type IS TABLE OF VARCHAR2(2);
    v_states state_array_type;
    
    -- Validation summary variables
    v_state_results_count NUMBER;
    v_failed_results_count NUMBER;
    v_sent_results_count NUMBER;
    
    
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== COMPREHENSIVE VALIDATION FOR ALL STATES ===');
    DBMS_OUTPUT.PUT_LINE('Process Date: ' || TO_CHAR(v_process_date, 'DD-MON-YYYY'));
    DBMS_OUTPUT.PUT_LINE('');
    
    -- Populate states array using condition_processor package function
    DECLARE
        v_states_cursor SYS_REFCURSOR;
        v_state_abbrev VARCHAR2(2);
        v_state_name VARCHAR2(100);
        v_single_state VARCHAR2(2) := 'TX';
        
    BEGIN
        v_states_cursor := condition_processor.get_active_states();
        
        -- Initialize collection
        v_states := state_array_type();
        
        LOOP
            FETCH v_states_cursor INTO v_state_abbrev, v_state_name;
            EXIT WHEN v_states_cursor%NOTFOUND;
            IF (v_state_abbrev = v_single_state) THEN
                v_states.EXTEND;
                v_states(1) := v_single_state;
            END IF;
            
        END LOOP;
        
        CLOSE v_states_cursor;
    END;
    
    DBMS_OUTPUT.PUT_LINE('Found ' || v_states.COUNT || ' active states to validate');
    DBMS_OUTPUT.PUT_LINE('');
    
    -- Loop through all states
    FOR i IN 1..1 LOOP
        v_count := 0;
        v_state_results_count := 0;
        v_failed_results_count := 0;
        v_sent_results_count := 0;
        
        BEGIN
            -- Validate results for current state with 'F' (Final) status filter
--            v_cursor := condition_processor.validate_results(
--                p_state_abbrev => v_states(i),
--                p_process_date => v_process_date,
--                p_result_status_filter => 'F'
--            );
            
            -- Get filtered cursor directly
        v_cursor := condition_processor.filter_310_validation(
            p_state_abbrev => v_states(i),
            p_process_date => v_process_date,
            p_result_status_filter => 'F'
        );
            
            DBMS_OUTPUT.PUT_LINE('--- STATE: ' || v_states(i) || ' (Final Results) ---');
            
            LOOP
                FETCH v_cursor INTO v_record;
                EXIT WHEN v_cursor%NOTFOUND;
                
--                v_process := condition_processor.is_valid_310_record(
--                v_record.order_number,
--                v_record.order_test_code,
--                v_states(i),
--                v_process_date);
--                
--                IF (v_process) THEN 
                
                --dbms_output.put_line('Not skipped..... ' || to_char(v_process));
                v_count := v_count + 1;
                
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
--                        WHEN MATCHED THEN
--                            UPDATE SET
--                                target.order_test_code = source.order_test_code,
--                                target.performing_lab_id = source.performing_lab_id,
--                                target.textual_result_full = source.textual_result_full,
--                                target.patient_last_name = source.patient_last_name,
--                                target.source = source.source,
--                                target.activitydate = source.activitydate,
--                                target.complete = 'Z'
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
                    
                  
                    
                    -- Display first 5 results for each state
                    IF v_count <= 35 THEN
                        DBMS_OUTPUT.PUT_LINE('  Result ' || v_count || ': ' || 
                            NVL(TO_CHAR(v_record.order_number), 'NULL') || ' | ' || 
                            NVL(TO_CHAR(v_record.order_test_code), 'NULL') || ' | ' || 
                            NVL(TO_CHAR(v_record.result_test_code), 'NULL') || ' | ' ||
                            NVL(TO_CHAR(v_record.result_status), 'NULL') || ' | ' ||
                            NVL(SUBSTR(v_record.textual_result, 1, 20), 'NULL') || ' | ' ||
                            CASE WHEN v_exists_in_sent_log > 0 THEN 'IN_SENT_LOG' ELSE 'NOT_IN_SENT_LOG' END);
                    END IF;
                EXCEPTION
                    WHEN OTHERS THEN
                        DBMS_OUTPUT.PUT_LINE('  ERROR checking record ' || v_count || ': ' || SQLERRM);
                        v_failed_results_count := v_failed_results_count + 1;
                END;
                
               
            END LOOP;
            
            CLOSE v_cursor;
            
            -- Display summary for this state
            DBMS_OUTPUT.PUT_LINE('  Summary - Total Final Results: ' || v_count || 
                               ', Found in sent_log: ' || v_sent_results_count || 
                               ', Missing from sent_log: ' || v_failed_results_count || 
                               ', Match Rate: ' || ROUND((v_sent_results_count / GREATEST(v_count, 1)) * 100, 1) || '%');
            
            v_total_count := v_total_count + v_count;
            v_total_matched := v_total_matched + v_sent_results_count;
            v_total_unmatched := v_total_unmatched + v_failed_results_count;
            
        EXCEPTION
            WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE('  ERROR for state ' || v_states(i) || ': ' || SQLERRM);
        END;
        
        DBMS_OUTPUT.PUT_LINE('');
    END LOOP;
    
    DBMS_OUTPUT.PUT_LINE('=== OVERALL SUMMARY ===');
    DBMS_OUTPUT.PUT_LINE('States processed: ' || v_states.COUNT);
    DBMS_OUTPUT.PUT_LINE('Total records processed: ' || v_total_count);
    DBMS_OUTPUT.PUT_LINE('Total matched in sent_log: ' || v_total_matched);
    DBMS_OUTPUT.PUT_LINE('Total missing from sent_log: ' || v_total_unmatched);
    DBMS_OUTPUT.PUT_LINE('Overall match rate: ' || ROUND((v_total_matched / GREATEST(v_total_count, 1)) * 100, 2) || '%');
    
END;
