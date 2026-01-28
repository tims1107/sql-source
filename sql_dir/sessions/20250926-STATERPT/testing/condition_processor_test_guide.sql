-- ========================================================================
-- CONDITION_PROCESSOR PACKAGE TESTING GUIDE FOR ORACLE SQL DEVELOPER
-- ========================================================================
-- This guide provides step-by-step testing procedures for the corrected
-- condition_processor package body using Oracle SQL Developer
-- ========================================================================

-- PREREQUISITES:
-- 1. Package specification and body must be compiled successfully
-- 2. User must have appropriate grants on IH_DW schema tables
-- 3. GTT tables must exist in STATERPT_OWNER schema
-- 4. Optional: condition_processor_log table for logging

-- ========================================================================
-- STEP 1: VERIFY PACKAGE COMPILATION STATUS
-- ========================================================================

-- Check if package specification exists and is valid
SELECT object_name, object_type, status, last_ddl_time
FROM user_objects 
WHERE object_name = 'CONDITION_PROCESSOR'
ORDER BY object_type;

-- Expected output: Two rows (PACKAGE and PACKAGE BODY) with STATUS = 'VALID'

-- ========================================================================
-- STEP 2: BASIC FUNCTIONALITY TESTS
-- ========================================================================

-- Test 2.1: Check session status (should be uninitialized initially)
DECLARE
    v_status VARCHAR2(4000);
BEGIN
    v_status := STATERPT_OWNER.condition_processor.get_session_status();
    DBMS_OUTPUT.PUT_LINE('Session Status: ' || v_status);
END;
/

-- Test 2.2: Test helper function - filter safety
DECLARE
    v_safe_filter VARCHAR2(100) := 'ORDER_TEST_CODE = ''123''';
    v_unsafe_filter VARCHAR2(100) := 'ORDER_TEST_CODE = ''123''; DROP TABLE test;';
    v_result BOOLEAN;
BEGIN
    -- Test safe filter
    v_result := STATERPT_OWNER.condition_processor.is_filter_safe(v_safe_filter);
    DBMS_OUTPUT.PUT_LINE('Safe filter test: ' || CASE WHEN v_result THEN 'PASS' ELSE 'FAIL' END);
    
    -- Test unsafe filter
    v_result := STATERPT_OWNER.condition_processor.is_filter_safe(v_unsafe_filter);
    DBMS_OUTPUT.PUT_LINE('Unsafe filter test: ' || CASE WHEN NOT v_result THEN 'PASS' ELSE 'FAIL' END);
END;
/

-- ========================================================================
-- STEP 3: SESSION INITIALIZATION TESTS
-- ========================================================================

-- Test 3.1: Standard session initialization (last 7 days)
DECLARE
    v_start_time TIMESTAMP := SYSTIMESTAMP;
    v_end_time TIMESTAMP;
    v_duration NUMBER;
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== Testing Standard Session Initialization ===');
    DBMS_OUTPUT.PUT_LINE('Start time: ' || TO_CHAR(v_start_time, 'YYYY-MM-DD HH24:MI:SS'));
    
    -- Initialize session with data from last 7 days
    STATERPT_OWNER.condition_processor.initialize_session(SYSDATE - 1);
    
    v_end_time := SYSTIMESTAMP;
    v_duration := EXTRACT(SECOND FROM (v_end_time - v_start_time));
    
    DBMS_OUTPUT.PUT_LINE('Initialization completed in ' || ROUND(v_duration, 2) || ' seconds');
    DBMS_OUTPUT.PUT_LINE('Session Status: ' || STATERPT_OWNER.condition_processor.get_session_status());
END;
/

select * from gtt_results_extract;
select count(1) from gtt_staff_results_extract;

/

-- Test 3.2: Check GTT population after initialization
SELECT 'GTT_RESULTS_EXTRACT' as table_name, COUNT(*) as record_count 
FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT
UNION ALL
SELECT 'GTT_STAFF_RESULTS_EXTRACT' as table_name, COUNT(*) as record_count 
FROM STATERPT_OWNER.GTT_STAFF_RESULTS_EXTRACT;

-- ========================================================================
-- STEP 4: CHUNKED PROCESSING TESTS
-- ========================================================================

-- Test 4.1: Calculate optimal chunk size
DECLARE
    v_optimal_hours NUMBER;
    v_start_date DATE := SYSDATE - 3;
    v_end_date DATE := SYSDATE;
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== Testing Optimal Chunk Size Calculation ===');
    
    v_optimal_hours := STATERPT_OWNER.condition_processor.calculate_optimal_chunk_size(
        p_start_date => v_start_date,
        p_end_date => v_end_date,
        p_target_records_per_chunk => 500
    );
    
    DBMS_OUTPUT.PUT_LINE('Date range: ' || TO_CHAR(v_start_date, 'YYYY-MM-DD') || 
                        ' to ' || TO_CHAR(v_end_date, 'YYYY-MM-DD'));
    DBMS_OUTPUT.PUT_LINE('Optimal chunk size: ' || v_optimal_hours || ' hours');
END;
/

