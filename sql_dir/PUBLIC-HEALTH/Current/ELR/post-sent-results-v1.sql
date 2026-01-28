-- Refactored ASR Process Run Posting Results Script
-- Purpose: Update complete status in asr_process_run based on results_sent_log
--          and categorize updates by type (General Lab vs COVID)
--
-- Business Rules:
--   - order_test_code '332' -> complete = 'S' (COVID)
--   - order_test_code '331' -> complete = 'C' (COVID)
--   - All others -> complete = 'R' (General Lab)

DECLARE
    v_general_count NUMBER := 0;
    v_covid_count NUMBER := 0;
    v_total_updated NUMBER := 0;
    v_error_count NUMBER := 0;
    
    -- Configuration constants
    c_status_not_complete CONSTANT CHAR(1) := 'N';
    c_status_general CONSTANT CHAR(1) := 'R';
    c_status_covid_332 CONSTANT CHAR(1) := 'S';
    c_status_covid_331 CONSTANT CHAR(1) := 'C';
    
    -- Type for state breakdown
    TYPE t_state_summary IS RECORD (
        source VARCHAR2(10),
        record_count NUMBER,
        general_count NUMBER,
        covid_count NUMBER
    );
    TYPE t_state_table IS TABLE OF t_state_summary;
    v_state_breakdown t_state_table;
    
    -- Exception handling
    e_update_failed EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_update_failed, -20001);
    
BEGIN
    -- Capture state breakdown BEFORE update
    SELECT 
        apr.source,
        COUNT(*) AS record_count,
        COUNT(CASE WHEN apr.order_test_code NOT IN ('332', '331') THEN 1 END) AS general_count,
        COUNT(CASE WHEN apr.order_test_code IN ('332', '331') THEN 1 END) AS covid_count
    BULK COLLECT INTO v_state_breakdown
    FROM asr_process_run apr
    WHERE apr.complete = c_status_not_complete
      AND EXISTS (
          SELECT 1
          FROM results_sent_log rsl
          WHERE rsl.order_number = apr.order_number
            AND rsl.result_test_code = apr.result_test_code
      )
    GROUP BY apr.source
    ORDER BY apr.source;
    
    -- Count by category BEFORE update
    SELECT 
        COUNT(CASE WHEN apr.order_test_code NOT IN ('332', '331') THEN 1 END),
        COUNT(CASE WHEN apr.order_test_code IN ('332', '331') THEN 1 END)
    INTO v_general_count, v_covid_count
    FROM asr_process_run apr
    WHERE apr.complete = c_status_not_complete
      AND EXISTS (
          SELECT 1
          FROM results_sent_log rsl
          WHERE rsl.order_number = apr.order_number
            AND rsl.result_test_code = apr.result_test_code
      );
    
    -- Single UPDATE with CASE expression replaces entire cursor loop
    UPDATE asr_process_run apr
    SET apr.complete = CASE apr.order_test_code
                           WHEN '332' THEN c_status_covid_332
                           WHEN '331' THEN c_status_covid_331
                           ELSE c_status_general
                       END
    WHERE apr.complete = c_status_not_complete
      AND EXISTS (
          SELECT 1
          FROM results_sent_log rsl
          WHERE rsl.order_number = apr.order_number
            AND rsl.result_test_code = apr.result_test_code
      );
    
    v_total_updated := SQL%ROWCOUNT;
    
    -- Single commit after all updates
    COMMIT;
    
    -- Output summary results
    DBMS_OUTPUT.PUT_LINE('=== Update Summary ===');
    DBMS_OUTPUT.PUT_LINE('Total records updated: ' || v_total_updated);
    DBMS_OUTPUT.PUT_LINE('General Lab (R): ' || v_general_count);
    DBMS_OUTPUT.PUT_LINE('COVID (S/C): ' || v_covid_count);
    DBMS_OUTPUT.PUT_LINE('');
    
    -- Debug: Check collection status
    IF v_state_breakdown IS NULL THEN
        DBMS_OUTPUT.PUT_LINE('DEBUG: v_state_breakdown is NULL');
    ELSE
        DBMS_OUTPUT.PUT_LINE('DEBUG: v_state_breakdown.COUNT = ' || v_state_breakdown.COUNT);
    END IF;
    
    DBMS_OUTPUT.PUT_LINE('By State:');
    
    -- Output state-by-state breakdown from pre-captured data
    IF v_state_breakdown IS NOT NULL AND v_state_breakdown.COUNT > 0 THEN
        FOR i IN 1..v_state_breakdown.COUNT LOOP
            DBMS_OUTPUT.PUT_LINE(
                '  ' || v_state_breakdown(i).source || ': ' || 
                v_state_breakdown(i).record_count || ' records ' ||
                '(General: ' || v_state_breakdown(i).general_count || 
                ', COVID: ' || v_state_breakdown(i).covid_count || ')'
            );
        END LOOP;
    ELSE
        DBMS_OUTPUT.PUT_LINE('  No states to report');
    END IF;
    
    DBMS_OUTPUT.PUT_LINE('=====================');
    
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Error: No matching records found in results_sent_log');
        RAISE;
        
    WHEN TOO_MANY_ROWS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Error: Unexpected multiple rows returned');
        RAISE;
        
    WHEN OTHERS THEN
        ROLLBACK;
        v_error_count := v_error_count + 1;
        DBMS_OUTPUT.PUT_LINE('Error occurred: ' || SQLERRM);
        DBMS_OUTPUT.PUT_LINE('Error code: ' || SQLCODE);
        DBMS_OUTPUT.PUT_LINE('Records updated before error: ' || v_total_updated);
        RAISE;
