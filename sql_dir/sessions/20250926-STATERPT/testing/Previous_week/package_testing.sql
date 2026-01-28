-- ================================================================
-- COMPREHENSIVE ORACLE VALIDATION SCRIPT FOR ALL STATES
-- Tests condition_processor.validate_results across all states
-- ================================================================

-- Initialize session first
DECLARE
    v_process_date DATE := TRUNC(sysdate);
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== INITIALIZING CONDITION PROCESSOR SESSION ===');
    condition_processor.initialize_session(v_process_date);
    DBMS_OUTPUT.PUT_LINE('Session initialized for date: ' || TO_CHAR(v_process_date, 'DD-MON-YYYY'));
    
    delete gtt_results_extract
    where not regexp_like(result_status,'^(F)')
    or not regexp_like(order_test_code,'^(3|110|111|113)');
    
    delete gtt_results_extract
    where regexp_like(order_test_code,'^(110|111|113)$')
    and patient_account_state NOT IN ('NY');
    
    commit;

END;
/

select order_number,textual_result_full,numeric_result,release_date_time,value_type from gtt_results_extract
where order_test_code = '318'
and patient_account_state = 'IL'
and (textual_result_full = 'Nonreactive' or (numeric_result is not null and numeric_result > 0))
order by order_number;

select order_number,textual_result_full,numeric_result,release_date_time from gtt_results_extract
where order_number in ('7512VN8','7297TK8','7512VN8','75577J8','7567NW8')
and order_test_code = '310'
order by order_number;

select order_number,order_test_code,count(1) from asr_process_run 
where activitydate = trunc(sysdate - 2)
and order_test_code = '310'
group by order_number,order_test_code
having count(1) = 1;


delete gtt_results_extract
where not regexp_like(result_status,'^(F)')
or not regexp_like(order_test_code,'^(3|110|111|113)');

delete gtt_results_extract
where regexp_like(order_test_code,'^(110|111|113)$')
and patient_account_state NOT IN ('NY');

commit;

select patient_account_state,count(1) from gtt_results_extract
group by patient_account_state;

select source,complete,order_test_code,result_test_code,complete from asr_process_run
where activitydate = trunc(sysdate - 1)
--group by source,complete,order_test_code,result_test_code
order by source;


select * from report_results r
where (order_number,result_test_code) not in
(select order_number,result_test_code 
from asr_process_run
where activitydate = trunc(sysdate -1)
and complete = 'N');

select * from asr_process_run
where activitydate = trunc(sysdate - 1)
and complete = 'N';
order by source,order_number;

select order_number,textual_result_full,patient_account_state from gtt_results_extract
where (order_number,order_test_code) IN
(select order_number,order_test_code from asr_process_run
where activitydate = trunc(sysdate)
and order_test_code = '310'
group by order_number,order_test_code
having count(1) = 1)
order by patient_account_state,order_number;

select * from asr_process_run
where activitydate = trunc(sysdate)
order by source;


select order_number,textual_result_full,patient_account_state,order_test_code,result_test_code from gtt_results_extract
where (order_number,order_test_code) IN
(select order_number,order_test_code from asr_process_run
where activitydate = trunc(sysdate)
and order_test_code = '332'

)
and regexp_like(result_test_code,'^(P10)')
order by patient_account_state,order_number;

select order_number,textual_result_full,patient_account_state,order_test_code,result_test_code,value_type from gtt_results_extract
where (order_number,order_test_code) IN
(select order_number,order_test_code from asr_process_run
where activitydate = trunc(sysdate)
and order_test_code = '318'

)
and regexp_like(result_test_code,'^(P10)')
order by patient_account_state,order_number;

select order_number,ORDER_TEST_CODE,RESULT_TEST_CODE,PERFORMING_LAB_ID,TEXTUAL_RESULT_FULL,
       PATIENT_LAST_NAME,source,ACTIVITYDATE,'N' complete from report_results rr
       where activitydate = trunc(sysdate - 1);

/

DELETE FROM asr_process_run 
WHERE activitydate = TRUNC(SYSDATE)
AND order_test_code = '310'
AND (order_number, order_test_code) IN (
    SELECT order_number, order_test_code
    FROM asr_process_run
    WHERE activitydate = TRUNC(SYSDATE )
    AND order_test_code = '310'
    GROUP BY order_number, order_test_code
    HAVING COUNT(1) = 1
);

commit;


/



select source,count(1) from asr_process_run
where activitydate = trunc(sysdate)
and complete = 'N'
group by source
order by source;

select to_timestamp(trunc(sysdate)) from dual;

drop table asr_process_PA_20250829;

create table asr_process_PA_20250829
as
select * from asr_process_run
where complete IN ('R','Q','N')
and source= 'PA'
and activitydate = '29-AUG-25'
--and order_test_code not in ('301')
order by result_test_code,order_number;

select * from asr_process_PA_20250829;

update asr_process_run
set complete = 'N'
where (order_number,result_test_code) IN
(select order_number,result_test_code from asr_process_PA_20250829);

delete results_sent_log
where (order_number,result_test_code) IN
(select order_number,result_test_code from asr_process_PA_20250829);

