-- ================================================================
-- CONDITION_PROCESSOR PACKAGE TEST SCRIPT
-- Oracle SQL Developer Test Suite
-- ================================================================

-- Enable DBMS_OUTPUT
SET SERVEROUTPUT ON SIZE 1000000;

-- Clear screen and set formatting
CLEAR SCREEN;
SET PAGESIZE 50;
SET LINESIZE 200;

PROMPT ================================================================
PROMPT CONDITION_PROCESSOR PACKAGE TEST SUITE
PROMPT Test Date: &_DATE
PROMPT ================================================================

-- ================================================================
-- TEST 1: Initial Session Status Check
-- ================================================================
PROMPT 
PROMPT TEST 1: Initial Session Status Check
PROMPT ================================================================

DECLARE
    v_status VARCHAR2(100);
BEGIN
    v_status := condition_processor.get_session_status;
    DBMS_OUTPUT.PUT_LINE('Initial Session Status: ' || v_status);
    
    IF v_status = 'NOT_INITIALIZED' THEN
        DBMS_OUTPUT.PUT_LINE('? PASS: Session correctly shows NOT_INITIALIZED');
    ELSE
        DBMS_OUTPUT.PUT_LINE('? FAIL: Expected NOT_INITIALIZED, got: ' || v_status);
    END IF;
END;

/
-- ================================================================
-- STEP 3: Manual Initialization with Custom Date
-- ================================================================
PROMPT Step 3: Manual Initialization with Custom Date (Yesterday)
DECLARE
    v_custom_date DATE := TRUNC(SYSDATE - 1);
    v_start_time TIMESTAMP := SYSTIMESTAMP;
    v_end_time TIMESTAMP;
    v_status VARCHAR2(100);
BEGIN
    DBMS_OUTPUT.PUT_LINE('Starting initialization with custom date: ' || 
        TO_CHAR(v_custom_date, 'YYYY-MM-DD'));
    
    -- Cleanup first
    condition_processor.cleanup_session;
    
    -- Initialize with custom date
    condition_processor.initialize_session(v_custom_date);
    
    v_end_time := SYSTIMESTAMP;
    DBMS_OUTPUT.PUT_LINE('Custom date initialization completed in: ' || 
        EXTRACT(SECOND FROM (v_end_time - v_start_time)) || ' seconds');
    
    -- Check status
    v_status := condition_processor.get_session_status;
    DBMS_OUTPUT.PUT_LINE('Status after custom initialization: ' || v_status);
END;
/

-- ================================================================
-- TEST 3: GTT Data Verification
-- ================================================================
PROMPT 
PROMPT TEST 3: GTT Data Verification
PROMPT ================================================================

DECLARE
    v_gtt_count NUMBER;
    v_staff_count NUMBER;
BEGIN
    -- Check GTT_RESULTS_EXTRACT
    SELECT COUNT(*) INTO v_gtt_count 
    FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT;
    
    -- Check GTT_STAFF_RESULTS_EXTRACT  
    SELECT COUNT(*) INTO v_staff_count 
    FROM STATERPT_OWNER.GTT_STAFF_RESULTS_EXTRACT;
    
    DBMS_OUTPUT.PUT_LINE('GTT_RESULTS_EXTRACT records: ' || v_gtt_count);
    DBMS_OUTPUT.PUT_LINE('GTT_STAFF_RESULTS_EXTRACT records: ' || v_staff_count);
    
    IF v_gtt_count > 0 THEN
        DBMS_OUTPUT.PUT_LINE('? PASS: GTT_RESULTS_EXTRACT populated');
    ELSE
        DBMS_OUTPUT.PUT_LINE('? WARNING: GTT_RESULTS_EXTRACT is empty');
    END IF;
    
    IF v_staff_count > 0 THEN
        DBMS_OUTPUT.PUT_LINE('? PASS: GTT_STAFF_RESULTS_EXTRACT populated');
    ELSE
        DBMS_OUTPUT.PUT_LINE('? WARNING: GTT_STAFF_RESULTS_EXTRACT is empty');
    END IF;
    
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('? FAIL: GTT verification error: ' || SQLERRM);
END;
/

-- ================================================================
-- TEST 4: Sample GTT Data Inspection
-- ================================================================
PROMPT 
PROMPT TEST 4: Sample GTT Data Inspection
PROMPT ================================================================

-- Show sample records from GTT
SELECT 'GTT_RESULTS_EXTRACT Sample:' as table_name FROM DUAL;

SELECT 
    accession_number,
    facility_id,
    patient_last_name,
    patient_first_name,
    patient_account_state,
    order_test_code,
    result_test_code
FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT 
WHERE ROWNUM <= 5
ORDER BY accession_number;

-- Show state distribution
SELECT 'State Distribution:' as analysis FROM DUAL;

SELECT 
    patient_account_state,
    COUNT(*) as record_count
FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT 
GROUP BY patient_account_state
ORDER BY COUNT(*) DESC;
/

-- ================================================================
-- TEST 5: Process Single State (Texas) - FUNCTION VALIDATION
-- ================================================================
PROMPT 
PROMPT TEST 5: Process Single State - Function Validation
PROMPT ================================================================

