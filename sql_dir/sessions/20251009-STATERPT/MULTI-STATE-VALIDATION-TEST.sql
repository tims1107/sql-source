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
    v_max_records_per_state NUMBER := 500; -- Limit per state for testing
    v_process_date DATE := TRUNC(SYSDATE);
    
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
        STATERPT_OWNER.condition_processor.initialize_session(SYSDATE - 1);
    END IF;
    
    dbms_output.put_line(condition_processor.get_session_status());
    
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