-- Test 4.2: Small chunked initialization test (last 2 days, 4-hour chunks)
DECLARE
    v_result VARCHAR2(4000);
    v_start_date DATE := SYSDATE - .6;
    v_end_date DATE := SYSDATE;
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== Testing Chunked Initialization ===');
    DBMS_OUTPUT.PUT_LINE('Processing ' || TO_CHAR(v_start_date, 'YYYY-MM-DD HH24:MI') || 
                        ' to ' || TO_CHAR(v_end_date, 'YYYY-MM-DD HH24:MI'));
    
    -- Clean up first
    STATERPT_OWNER.condition_processor.cleanup_session();
    
    -- Run chunked initialization
    v_result := STATERPT_OWNER.condition_processor.initialize_session_chunked(
        p_start_date => v_start_date,
        p_end_date => v_end_date,
        p_chunk_hours => 2
    );
    
    DBMS_OUTPUT.PUT_LINE('Chunked Result: ' || v_result);
END;
/

-- ========================================================================
-- STEP 5: VALIDATION FUNCTION TESTS
-- ========================================================================

-- Test 5.1: Get active states
DECLARE
    v_cursor SYS_REFCURSOR;
    v_state_abbrev VARCHAR2(2);
    v_state_name VARCHAR2(100);
    v_count NUMBER := 0;
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== Testing Active States Retrieval ===');
    
    v_cursor := STATERPT_OWNER.condition_processor.get_active_states();
    
    LOOP
        FETCH v_cursor INTO v_state_abbrev, v_state_name;
        EXIT WHEN v_cursor%NOTFOUND;
        
        v_count := v_count + 1;
        DBMS_OUTPUT.PUT_LINE('State ' || v_count || ': ' || v_state_abbrev || ' - ' || v_state_name);
        
        -- Limit output for testing
        IF v_count >= 10 THEN
            DBMS_OUTPUT.PUT_LINE('... (showing first 10 states only)');
            EXIT;
        END IF;
    END LOOP;
    
    CLOSE v_cursor;
    DBMS_OUTPUT.PUT_LINE('Total active states found: ' || v_count || '+');
END;
/

-- Test 5.2: Test 310 validation function
DECLARE
    v_test_result BOOLEAN;
    v_test_code VARCHAR2(10) := '310';
    v_textual_result VARCHAR2(100) := 'POSITIVE';
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== Testing 310 Record Validation ===');
    
    v_test_result := STATERPT_OWNER.condition_processor.is_valid_310_record(
        p_order_test_code => v_test_code,
        p_textual_result => v_textual_result
    );
    
    DBMS_OUTPUT.PUT_LINE('Test Code: ' || v_test_code);
    DBMS_OUTPUT.PUT_LINE('Textual Result: ' || v_textual_result);
    DBMS_OUTPUT.PUT_LINE('Is Valid 310: ' || CASE WHEN v_test_result THEN 'YES' ELSE 'NO' END);
END;
/


select order_number,order_test_code,activitydate from asr_process_run
where activitydate = trunc(sysdate - 2)
and source = 'IL';

select * from gtt_results_extract
where order_number = '81192Y8';

/

-- Test 6.1: Validate results for a specific state (limited records)
DECLARE
    v_cursor SYS_REFCURSOR;
    v_record STATERPT_OWNER.GTT_RESULTS_EXTRACT%ROWTYPE;
    v_count NUMBER := 0;
    v_test_state VARCHAR2(2) := 'NY'; -- Change to your target state
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== Testing Results Validation for State: ' || v_test_state || ' ===');
    
    -- Ensure session is initialized first
    IF NOT STATERPT_OWNER.condition_processor.get_session_status() LIKE '%INITIALIZED%' THEN
        STATERPT_OWNER.condition_processor.initialize_session(SYSDATE);
    END IF;
    
    v_cursor := STATERPT_OWNER.condition_processor.validate_results(
        p_state_abbrev => v_test_state,
        p_process_date => TRUNC(SYSDATE),
        p_max_records => 200, -- Limit for testing
        p_result_status_filter => 'F'
    );
    
    LOOP
        FETCH v_cursor INTO v_record;
        EXIT WHEN v_cursor%NOTFOUND;
        
        v_count := v_count + 1;
        DBMS_OUTPUT.PUT_LINE('Record ' || v_count || ': Order=' || v_record.order_number || 
                           ', Test=' || v_record.result_test_code || 
                           ', Patient=' || v_record.patient_last_name);
    END LOOP;
    
    CLOSE v_cursor;
    DBMS_OUTPUT.PUT_LINE('Total validation records found: ' || v_count);
END;

/

-- ========================================================================
-- STEP 7: INTEGRATED PROCESSING TEST
-- ========================================================================

