-- Merge statement to insert records from il_output_results into asr_process_run
-- only if they don't already exist
MERGE INTO asr_process_run target
USING (
    SELECT 
        SUBSTR(REQUISITION_ID, 1, 7) as ORDER_NUMBER,
        SUBSTR(ORDER_TEST_CODE, 1, 5) as ORDER_TEST_CODE,
        SUBSTR(RESULT_TEST_CODE, 1, 5) as RESULT_TEST_CODE,
        SUBSTR(PERFORMING_LAB, 1, 5) as PERFORMING_LAB_ID,
        TEXTUAL_RESULT_FULL,
        SUBSTR(LNAME, 1, 128) as PATIENT_LAST_NAME,
        SUBSTR(STATE, 1, 2) as SOURCE,
        TO_CHAR(LAST_UPDATED_DATE, 'dd-MON-rr') as ACTIVITYDATE,
        'N' as COMPLETE
    FROM il_results_20250609
    WHERE regexp_like(order_test_code,'^301')
    
    
   -- AND textual_result_full = '>11.00'
    --AND order_test_code = '332'
    -- Add any filtering conditions here if needed
    -- WHERE STATE = 'NC' -- Example filter
) source
ON (
    target.ORDER_NUMBER = source.ORDER_NUMBER AND
    target.ORDER_TEST_CODE = source.ORDER_TEST_CODE AND
    target.RESULT_TEST_CODE = source.RESULT_TEST_CODE
)
WHEN NOT MATCHED THEN
    INSERT (
        ORDER_NUMBER,
        ORDER_TEST_CODE,
        RESULT_TEST_CODE,
        PERFORMING_LAB_ID,
        TEXTUAL_RESULT_FULL,
        PATIENT_LAST_NAME,
        SOURCE,
        ACTIVITYDATE,
        COMPLETE
    )
    VALUES (
        source.ORDER_NUMBER,
        source.ORDER_TEST_CODE,
        source.RESULT_TEST_CODE,
        source.PERFORMING_LAB_ID,
        source.TEXTUAL_RESULT_FULL,
        source.PATIENT_LAST_NAME,
        source.SOURCE,
        source.ACTIVITYDATE,
        source.COMPLETE
    );
/
-- Option 2

MERGE INTO asr_process_run target
USING (
    SELECT ORDER_NUMBER, ORDER_TEST_CODE, RESULT_TEST_CODE, PERFORMING_LAB_ID, 
           TEXTUAL_RESULT_FULL, PATIENT_LAST_NAME, SOURCE, ACTIVITYDATE, COMPLETE
    FROM (
        SELECT 
            SUBSTR(REQUISITION_ID, 1, 7) as ORDER_NUMBER,
            SUBSTR(ORDER_TEST_CODE, 1, 5) as ORDER_TEST_CODE,
            SUBSTR(RESULT_TEST_CODE, 1, 5) as RESULT_TEST_CODE,
            SUBSTR(PERFORMING_LAB, 1, 5) as PERFORMING_LAB_ID,
            TEXTUAL_RESULT_FULL,
            SUBSTR(LNAME, 1, 128) as PATIENT_LAST_NAME,
            SUBSTR(STATE, 1, 2) as SOURCE,
            TO_CHAR(LAST_UPDATED_DATE, 'dd-MON-rr') as ACTIVITYDATE,
            'N' as COMPLETE,
            ROW_NUMBER() OVER (
                PARTITION BY 
                    SUBSTR(REQUISITION_ID, 1, 7), 
                    SUBSTR(ORDER_TEST_CODE, 1, 5), 
                    SUBSTR(RESULT_TEST_CODE, 1, 5)
                ORDER BY LAST_UPDATED_DATE DESC
            ) as rn
        FROM il_results_20250610
        WHERE regexp_like(order_test_code,'^312')
    )
    WHERE rn = 1
) source
ON (
    target.ORDER_NUMBER = source.ORDER_NUMBER AND
    target.ORDER_TEST_CODE = source.ORDER_TEST_CODE AND
    target.RESULT_TEST_CODE = source.RESULT_TEST_CODE
)
WHEN NOT MATCHED THEN
    INSERT (
        ORDER_NUMBER,
        ORDER_TEST_CODE,
        RESULT_TEST_CODE,
        PERFORMING_LAB_ID,
        TEXTUAL_RESULT_FULL,
        PATIENT_LAST_NAME,
        SOURCE,
        ACTIVITYDATE,
        COMPLETE
    )
    VALUES (
        source.ORDER_NUMBER,
        source.ORDER_TEST_CODE,
        source.RESULT_TEST_CODE,
        source.PERFORMING_LAB_ID,
        source.TEXTUAL_RESULT_FULL,
        source.PATIENT_LAST_NAME,
        source.SOURCE,
        source.ACTIVITYDATE,
        source.COMPLETE
    );
    
