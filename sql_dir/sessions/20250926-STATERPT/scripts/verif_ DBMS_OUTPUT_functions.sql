-- Simple test to verify DBMS_OUTPUT and package functions work
-- Run this first to diagnose the issue

SET SERVEROUTPUT ON SIZE 1000000;

BEGIN
    DBMS_OUTPUT.PUT_LINE('=== Simple Test ===');
    DBMS_OUTPUT.PUT_LINE('If you see this, DBMS_OUTPUT is working');
    
    -- Test if package exists
    BEGIN
        DBMS_OUTPUT.PUT_LINE('Testing package access...');
        DECLARE
            v_dummy VARCHAR2(100);
        BEGIN
            SELECT condition_processor.get_session_status() INTO v_dummy FROM DUAL;
            DBMS_OUTPUT.PUT_LINE('Package condition_processor is accessible');
        END;
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('ERROR: Package not accessible - ' || SQLERRM);
    END;
    
    -- Test chunked functions exist
    BEGIN
        DBMS_OUTPUT.PUT_LINE('Testing chunked functions...');
        DECLARE
            v_result VARCHAR2(100);
        BEGIN
            v_result := condition_processor.calculate_optimal_chunk_size(SYSDATE-1, SYSDATE, 100);
            DBMS_OUTPUT.PUT_LINE('calculate_optimal_chunk_size works: ' || v_result);
        END;
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('ERROR: Chunked functions not found - ' || SQLERRM);
    END;
    
    DBMS_OUTPUT.PUT_LINE('=== Test Complete ===');
END;
/
