WITH activity AS (
    SELECT lab_order_fk, requisition_id, last_updated_date 
    FROM ih_dw.dw_ods_activity
    WHERE last_updated_date > TRUNC(SYSDATE)
),
-- Get all 310 and 310A results
results_310 AS (
    SELECT 
        r.requisition_id,
        r.release_date_time,
        r.order_test_code,
        r.result_test_code,
        r.textual_result_full,
        CASE 
            WHEN r.result_test_code = '310' AND r.textual_result_full = 'Nonreactive' THEN 0
            WHEN r.result_test_code = '310' AND r.textual_result_full = 'Reactive' THEN 1
            ELSE 2
        END AS result_310_status,
        CASE 
            WHEN r.result_test_code = '310A' AND r.textual_result_full = '>11.00' THEN 1
            WHEN r.result_test_code = '310A' THEN 0
            ELSE 2
        END AS result_310A_status
    FROM activity a
    JOIN ih_dw.results r ON r.requisition_id = a.requisition_id
    WHERE r.order_test_code = '310'
    AND r.result_test_code IN ('310', '310A')
    AND r.result_status = 'F'
    --AND r.requisition_id IN ('2365FP4','2528KA4','5823JV8','6249K78')
),
-- Aggregate results by requisition_id to check conditions
filtered_reqs AS (
    SELECT 
        requisition_id,
        MAX(CASE WHEN result_test_code = '310' THEN textual_result_full ELSE NULL END) AS result_310,
        MAX(CASE WHEN result_test_code = '310A' THEN textual_result_full ELSE NULL END) AS result_310A,
        MIN(result_310_status) AS min_310_status,
        MIN(result_310A_status) AS min_310A_status
    FROM results_310
    GROUP BY requisition_id
    -- Keep only requisitions that pass our filter conditions
    HAVING NOT (
        MIN(result_310_status) = 0 OR -- Filter out if 310 is Nonreactive
        (MIN(result_310_status) = 1 AND MIN(result_310A_status) = 0) -- Filter out if 310 is Reactive and 310A is not >11.00
    )
)
-- Final result set with all columns
SELECT 
    r.requisition_id,
    r.release_date_time,
    r.order_test_code,
    r.result_test_code,
    r.textual_result_full
FROM ih_dw.results r
JOIN filtered_reqs fr ON r.requisition_id = fr.requisition_id
WHERE r.order_test_code = '310'
AND r.result_test_code IN ('310', '310A')
AND r.result_status = 'F'
ORDER BY r.requisition_id, r.result_test_code;