create table results_sent_log_PA_20250829
as
select * from results_sent_log
where (order_number,result_test_code) IN
(select order_number,result_test_code from asr_process_PA_20250829);

select * from generator
where state_fk IN
(select state_master_pk from state_master
where state_abbreviation = 'NC');

update generator
set conversion_context = 'NCHL7GeneratorContext'
where generator_pk = 42;

/

-- ================================================================
-- VALIDATE RESULTS FOR ALL STATES - REFACTORED VERSION
-- ================================================================

DECLARE
    v_cursor SYS_REFCURSOR;
    v_record STATERPT_OWNER.GTT_RESULTS_EXTRACT%ROWTYPE;
    v_count NUMBER := 0;
    v_total_count NUMBER := 0;
    v_total_matched NUMBER := 0;
    v_total_unmatched NUMBER := 0;
    v_process_date DATE := TRUNC(SYSDATE - 1);
    
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
    BEGIN
        v_states_cursor := condition_processor.get_active_states();
        
        -- Initialize collection
        v_states := state_array_type();
        
        LOOP
            FETCH v_states_cursor INTO v_state_abbrev, v_state_name;
            EXIT WHEN v_states_cursor%NOTFOUND;
            
            v_states.EXTEND;
            v_states(v_states.COUNT) := v_state_abbrev;
        END LOOP;
        
        CLOSE v_states_cursor;
    END;
    
    DBMS_OUTPUT.PUT_LINE('Found ' || v_states.COUNT || ' active states to validate');
    DBMS_OUTPUT.PUT_LINE('');
    
    -- Loop through all states
    FOR i IN 1..v_states.COUNT LOOP
        v_count := 0;
        v_state_results_count := 0;
        v_failed_results_count := 0;
        v_sent_results_count := 0;
        
        BEGIN
            -- Validate results for current state with 'F' (Final) status filter
            v_cursor := condition_processor.validate_results(
                p_state_abbrev => v_states(i),
                p_process_date => v_process_date,
                p_result_status_filter => 'F'
            );
            
            DBMS_OUTPUT.PUT_LINE('--- STATE: ' || v_states(i) || ' (Final Results) ---');
            
            LOOP
                FETCH v_cursor INTO v_record;
                EXIT WHEN v_cursor%NOTFOUND;
                
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
/


BEGIN
        -- Validate results for current state with 'F' (Final) status filter
        v_cursor := condition_processor.validate_results(
            p_state_abbrev => v_states(i),
            p_process_date => v_process_date,
            p_result_status_filter => 'F'
        );
        
        DBMS_OUTPUT.PUT_LINE('--- STATE: ' || v_states(i) || ' (Final Results) ---');
        
        LOOP
            FETCH v_cursor INTO v_record;
            EXIT WHEN v_cursor%NOTFOUND;
            
            -- Apply 310 validation filter
            IF condition_processor.is_valid_310_record(
                v_record.order_number,
                v_record.order_test_code,
                v_states(i),
                v_process_date
            ) THEN
                v_count := v_count + 1;
                
                -- Your existing processing logic here
                -- Check if this result exists in results_sent_log
                DECLARE
                    v_exists_in_sent_log NUMBER;
                BEGIN
                    -- ... existing logic ...
                END;
            ELSE
                -- Skip this record due to 310 validation failure
                DBMS_OUTPUT.PUT_LINE('  Skipped 310 record: ' || v_record.order_number || 
                    ' (insufficient result codes)');
            END IF;
        END LOOP;
        
        CLOSE v_cursor;
end;



/


-- ================================================================
-- DETAILED VALIDATION FOR SPECIFIC STATES (MODIFY AS NEEDED)
-- ================================================================

DECLARE
    v_cursor SYS_REFCURSOR;
    v_record STATERPT_OWNER.GTT_RESULTS_EXTRACT%ROWTYPE;
    v_count NUMBER := 0;
    v_state VARCHAR2(2) := 'IL'; -- Change this to test specific state
    v_process_date DATE := TRUNC(SYSDATE - 1);
    v_max_records NUMBER := 20; -- Limit for detailed output
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== DETAILED VALIDATION FOR STATE: ' || v_state || ' ===');
    
    -- Test with different status filters
    FOR status_filter IN (
        SELECT 'F' as status, 'FAILED' as description FROM DUAL
        UNION ALL
        SELECT 'S' as status, 'SENT' as description FROM DUAL
        UNION ALL
        SELECT 'P' as status, 'PENDING' as description FROM DUAL
    ) LOOP
        v_count := 0;
        
        BEGIN
            v_cursor := condition_processor.validate_results(
                p_state_abbrev => v_state,
                p_process_date => v_process_date,
                p_result_status_filter => status_filter.status
            );
            
            DBMS_OUTPUT.PUT_LINE('--- ' || status_filter.description || ' RESULTS ---');
            
            LOOP
                FETCH v_cursor INTO v_record;
                EXIT WHEN v_cursor%NOTFOUND OR v_count >= v_max_records;
                
                v_count := v_count + 1;
                
                DBMS_OUTPUT.PUT_LINE(v_count || ': Order=' || v_record.accession_number || 
                    ' | OrderTest=' || v_record.order_test_code || 
                    ' | ResultTest=' || v_record.result_test_code || 
                    ' | Status=' || v_record.result_status || 
                    ' | Result=' || NVL(SUBSTR(v_record.textual_result, 1, 30), 'NULL') ||
                    ' | Lab=' || NVL(v_record.performing_lab, 'NULL'));
            END LOOP;
            
            -- Count remaining records
            DECLARE
                v_remaining NUMBER := 0;
            BEGIN
                LOOP
                    FETCH v_cursor INTO v_record;
                    EXIT WHEN v_cursor%NOTFOUND;
                    v_remaining := v_remaining + 1;
                END LOOP;
                
                IF v_remaining > 0 THEN
                    DBMS_OUTPUT.PUT_LINE('... and ' || v_remaining || ' more records');
                END IF;
            END;
            
            CLOSE v_cursor;
            DBMS_OUTPUT.PUT_LINE('Total ' || status_filter.description || ' records: ' || (v_count + NVL(v_remaining, 0)));
            
        EXCEPTION
            WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE('ERROR processing ' || status_filter.description || ': ' || SQLERRM);
                IF v_cursor%ISOPEN THEN
                    CLOSE v_cursor;
                END IF;
        END;
        
        DBMS_OUTPUT.PUT_LINE('');
    END LOOP;
    
