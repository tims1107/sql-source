select count(1) from ih_dw.dw_ods_activity a
join ih_dw.results r ON r.requisition_id = a.requisition_id 
 where a.last_updated_date > to_timestamp(to_char('2025-08-10 01:00:00','yyyy-MM-dd hh24:mi:ss'))
 and order_test_code IN ('310','301')
 order by order_test_code;
 
 select  to_char('2025-08-10 01:00:00','yyyy-MM-dd hh:mi:ss') from dual;
 
 SELECT requisition_id, order_test_code, COUNT(*) 
FROM ih_dw.results 
WHERE requisition_id IN ('5787P58', '58721H8', '61308C8')
GROUP BY requisition_id, order_test_code
ORDER BY requisition_id, order_test_code;

/

-- Step 1: Get activities
WITH activities AS (
    SELECT requisition_id 
    FROM ih_dw.dw_ods_activity 
    WHERE last_updated_date >trunc(sysdate)
),

-- Step 2: Get all results for those activities  
all_results AS (
    SELECT r.* 
    FROM ih_dw.results r
    INNER JOIN activities a ON r.requisition_id = a.requisition_id
)

-- Step 3: Filter by configured order test codes
SELECT * 
FROM all_results 
WHERE order_test_code IN ('310');

select requisition_id,order_test_code,result_test_code from ih_dw.results
where requisition_id = '26435J4'
and order_test_code = '310';

/

CREATE OR REPLACE VIEW VW_ACTIVITY_RESULTS_SUMMARY AS
WITH act AS (
    SELECT 
        requisition_id,
        last_updated_date
    FROM IH_DW.DW_ODS_ACTIVITY
),
results AS (
    SELECT
        r.last_updated_date,
        r.requisition_id,
        r.order_test_code,
        r.order_test_name,
        r.result_test_code,
        r.result_test_name,
        1 as result_count  -- Each row represents one result record
    FROM IH_DW.RESULTS r
)
SELECT 
    act.requisition_id,
    results.last_updated_date,
    results.order_test_code,
    results.order_test_name,
    results.result_test_code,
    results.result_test_name,
    results.result_count
FROM act 
INNER JOIN results ON results.requisition_id = act.requisition_id;

/

CREATE OR REPLACE VIEW VW_ACTIVITY_RESULTS_SUMMARY AS
SELECT 
    a.requisition_id,
    r.last_updated_date,
    r.order_test_code,
    r.order_test_name,
    r.result_test_code,
    r.result_test_name,
    1 as result_count  -- Each row represents one result record
FROM IH_DW.DW_ODS_ACTIVITY a
INNER JOIN IH_DW.RESULTS r ON a.requisition_id = r.requisition_id;

/

select order_test_code,count(1) from VW_ACTIVITY_RESULTS_SUMMARY
where last_updated_date > to_timestamp('2025-08-11T00:00:00')
and result_test_code IN ('301','310')
group by order_test_code;

SELECT s.last_updated_date,s.requisition_id,s.result_test_code,r.textual_result_full
FROM STATERPT_OWNER.VW_ACTIVITY_RESULTS_SUMMARY s
join ih_dw.results r ON r.requisition_id = s.requisition_id and r.result_test_code = s.result_test_code
WHERE s.last_updated_date > TO_TIMESTAMP('2025-08-11T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS');
AND r.order_test_code IN ('301','310')
and r.textual_result_full IN ('Positive','Reactive');
GROUP BY order_test_code;


select textual_result_full,last_updated_date from ih_dw.results
where requisition_id = '60867U8'
and order_test_code = '310';

select to_char(to_date(trunc(sysdate)),'hh:mi') from dual;

SELECT TO_CHAR(TRUNC(SYSDATE), 'YYYY-MM-DD"T"HH24:MI:SS') FROM DUAL;
-- Returns: '2025-08-11T00:00:00'

