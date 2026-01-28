-- ================================================================
-- TEST 310 VALIDATION LOGIC FOR ORDER 68508A8
-- Debug why this specific order is being excluded
-- ================================================================

-- Check what the 310 validation subquery returns for order 68508A8
SELECT 
    'Validation check for 68508A8' as test_type,
    COUNT(DISTINCT result_test_code) as distinct_result_codes,
    LISTAGG(DISTINCT result_test_code, ',') WITHIN GROUP (ORDER BY result_test_code) as result_codes_found
FROM GTT_RESULTS_EXTRACT orig_gtt 
WHERE orig_gtt.order_number = '68508A8'
AND orig_gtt.order_test_code = '310' 
AND orig_gtt.result_test_code IN ('310', '310A') 
AND orig_gtt.patient_account_state = 'TX' 
AND TRUNC(orig_gtt.release_date_time) = DATE '2025-09-02';

-- Check all 310 records for this order
SELECT 
    'All 310 records for 68508A8' as test_type,
    order_number,
    order_test_code,
    result_test_code,
    value_type,
    numeric_result,
    textual_result_full
FROM GTT_RESULTS_EXTRACT 
WHERE order_number = '68508A8'
AND order_test_code = '310'
AND patient_account_state = 'TX' 
AND TRUNC(release_date_time) = DATE '2025-09-02'
ORDER BY result_test_code;

-- Test the 310 validation condition specifically
SELECT 
    'Testing 310 validation condition' as test_type,
    base.order_number,
    base.order_test_code,
    base.result_test_code,
    base.value_type,
    base.numeric_result,
    CASE 
        WHEN base.order_test_code != '310' THEN 'NOT 310 - INCLUDED'
        WHEN (SELECT COUNT(DISTINCT result_test_code) 
              FROM GTT_RESULTS_EXTRACT orig_gtt 
              WHERE orig_gtt.order_number = base.order_number 
              AND orig_gtt.order_test_code = '310' 
              AND orig_gtt.result_test_code IN ('310', '310A') 
              AND orig_gtt.patient_account_state = 'TX' 
              AND TRUNC(orig_gtt.release_date_time) = DATE '2025-09-02') = 2 THEN 'HAS BOTH 310 AND 310A - INCLUDED'
        ELSE 'MISSING 310 OR 310A - EXCLUDED'
    END as validation_result
FROM (
    -- Test both records for order 68508A8
    SELECT * FROM GTT_RESULTS_EXTRACT 
    WHERE order_number = '68508A8'
    AND order_test_code = '310'
    AND patient_account_state = 'TX' 
    AND TRUNC(release_date_time) = DATE '2025-09-02'
) base;

-- Check if there are any other orders with similar pattern
SELECT 
    'Orders with 310 but missing validation' as test_type,
    order_number,
    COUNT(*) as total_310_records,
    COUNT(CASE WHEN result_test_code = '310' THEN 1 END) as count_310,
    COUNT(CASE WHEN result_test_code = '310A' THEN 1 END) as count_310A,
    LISTAGG(DISTINCT result_test_code, ',') WITHIN GROUP (ORDER BY result_test_code) as result_codes
FROM GTT_RESULTS_EXTRACT 
WHERE order_test_code = '310'
AND patient_account_state = 'TX' 
AND TRUNC(release_date_time) = DATE '2025-09-02'
GROUP BY order_number
HAVING COUNT(CASE WHEN result_test_code = '310' THEN 1 END) > 0 
   AND COUNT(CASE WHEN result_test_code = '310A' THEN 1 END) > 0
ORDER BY order_number;

SELECT value_type, numeric_result, 
       CASE WHEN numeric_result > 0.00 THEN 'SHOULD MATCH' ELSE 'NO MATCH' END
FROM GTT_RESULTS_EXTRACT 
WHERE order_number = '68508A8' AND result_test_code = '310A';