/

select requisition_id,order_test_code,count(1) from il_results_20250610
where order_test_code = '311'
group by requisition_id,order_test_code;
having count(1) ;

select * from il_results_20250610
where regexp_like(order_test_code,'^(301|303|304|308|310|319N|311|318)$');
where requisition_id = '3700GC8';

select * from asr_process_run 
where complete = 'N'
and source = 'IL';

select * from hl7_message
order by hl7_message_pk;

select * from asr_process_run
where source = 'IL'
order by to_timestamp(to_date(activitydate,'dd-MON-rr')) desc;

update asr_process_run
set complete = 'N'
where order_number = '3197GN8';

delete results_sent_log
where order_number = '3197GN8';




/
-- 310 Filter
WITH matching_requisitions AS (
    -- Find requisitions with both required result patterns
    SELECT requisition_id
    FROM (
        SELECT DISTINCT
            requisition_id,
            result_test_code,
            textual_result_full
        FROM il_results_20250609
        WHERE order_test_code = '310'
        AND result_test_code IN ('310', '310A')
    )
    GROUP BY requisition_id
    HAVING 
        SUM(CASE WHEN result_test_code = '310' AND textual_result_full = 'Reactive' THEN 1 ELSE 0 END) >= 1
        AND SUM(CASE WHEN result_test_code = '310A' AND textual_result_full = '>11.00' THEN 1 ELSE 0 END) >= 1
),
-- Get unique result rows using stream-like processing
unique_results AS (
    SELECT 
        r.*,
        ROW_NUMBER() OVER (
            PARTITION BY 
                r.requisition_id, 
                r.result_test_code,
                r.textual_result_full
            ORDER BY r.last_updated_date DESC
        ) AS rn
    FROM il_results_20250609 r
    JOIN matching_requisitions m ON r.requisition_id = m.requisition_id
    WHERE r.order_test_code = '310'
    AND r.result_test_code IN ('310', '310A')
)
-- Select only unique rows
SELECT * FROM unique_results
WHERE rn = 1
ORDER BY requisition_id, result_test_code;

select * from il_results_20250610
where order_test_code = '310'
and requisition_id = '37078P8';
and textual_result_full = 'Reactive';

/

select * from hl7_message
order by creation_date;

update hl7_message
set status = 'SENT'
where hl7_message_pk = 142;

SET DEFINE OFF;

select hl7_message_pk from hl7_message
where regexp_like(message_content,'(^MSH).+(\|P\||\|T\|)','i')
and regexp_like(message_content,
and not regexp_like(message_content,'(PID.+CLIA\&PI)','i');
 
 SELECT * FROM hl7_message
WHERE REGEXP_LIKE(message_content, '^(PID)(.+)(&CLIA&PI)');

select * from hl7_message
where regexp_like(message_content,'(^ORC).+(SPECTRA)','i');
or regexp_like(message_content,'(^PID).+(CLIA\&PI)','i');

SELECT min(last_updated_date)
FROM il_results_20250609 r;

SELECT max(last_updated_date)
FROM il_results_20250609 r;

select * from asr_process_run
where complete = 'N';
    
    