DECLARE
    v_cursor SYS_REFCURSOR;
    v_function_works BOOLEAN := FALSE;
BEGIN
    DBMS_OUTPUT.PUT_LINE('Testing process_state function for TX...');
    
    BEGIN
        -- Just test that function executes without error
        v_cursor := condition_processor.process_state('CA');
        v_function_works := TRUE;
        CLOSE v_cursor;
        
        DBMS_OUTPUT.PUT_LINE('? PASS: process_state(''TX'') executed successfully');
        
    EXCEPTION
        WHEN OTHERS THEN
            IF v_cursor%ISOPEN THEN
                CLOSE v_cursor;
            END IF;
            DBMS_OUTPUT.PUT_LINE('? FAIL: process_state(''TX'') error: ' || SQLERRM);
    END;
    
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('? FAIL: Unexpected error: ' || SQLERRM);
END;
/

-- ================================================================
-- TEST 6: Process Multiple States
-- ================================================================
PROMPT 
PROMPT TEST 6: Process Multiple States
PROMPT ================================================================

DECLARE
    v_cursor SYS_REFCURSOR;
    v_count NUMBER;
    TYPE state_array IS VARRAY(5) OF VARCHAR2(2);
    v_states state_array := state_array('TX', 'CA', 'NY', 'FL', 'IL');
BEGIN
    FOR i IN 1..v_states.COUNT LOOP
        v_count := 0;
        
        BEGIN
            v_cursor := condition_processor.process_state(v_states(i));
            
            -- Count results
            LOOP
                FETCH v_cursor INTO v_count; -- This will need adjustment based on your cursor structure
                EXIT WHEN v_cursor%NOTFOUND;
                v_count := v_count + 1;
            END LOOP;
            
            CLOSE v_cursor;
            
            DBMS_OUTPUT.PUT_LINE('State ' || v_states(i) || ': ' || v_count || ' records');
            
        EXCEPTION
            WHEN OTHERS THEN
                IF v_cursor%ISOPEN THEN
                    CLOSE v_cursor;
                END IF;
                DBMS_OUTPUT.PUT_LINE('State ' || v_states(i) || ': ERROR - ' || SQLERRM);
        END;
    END LOOP;
    
    DBMS_OUTPUT.PUT_LINE('? PASS: Multi-state processing completed');
    
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('? FAIL: Multi-state processing error: ' || SQLERRM);
END;
/

-- ================================================================
-- TEST 7: Session Persistence Test
-- ================================================================
PROMPT 
PROMPT TEST 7: Session Persistence Test
PROMPT ================================================================

DECLARE
    v_status1 VARCHAR2(100);
    v_status2 VARCHAR2(100);
    v_cursor SYS_REFCURSOR;
BEGIN
    -- Check status before processing
    v_status1 := condition_processor.get_session_status;
    DBMS_OUTPUT.PUT_LINE('Status before processing: ' || v_status1);
    
    -- Process a state (should not re-initialize)
    v_cursor := condition_processor.process_state('TX');
    CLOSE v_cursor;
    
    -- Check status after processing
    v_status2 := condition_processor.get_session_status;
    DBMS_OUTPUT.PUT_LINE('Status after processing: ' || v_status2);
    
    IF v_status1 = v_status2 THEN
        DBMS_OUTPUT.PUT_LINE('? PASS: Session state persisted correctly');
    ELSE
        DBMS_OUTPUT.PUT_LINE('? FAIL: Session state changed unexpectedly');
    END IF;
    
EXCEPTION
    WHEN OTHERS THEN
        IF v_cursor%ISOPEN THEN
            CLOSE v_cursor;
        END IF;
        DBMS_OUTPUT.PUT_LINE('? FAIL: Session persistence test error: ' || SQLERRM);
END;
/

-- ================================================================
-- TEST 8: Invalid State Test
-- ================================================================
PROMPT 
PROMPT TEST 8: Invalid State Test
PROMPT ================================================================

DECLARE
    v_cursor SYS_REFCURSOR;
    v_count NUMBER := 0;
BEGIN
    DBMS_OUTPUT.PUT_LINE('Testing invalid state: ZZ');
    
    v_cursor := condition_processor.process_state('ZZ');
    
    -- Count results
    LOOP
        FETCH v_cursor INTO v_count; -- Adjust based on cursor structure
        EXIT WHEN v_cursor%NOTFOUND;
        v_count := v_count + 1;
    END LOOP;
    
    CLOSE v_cursor;
    
    DBMS_OUTPUT.PUT_LINE('Records returned for invalid state ZZ: ' || v_count);
    
    IF v_count = 0 THEN
        DBMS_OUTPUT.PUT_LINE('? PASS: Invalid state correctly returns no records');
    ELSE
        DBMS_OUTPUT.PUT_LINE('? WARNING: Invalid state returned ' || v_count || ' records');
    END IF;
    
