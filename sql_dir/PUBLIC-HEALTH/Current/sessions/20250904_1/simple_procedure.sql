-- ================================================================
-- SIMPLE PROCEDURE EXECUTION IN SQL DEVELOPER
-- ================================================================

SET SERVEROUTPUT ON SIZE 1000000;

-- Execute the procedure with parameters
BEGIN
    -- Initialize session with yesterday's date
    condition_processor.initialize_session(TRUNC(SYSDATE - 2));
    
    DBMS_OUTPUT.PUT_LINE('Session initialized successfully');
END;
/

-- Check session status
BEGIN
    DBMS_OUTPUT.PUT_LINE('Status: ' || condition_processor.get_session_status());
END;
/

-- Process a specific state
DECLARE
    v_cursor SYS_REFCURSOR;
    v_count NUMBER := 0;
    TYPE result_rec IS RECORD (
        accession_number VARCHAR2(50),
        order_test_code VARCHAR2(20),
        result_test_code VARCHAR2(20),
        result_status VARCHAR2(10),
        patient_last_name VARCHAR2(100)
    );
    v_rec result_rec;
BEGIN
    -- Call the function
    v_cursor := condition_processor.process_state('LA', TRUNC(SYSDATE - 1));
    
    -- Process results
    LOOP
        FETCH v_cursor INTO v_rec.accession_number, v_rec.order_test_code, 
                           v_rec.result_test_code, v_rec.result_status, v_rec.patient_last_name;
        EXIT WHEN v_cursor%NOTFOUND;
        
        v_count := v_count + 1;
        
        -- Show first 5 records
        IF v_count <= 200 THEN
            DBMS_OUTPUT.PUT_LINE('Record ' || v_count || ': ' || 
                v_rec.accession_number || ' | ' || 
                v_rec.order_test_code || ' | ' || 
                v_rec.result_test_code);
        END IF;
        
        EXIT WHEN v_count >= 100;
    END LOOP;
    
    CLOSE v_cursor;
    DBMS_OUTPUT.PUT_LINE('Total records: ' || v_count);
END;
/
SET SERVEROUTPUT ON SIZE 1000000;

DECLARE
    v_cursor SYS_REFCURSOR;
    v_record STATERPT_OWNER.GTT_RESULTS_EXTRACT%ROWTYPE;
    v_count NUMBER := 0;
BEGIN
    condition_processor.initialize_session(TRUNC(SYSDATE - 1));
    v_cursor := condition_processor.process_state('LA', TRUNC(SYSDATE - 1));
    
    DBMS_OUTPUT.PUT_LINE('Processing results...');
    
    LOOP
        FETCH v_cursor INTO v_record;
        EXIT WHEN v_cursor%NOTFOUND;
        
        v_count := v_count + 1;
        
        IF v_count <= 10 THEN
            DBMS_OUTPUT.PUT_LINE('Record ' || v_count || ': ' || 
                NVL(v_record.accession_number, 'NULL') || ' | ' || 
                NVL(v_record.order_test_code, 'NULL') || ' | ' || 
                NVL(v_record.result_test_code, 'NULL') || ' | ' ||
                NVL(v_record.textual_result, 'NULL'));
        END IF;
        
        EXIT WHEN v_count >= 100;
    END LOOP;
    
    CLOSE v_cursor;
    DBMS_OUTPUT.PUT_LINE('Total records: ' || v_count);
END;
/


/

select order_number,order_test_code,result_test_code,textual_result_full from gtt_results_extract
where patient_account_state = 'LA'
and result_test_code IN ('310','310A');

select * from asr_process_run
where source = 'AL'
and activitydate = '30-AUG-25';

select * from results_sent_log
where order_number = '7279VR8';

select * from gtt_results_extract
where order_number = '7279VR8'
and result_test_code = '310';

;

/

-- Cleanup (optional)
BEGIN
    condition_processor.cleanup_session();
    DBMS_OUTPUT.PUT_LINE('Session cleaned up');
END;
/

select patient_account_state,count(1) from gtt_results_extract
where order_test_code = '311'
and textual_result_full = 'Not Detected'
group by patient_account_state
order by patient_account_state;
/

-- ================================================================
-- VALIDATE RESULTS AFTER INITIALIZATION
-- ================================================================

DECLARE
    v_cursor SYS_REFCURSOR;
    v_record STATERPT_OWNER.GTT_RESULTS_EXTRACT%ROWTYPE;
    v_row_num NUMBER;
    v_result_code_count NUMBER;
    v_all_result_codes VARCHAR2(100);
    v_count NUMBER := 0;
    v_state VARCHAR2(2) := 'AL';
    v_process_date DATE := TRUNC(SYSDATE - 1);
BEGIN
    v_cursor := condition_processor.validate_results(
        p_state_abbrev => v_state,
        p_process_date => v_process_date,
        p_result_status_filter => 'F'
    );

    DBMS_OUTPUT.PUT_LINE('=== VALIDATION RESULTS ===');
    
    LOOP
        FETCH v_cursor INTO v_record;
        EXIT WHEN v_cursor%NOTFOUND;
        
        v_count := v_count + 1;
        
        DBMS_OUTPUT.PUT_LINE('Validation ' || v_count || ': ' || 
            v_record.accession_number || ' | ' || 
            v_record.order_test_code || ' | ' || 
            v_record.result_test_code || ' | ' ||
            v_record.result_status || ' | ' ||
            NVL(SUBSTR(v_record.textual_result, 1, 15), 'NULL'));
    END LOOP;
    
    CLOSE v_cursor;
    DBMS_OUTPUT.PUT_LINE('Total: ' || v_count);
END;
/
/

-- Alternative: Validate without status filter
DECLARE
    v_cursor SYS_REFCURSOR;
    v_record STATERPT_OWNER.GTT_RESULTS_EXTRACT%ROWTYPE;
    v_count NUMBER := 0;
BEGIN
    -- Validate all results (no status filter)
    v_cursor := condition_processor.validate_results('LA', TRUNC(SYSDATE - 1), 20, NULL);
    
    DBMS_OUTPUT.PUT_LINE('=== ALL RESULTS VALIDATION ===');
    
    LOOP
        FETCH v_cursor INTO v_record;
        EXIT WHEN v_cursor%NOTFOUND;
        
        v_count := v_count + 1;
        
        DBMS_OUTPUT.PUT_LINE('Record ' || v_count || ': ' || 
            v_record.accession_number || ' | ' || 
            v_record.order_test_code || ' | ' || 
            v_record.result_test_code || ' | ' ||
            v_record.result_status);
    END LOOP;
    
    CLOSE v_cursor;
    DBMS_OUTPUT.PUT_LINE('Total: ' || v_count);
END;
/