-- ================================================================
-- DETAILED RECORD INSPECTION - WITH PROCESS DATE FILTER
-- ================================================================
PROMPT 
PROMPT Detailed Record Inspection with Process Date Filter
PROMPT ================================================================

DECLARE
    v_cursor SYS_REFCURSOR;
    v_record STATERPT_OWNER.GTT_RESULTS_EXTRACT%ROWTYPE;
    v_count NUMBER := 0;
    v_process_date DATE := TRUNC(SYSDATE - 1); -- Change this to your desired date
    v_state_abbrev varchar2(2) := 'LA';
BEGIN
    DBMS_OUTPUT.PUT_LINE('Inspecting detailed records for PA with process date: ' || 
        TO_CHAR(v_process_date, 'YYYY-MM-DD'));
    
    -- Process PA state with specific date filter
    v_cursor := condition_processor.process_state(v_state_abbrev, v_process_date);
    
    -- Display detailed info for first few records
    LOOP
        FETCH v_cursor INTO v_record;
        EXIT WHEN v_cursor%NOTFOUND;
        
        v_count := v_count + 1;
        
        -- Display detailed info for first 200 records
        IF v_count <= 200 and v_record.result_status = 'F' THEN
            DBMS_OUTPUT.PUT_LINE('--- Record ' || v_count || ' ---');
            DBMS_OUTPUT.PUT_LINE('Accession: ' || v_record.accession_number);
            DBMS_OUTPUT.PUT_LINE('Patient: ' || v_record.patient_last_name || ', ' || v_record.patient_first_name);
            DBMS_OUTPUT.PUT_LINE('State: ' || v_record.patient_account_state);
            DBMS_OUTPUT.PUT_LINE('Order Test: ' || v_record.order_test_code || ' - ' || v_record.order_test_name);
            DBMS_OUTPUT.PUT_LINE('Result Test: ' || v_record.result_test_code || ' - ' || v_record.result_test_name);
            DBMS_OUTPUT.PUT_LINE('Result: ' || v_record.textual_result);
            DBMS_OUTPUT.PUT_LINE('Release Date/Time: ' || 
                CASE 
                    WHEN v_record.release_date_time IS NOT NULL THEN 
                        TO_CHAR(v_record.release_date_time, 'YYYY-MM-DD HH24:MI:SS')
                    ELSE 'NULL'
                END);
            DBMS_OUTPUT.PUT_LINE('Release Date (Truncated): ' || 
                CASE 
                    WHEN v_record.release_date_time IS NOT NULL THEN 
                        TO_CHAR(TRUNC(v_record.release_date_time), 'YYYY-MM-DD')
                    ELSE 'NULL'
                END);
            DBMS_OUTPUT.PUT_LINE('Facility: ' || v_record.facility_name);
            DBMS_OUTPUT.PUT_LINE('Result_Status: ' || v_record.result_status);
            DBMS_OUTPUT.PUT_LINE('');
        END IF;
        
        EXIT WHEN v_count >= 200;
    END LOOP;
    
    CLOSE v_cursor;
    
    DBMS_OUTPUT.PUT_LINE('Sample inspection completed. Total records processed: ' || v_count);
    
EXCEPTION
    WHEN OTHERS THEN
        IF v_cursor%ISOPEN THEN
            CLOSE v_cursor;
        END IF;
        DBMS_OUTPUT.PUT_LINE('Detailed inspection error: ' || SQLERRM);
END;
/

select order_number,order_test_code,result_test_code,textual_result_full,result_status,result_comments from gtt_results_extract
where patient_account_state = 'LA'
and order_test_code = '310'
--and textual_result_full = 'Positive'
and trunc(release_date_time) = '30-AUG-25'
and result_status = 'F'
order by order_number;
/