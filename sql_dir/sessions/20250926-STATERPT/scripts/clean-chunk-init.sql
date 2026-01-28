-- Test 4.2: Small chunked initialization test (last 2 days, 4-hour chunks)
DECLARE
    v_result VARCHAR2(4000);
    v_start_date DATE := TRUNC(sysdate);
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