END;
/

-- ============================================================================
-- Alternative: Detailed logging version with per-record tracking
-- Use this if you need to see individual record updates
-- ============================================================================

DECLARE
    v_general_count NUMBER := 0;
    v_covid_count NUMBER := 0;
    v_total_updated NUMBER := 0;
    
    -- Configuration constants
    c_status_not_complete CONSTANT CHAR(1) := 'N';
    c_status_general CONSTANT CHAR(1) := 'R';
    c_status_covid_332 CONSTANT CHAR(1) := 'S';
    c_status_covid_331 CONSTANT CHAR(1) := 'C';
    
    -- Cursor for detailed logging
    CURSOR c_updates IS
        SELECT 
            apr.order_number,
            apr.order_test_code,
            apr.result_test_code,
            CASE apr.order_test_code
                WHEN '332' THEN c_status_covid_332
                WHEN '331' THEN c_status_covid_331
                ELSE c_status_general
            END AS new_complete_status
        FROM asr_process_run apr
        WHERE apr.complete = c_status_not_complete
          AND EXISTS (
              SELECT 1
              FROM results_sent_log rsl
              WHERE rsl.order_number = apr.order_number
                AND rsl.result_test_code = apr.result_test_code
          )
        ORDER BY apr.order_number;
    
    TYPE t_update_records IS TABLE OF c_updates%ROWTYPE;
    v_records t_update_records;
    
BEGIN
    -- Bulk collect all records to update
    OPEN c_updates;
    FETCH c_updates BULK COLLECT INTO v_records;
    CLOSE c_updates;
    
    -- Exit if no records to process
    IF v_records.COUNT = 0 THEN
        DBMS_OUTPUT.PUT_LINE('No records to update.');
        RETURN;
    END IF;
    
    -- Process updates using FORALL for bulk operations
    FORALL i IN 1..v_records.COUNT
        UPDATE asr_process_run
        SET complete = v_records(i).new_complete_status
        WHERE order_number = v_records(i).order_number
          AND order_test_code = v_records(i).order_test_code
          AND result_test_code = v_records(i).result_test_code
          AND complete = c_status_not_complete;
    
    v_total_updated := SQL%ROWCOUNT;
    
    -- Count by category and output details
    FOR i IN 1..v_records.COUNT LOOP
        DBMS_OUTPUT.PUT_LINE(
            'Updated: ' || 
            v_records(i).order_number || CHR(9) ||
            v_records(i).result_test_code || CHR(9) ||
            v_records(i).new_complete_status
        );
        
        IF v_records(i).new_complete_status = c_status_general THEN
            v_general_count := v_general_count + 1;
        ELSE
            v_covid_count := v_covid_count + 1;
        END IF;
    END LOOP;
    
    -- Single commit after all updates
    COMMIT;
    
    -- Output summary
    DBMS_OUTPUT.PUT_LINE('=== Update Summary ===');
    DBMS_OUTPUT.PUT_LINE('General Lab (R): ' || v_general_count);
    DBMS_OUTPUT.PUT_LINE('COVID (S/C): ' || v_covid_count);
    DBMS_OUTPUT.PUT_LINE('Total updated: ' || v_total_updated);
    
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
        DBMS_OUTPUT.PUT_LINE('Records processed before error: ' || v_total_updated);
        RAISE;
END;
/

-- ============================================================================
-- Preview Query: See what would be updated without making changes
-- ============================================================================

SELECT 
    apr.order_number,
    apr.order_test_code,
    apr.result_test_code,
    apr.complete AS current_status,
    CASE apr.order_test_code
        WHEN '332' THEN 'S'
        WHEN '331' THEN 'C'
        ELSE 'R'
    END AS new_status,
    CASE 
        WHEN apr.order_test_code IN ('332', '331') THEN 'COVID'
        ELSE 'General Lab'
    END AS category
FROM asr_process_run apr
WHERE apr.complete = 'N'
  AND EXISTS (
      SELECT 1
      FROM results_sent_log rsl
      WHERE rsl.order_number = apr.order_number
        AND rsl.result_test_code = apr.result_test_code
  )
ORDER BY 
    CASE WHEN apr.order_test_code IN ('332', '331') THEN 1 ELSE 2 END,
    apr.order_number;