END;
/

-- ================================================================
-- CROSS-REFERENCE WITH RESULTS_SENT_LOG TABLE
-- ================================================================

DECLARE
    v_cursor SYS_REFCURSOR;
    v_record STATERPT_OWNER.GTT_RESULTS_EXTRACT%ROWTYPE;
    v_count NUMBER := 0;
    v_matched_count NUMBER := 0;
    v_unmatched_count NUMBER := 0;
    v_state VARCHAR2(2) := 'IL'; -- Change as needed
    v_process_date DATE := TRUNC(SYSDATE - 1);
    v_exists_in_log NUMBER;
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== CROSS-REFERENCE VALIDATION WITH RESULTS_SENT_LOG ===');
    DBMS_OUTPUT.PUT_LINE('State: ' || v_state);
    
    v_cursor := condition_processor.validate_results(
        p_state_abbrev => v_state,
        p_process_date => v_process_date,
        p_result_status_filter => 'S' -- Check sent results
    );
    
    LOOP
        FETCH v_cursor INTO v_record;
        EXIT WHEN v_cursor%NOTFOUND;
        
        v_count := v_count + 1;
        
        -- Check if this record exists in results_sent_log
        SELECT COUNT(*)
        INTO v_exists_in_log
        FROM results_sent_log
        WHERE order_number = v_record.accession_number
        AND result_test_code = v_record.result_test_code;
        
        IF v_exists_in_log > 0 THEN
            v_matched_count := v_matched_count + 1;
            IF v_matched_count <= 5 THEN -- Show first 5 matches
                DBMS_OUTPUT.PUT_LINE('MATCHED: ' || v_record.accession_number || 
                    ' | ' || v_record.result_test_code || ' | Found in sent log');
            END IF;
        ELSE
            v_unmatched_count := v_unmatched_count + 1;
            IF v_unmatched_count <= 10 THEN -- Show first 10 unmatched
                DBMS_OUTPUT.PUT_LINE('UNMATCHED: ' || v_record.accession_number || 
                    ' | ' || v_record.result_test_code || ' | NOT found in sent log');
            END IF;
        END IF;
        
        -- Limit output for performance
        IF v_count >= 100 THEN
            DBMS_OUTPUT.PUT_LINE('... limiting output to first 100 records');
            EXIT;
        END IF;
    END LOOP;
    
    CLOSE v_cursor;
    
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('=== CROSS-REFERENCE SUMMARY ===');
    DBMS_OUTPUT.PUT_LINE('Total validated records: ' || v_count);
    DBMS_OUTPUT.PUT_LINE('Matched in results_sent_log: ' || v_matched_count);
    DBMS_OUTPUT.PUT_LINE('Unmatched (missing from sent log): ' || v_unmatched_count);
    DBMS_OUTPUT.PUT_LINE('Match percentage: ' || ROUND((v_matched_count / GREATEST(v_count, 1)) * 100, 2) || '%');
    
END;
/

-- ================================================================
-- CLEANUP SESSION
-- ================================================================

BEGIN
    DBMS_OUTPUT.PUT_LINE('=== CLEANING UP SESSION ===');
    condition_processor.cleanup_session();
    DBMS_OUTPUT.PUT_LINE('Session cleanup completed');
END;
/

-- ================================================================
-- PERFORMANCE MONITORING QUERIES
-- ================================================================

-- Check session status
SELECT condition_processor.get_session_status FROM DUAL;

-- Check GTT table contents (if accessible)
-- SELECT COUNT(*) FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT;

-- Monitor long operations (if running)
SELECT sid, serial#, opname, target, sofar, totalwork, 
       ROUND(sofar/totalwork*100,2) as pct_complete,
       time_remaining, elapsed_seconds
FROM v$session_longops 
WHERE time_remaining > 0;