-- Test 7.1: Full integrated chunked processing and validation (small dataset)
DECLARE
    v_result VARCHAR2(4000);
    v_start_date DATE := SYSDATE - 1; -- Last 24 hours
    v_end_date DATE := SYSDATE;
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== Testing Integrated Chunked Processing ===');
    DBMS_OUTPUT.PUT_LINE('CAUTION: This will process real data - use small date range for testing');
    
    -- Clean up first
    STATERPT_OWNER.condition_processor.cleanup_session();
    
    -- Run integrated processing
    v_result := STATERPT_OWNER.condition_processor.initialize_and_validate_chunked(
        p_start_date => v_start_date,
        p_end_date => v_end_date,
        p_chunk_hours => 6,           -- 6-hour chunks
        p_max_records => 100,         -- Limit validation records for testing
        p_validation_chunk_size => 50 -- Small validation chunks
    );
    
    DBMS_OUTPUT.PUT_LINE('Integrated Processing Result:');
    DBMS_OUTPUT.PUT_LINE(v_result);
END;
/

-- ========================================================================
-- STEP 8: PERFORMANCE AND MONITORING TESTS
-- ========================================================================

-- Test 8.1: Check chunk progress during processing
DECLARE
    v_progress VARCHAR2(4000);
BEGIN
    v_progress := STATERPT_OWNER.condition_processor.get_chunk_progress();
    DBMS_OUTPUT.PUT_LINE('Current Chunk Progress: ' || v_progress);
END;
/

-- Test 8.2: Monitor GTT table sizes
SELECT 
    'Current GTT Status' as info,
    (SELECT COUNT(*) FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT) as main_gtt_count,
    (SELECT COUNT(*) FROM STATERPT_OWNER.GTT_STAFF_RESULTS_EXTRACT) as staff_gtt_count,
    STATERPT_OWNER.condition_processor.get_session_status() as session_status
FROM DUAL;

-- ========================================================================
-- STEP 9: CLEANUP AND RESET
-- ========================================================================

-- Test 9.1: Session cleanup
DECLARE
    v_status_before VARCHAR2(4000);
    v_status_after VARCHAR2(4000);
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== Testing Session Cleanup ===');
    
    v_status_before := STATERPT_OWNER.condition_processor.get_session_status();
    DBMS_OUTPUT.PUT_LINE('Status Before Cleanup: ' || v_status_before);
    
    STATERPT_OWNER.condition_processor.cleanup_session();
    
    v_status_after := STATERPT_OWNER.condition_processor.get_session_status();
    DBMS_OUTPUT.PUT_LINE('Status After Cleanup: ' || v_status_after);
END;
/

-- ========================================================================
-- STEP 10: ERROR HANDLING TESTS
-- ========================================================================

-- Test 10.1: Test with invalid date range
DECLARE
    v_result VARCHAR2(4000);
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== Testing Error Handling ===');
    
    -- Test with end date before start date
    v_result := STATERPT_OWNER.condition_processor.initialize_session_chunked(
        p_start_date => SYSDATE,
        p_end_date => SYSDATE - 1, -- Invalid: end before start
        p_chunk_hours => 2
    );
    
    DBMS_OUTPUT.PUT_LINE('Invalid date range result: ' || v_result);
END;
/

-- Test 10.2: Test with invalid state code
DECLARE
    v_cursor SYS_REFCURSOR;
    v_record STATERPT_OWNER.GTT_RESULTS_EXTRACT%ROWTYPE;
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== Testing Invalid State Code ===');
    
    BEGIN
        v_cursor := STATERPT_OWNER.condition_processor.validate_results(
            p_state_abbrev => 'XX', -- Invalid state
            p_process_date => TRUNC(SYSDATE),
            p_max_records => 10
        );
        
        FETCH v_cursor INTO v_record;
        CLOSE v_cursor;
        
        DBMS_OUTPUT.PUT_LINE('Invalid state test completed without error');
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Expected error for invalid state: ' || SQLERRM);
    END;
END;
/

-- ========================================================================
-- TROUBLESHOOTING QUERIES
-- ========================================================================

-- Check for any compilation errors
SELECT * FROM user_errors 
WHERE name = 'CONDITION_PROCESSOR' 
ORDER BY sequence;

-- Check package dependencies
SELECT referenced_owner, referenced_name, referenced_type
FROM user_dependencies 
WHERE name = 'CONDITION_PROCESSOR'
ORDER BY referenced_owner, referenced_name;

-- Check table grants (if you get ORA-00942 errors)
SELECT table_name, privilege,owner 
FROM user_tab_privs 
WHERE table_name IN ('RESULTS', 'DIM_LAB_ORDER', 'DIM_PATIENT', 'DIM_STAFF')
ORDER BY table_name;

PROMPT ========================================================================
PROMPT TESTING COMPLETE
PROMPT ========================================================================
PROMPT 
PROMPT NEXT STEPS:
PROMPT 1. Review all test outputs for any errors
PROMPT 2. Adjust date ranges based on your data availability
PROMPT 3. Test with production-like data volumes gradually
PROMPT 4. Monitor performance with larger datasets
PROMPT 5. Set up automated logging if condition_processor_log table exists
PROMPT 
PROMPT For production use:
PROMPT - Use appropriate date ranges for your data processing needs
PROMPT - Monitor chunk sizes and adjust based on performance
PROMPT - Implement proper error notification and monitoring
PROMPT ========================================================================
