-- ================================================================
-- TEST 2: Dynamic Date Initialization Tests
-- ================================================================
PROMPT 
PROMPT TEST 2: Dynamic Date Initialization Tests
PROMPT ================================================================

-- Test with default date (today)
DECLARE
    v_status VARCHAR2(100);
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== Testing with default date (today) ===');
    condition_processor.initialize_session;
    v_status := condition_processor.get_session_status;
    DBMS_OUTPUT.PUT_LINE('Status: ' || v_status);
END;
/

-- Test with yesterday's date
DECLARE
    v_status VARCHAR2(100);
    v_yesterday DATE := TRUNC(SYSDATE) - 1;
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== Testing with yesterday''s date ===');
    condition_processor.cleanup_session;
    condition_processor.initialize_session(v_yesterday);
    v_status := condition_processor.get_session_status;
    DBMS_OUTPUT.PUT_LINE('Status: ' || v_status);
END;
/

-- Test with last week's date
DECLARE
    v_status VARCHAR2(100);
    v_last_week DATE := TRUNC(SYSDATE) - 7;
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== Testing with last week''s date ===');
    condition_processor.cleanup_session;
    condition_processor.initialize_session(v_last_week);
    v_status := condition_processor.get_session_status;
    DBMS_OUTPUT.PUT_LINE('Status: ' || v_status);
END;
/