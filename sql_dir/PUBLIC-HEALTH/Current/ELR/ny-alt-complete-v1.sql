-- Refactored ASR Process Run Cleanup Script
-- Purpose: Mark orders complete ('D') when they have result_test_code='111' 
--          but no pending orders with specific test codes (301, 310, 308, etc.)
-- 
-- Business Rule: Orders with '111' results can be marked complete only if
--                there are no incomplete orders with specific test codes

DECLARE
    v_updated_count NUMBER := 0;
    
    -- Configuration constants
    c_source_state CONSTANT VARCHAR2(10) := 'NY';
    c_target_result_code CONSTANT VARCHAR2(10) := '111';
    c_status_incomplete CONSTANT CHAR(1) := 'N';
    c_status_done CONSTANT CHAR(1) := 'D';
    
BEGIN
    -- Single UPDATE statement replaces entire loop logic
    UPDATE asr_process_run apr
    SET apr.complete = c_status_done
    WHERE apr.result_test_code = c_target_result_code
      AND apr.complete = c_status_incomplete
      AND apr.source = c_source_state
      -- Optional: Uncomment to filter by activity date
      -- AND apr.activitydate = TRUNC(SYSDATE - 1)
      
      -- Only update if NO pending prerequisite tests exist
      AND NOT EXISTS (
          SELECT 1
          FROM asr_process_run prereq
          WHERE prereq.order_number = apr.order_number
            AND prereq.complete = c_status_incomplete
            AND REGEXP_LIKE(
                prereq.order_test_code,
                '^(301|310|308|311|318|303|304|312)$'
            )
      );
    
    v_updated_count := SQL%ROWCOUNT;
    COMMIT;
    
    -- Output results
    DBMS_OUTPUT.PUT_LINE('Orders marked complete: ' || v_updated_count);
    
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
        RAISE;
END;
/

-- Alternative: Query-only version to preview changes before executing
SELECT 
    apr.order_number,
    apr.result_test_code,
    apr.complete AS current_status,
    'D' AS new_status,
    COUNT(*) OVER (PARTITION BY apr.order_number) AS records_per_order
FROM asr_process_run apr
WHERE apr.result_test_code = '111'
  AND apr.complete = 'N'
  AND apr.source = 'NY'
  AND NOT EXISTS (
      SELECT 1
      FROM asr_process_run prereq
      WHERE prereq.order_number = apr.order_number
        AND prereq.complete = 'N'
        AND REGEXP_LIKE(prereq.order_test_code, '^(301|310|308|311|318|303|304|312)$')
  )
ORDER BY apr.order_number;