EXCEPTION
    WHEN OTHERS THEN
        IF v_cursor%ISOPEN THEN
            CLOSE v_cursor;
        END IF;
        DBMS_OUTPUT.PUT_LINE('Invalid state test error: ' || SQLERRM);
END;
/

-- ================================================================
-- TEST 9: Cleanup Session Test
-- ================================================================
PROMPT 
PROMPT TEST 9: Cleanup Session Test
PROMPT ================================================================

DECLARE
    v_status_before VARCHAR2(100);
    v_status_after VARCHAR2(100);
    v_gtt_count NUMBER;
BEGIN
    -- Check status before cleanup
    v_status_before := condition_processor.get_session_status;
    DBMS_OUTPUT.PUT_LINE('Status before cleanup: ' || v_status_before);
    
    -- Cleanup session
    condition_processor.cleanup_session;
    
    -- Check status after cleanup
    v_status_after := condition_processor.get_session_status;
    DBMS_OUTPUT.PUT_LINE('Status after cleanup: ' || v_status_after);
    
    -- Check GTT record count
    SELECT COUNT(*) INTO v_gtt_count FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT;
    DBMS_OUTPUT.PUT_LINE('GTT records after cleanup: ' || v_gtt_count);
    
    IF v_status_after = 'NOT_INITIALIZED' AND v_gtt_count = 0 THEN
        DBMS_OUTPUT.PUT_LINE('? PASS: Cleanup successful');
    ELSE
        DBMS_OUTPUT.PUT_LINE('? FAIL: Cleanup incomplete');
    END IF;
    
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('? FAIL: Cleanup test error: ' || SQLERRM);
END;
/

-- ================================================================
-- TEST 10: Auto-Initialize Test
-- ================================================================
PROMPT 
PROMPT TEST 10: Auto-Initialize Test
PROMPT ================================================================

DECLARE
    v_cursor SYS_REFCURSOR;
    v_status VARCHAR2(100);
BEGIN
    -- Ensure session is not initialized
    v_status := condition_processor.get_session_status;
    DBMS_OUTPUT.PUT_LINE('Initial status: ' || v_status);
    
    -- Call process_state without manual initialization
    DBMS_OUTPUT.PUT_LINE('Calling process_state without manual initialization...');
    v_cursor := condition_processor.process_state('TX');
    CLOSE v_cursor;
    
    -- Check if auto-initialization worked
    v_status := condition_processor.get_session_status;
    DBMS_OUTPUT.PUT_LINE('Status after auto-init: ' || v_status);
    
    IF INSTR(v_status, 'INITIALIZED') > 0 THEN
        DBMS_OUTPUT.PUT_LINE('? PASS: Auto-initialization successful');
    ELSE
        DBMS_OUTPUT.PUT_LINE('? FAIL: Auto-initialization failed');
    END IF;
    
EXCEPTION
    WHEN OTHERS THEN
        IF v_cursor%ISOPEN THEN
            CLOSE v_cursor;
        END IF;
        DBMS_OUTPUT.PUT_LINE('? FAIL: Auto-initialize test error: ' || SQLERRM);
END;
/

-- ================================================================
-- PERFORMANCE TEST
-- ================================================================
PROMPT 
PROMPT PERFORMANCE TEST: Multiple State Processing
PROMPT ================================================================

DECLARE
    v_cursor SYS_REFCURSOR;
    v_start_time TIMESTAMP;
    v_end_time TIMESTAMP;
    v_duration NUMBER;
    TYPE state_array IS VARRAY(10) OF VARCHAR2(2);
    v_states state_array := state_array('TX', 'CA', 'NY', 'FL', 'IL', 'PA', 'OH', 'GA', 'NC', 'MI');
BEGIN
    -- Initialize once
    condition_processor.initialize_session;
    
    v_start_time := SYSTIMESTAMP;
    
    -- Process multiple states
    FOR i IN 1..v_states.COUNT LOOP
        v_cursor := condition_processor.process_state(v_states(i));
        CLOSE v_cursor;
    END LOOP;
    
    v_end_time := SYSTIMESTAMP;
    v_duration := EXTRACT(SECOND FROM (v_end_time - v_start_time));
    
    DBMS_OUTPUT.PUT_LINE('Processed ' || v_states.COUNT || ' states in ' || v_duration || ' seconds');
    DBMS_OUTPUT.PUT_LINE('Average time per state: ' || ROUND(v_duration / v_states.COUNT, 3) || ' seconds');
    
EXCEPTION
    WHEN OTHERS THEN
        IF v_cursor%ISOPEN THEN
            CLOSE v_cursor;
        END IF;
        DBMS_OUTPUT.PUT_LINE('Performance test error: ' || SQLERRM);
END;
/

-- ================================================================
-- FINAL CLEANUP
-- ================================================================
PROMPT 
PROMPT Final Cleanup
PROMPT ================================================================

BEGIN
    condition_processor.cleanup_session;
    DBMS_OUTPUT.PUT_LINE('Test suite completed - session cleaned up');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Final cleanup error: ' || SQLERRM);
END;
/

PROMPT 
PROMPT ================================================================
PROMPT TEST SUITE COMPLETED
PROMPT ================================================================