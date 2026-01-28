DECLARE
  v_batch_size CONSTANT PLS_INTEGER := 100;
  v_total_count PLS_INTEGER := 0;
  v_prompt_count PLS_INTEGER := 0;
  v_error_count PLS_INTEGER := 0;
  v_start_time TIMESTAMP := SYSTIMESTAMP;
  v_offset PLS_INTEGER := 0;
  v_has_more BOOLEAN := TRUE;
  v_records_in_batch PLS_INTEGER := 0;
  v_has_more_count PLS_INTEGER := 0;
  
  -- Log procedure
  PROCEDURE log_message(p_message VARCHAR2) IS
  BEGIN
    dbms_output.put_line(TO_CHAR(SYSTIMESTAMP, 'HH24:MI:SS.FF') || ' - ' || p_message);
  END;
  
BEGIN
  log_message('Starting processing for all records in report_results');
  
  -- Process data in batches using MERGE
  WHILE v_has_more LOOP
    BEGIN
      -- Process ASR_PROCESS_RUN in batches - INSERT ONLY (no updates)
      MERGE INTO ASR_PROCESS_RUN target
      USING (
        SELECT * FROM (
          SELECT 
            rr.ORDER_NUMBER, rr.ORDER_TEST_CODE, rr.RESULT_TEST_CODE, 
            rr.PERFORMING_LAB_ID, rr.TEXTUAL_RESULT_FULL, rr.PATIENT_LAST_NAME, 
            rr.SOURCE, rr.ACTIVITYDATE,
            CASE WHEN REGEXP_LIKE(rr.RESULT_TEST_CODE, '^P') THEN 'A' ELSE 'N' END AS COMPLETE,
            ROW_NUMBER() OVER (ORDER BY rr.ORDER_NUMBER, rr.RESULT_TEST_CODE) AS rn
          FROM report_results rr
        ) 
        WHERE rn BETWEEN v_offset + 1 AND v_offset + v_batch_size
      ) source
      ON (
        target.ORDER_NUMBER = source.ORDER_NUMBER AND 
        target.RESULT_TEST_CODE = source.RESULT_TEST_CODE
      )
      WHEN NOT MATCHED THEN
        INSERT (
          ORDER_NUMBER, ORDER_TEST_CODE, RESULT_TEST_CODE, 
          PERFORMING_LAB_ID, TEXTUAL_RESULT_FULL, PATIENT_LAST_NAME, 
          SOURCE, ACTIVITYDATE, COMPLETE
        )
        VALUES (
          source.ORDER_NUMBER, source.ORDER_TEST_CODE, source.RESULT_TEST_CODE,
          source.PERFORMING_LAB_ID, source.TEXTUAL_RESULT_FULL, source.PATIENT_LAST_NAME,
          source.SOURCE, source.ACTIVITYDATE, source.COMPLETE
        );
      
      -- Count records processed in this batch
      v_records_in_batch := SQL%ROWCOUNT;
      v_total_count := v_total_count + v_records_in_batch;
      log_message('Inserted ' || v_records_in_batch || ' records in ASR_PROCESS_RUN');
      
      -- Process PROMPT_TABLE for records with result_test_code starting with 'P'
      MERGE INTO PROMPT_TABLE target
      USING (
        SELECT * FROM (
          SELECT 
            rr.ORDER_NUMBER, rr.ORDER_TEST_CODE, rr.RESULT_TEST_CODE, 
            rr.PERFORMING_LAB_ID, rr.TEXTUAL_RESULT_FULL, rr.PATIENT_LAST_NAME, 
            rr.SOURCE, rr.ACTIVITYDATE, 'N' AS COMPLETE,
            ROW_NUMBER() OVER (ORDER BY rr.ORDER_NUMBER, rr.RESULT_TEST_CODE) AS rn
          FROM report_results rr
          WHERE REGEXP_LIKE(rr.RESULT_TEST_CODE, '^P')
        )
        WHERE rn BETWEEN v_offset + 1 AND v_offset + v_batch_size
      ) source
      ON (
        target.ORDER_NUMBER = source.ORDER_NUMBER AND 
        target.RESULT_TEST_CODE = source.RESULT_TEST_CODE
      )
      WHEN NOT MATCHED THEN
        INSERT (
          ORDER_NUMBER, ORDER_TEST_CODE, RESULT_TEST_CODE, 
          PERFORMING_LAB_ID, TEXTUAL_RESULT_FULL, PATIENT_LAST_NAME, 
          SOURCE, ACTIVITYDATE, COMPLETE
        )
        VALUES (
          source.ORDER_NUMBER, source.ORDER_TEST_CODE, source.RESULT_TEST_CODE,
          source.PERFORMING_LAB_ID, source.TEXTUAL_RESULT_FULL, source.PATIENT_LAST_NAME,
          source.SOURCE, source.ACTIVITYDATE, source.COMPLETE
        );
      
      -- Count prompt records processed
      v_prompt_count := v_prompt_count + SQL%ROWCOUNT;
      
      -- Check if we have more records to process
      SELECT COUNT(*) INTO v_has_more_count 
      FROM (
        SELECT 1 FROM report_results 
        WHERE ROWNUM <= v_offset + v_batch_size + 1
      );
      
      -- If we processed fewer records than the batch size, we're done
      v_has_more := (v_records_in_batch = v_batch_size);
      v_offset := v_offset + v_batch_size;
      
      COMMIT;
      log_message('Processed batch. Running total: ' || v_total_count || ' records');
      
    EXCEPTION
      WHEN OTHERS THEN
        log_message('Error processing batch: ' || SQLERRM || ' at ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
        v_error_count := v_error_count + 1;
        ROLLBACK;
    END;
  END LOOP;
  
  -- Log summary
  log_message('Processing complete. Duration: ' || 
              TO_CHAR(EXTRACT(SECOND FROM (SYSTIMESTAMP - v_start_time))) || ' seconds');
  log_message('Total records: ' || v_total_count);
  log_message('Prompt records: ' || v_prompt_count);
  log_message('Errors: ' || v_error_count);
  
  -- Insert log record
  INSERT INTO asr_load_log (
    EXTRACTID, LOGGEDAT, ERRORCOUNT, ACTIVITYDATE, PROMPTCOUNT, GENERALCOUNT
  ) VALUES (
    asr_extract_log_seq.nextval, SYSTIMESTAMP, v_error_count, 
    NULL, v_prompt_count, v_total_count
  );
  
  COMMIT;
  
  log_message('Process completed successfully');
END;
/

select * from report_results;

select * from asr_process_run
where complete = 'N';

select result_test_code,textual_result_full from ih_dw.results
where requisition_id = '2374KG4';

create table asr_process_run_20250807
as
select * from asr_process_run;

select r.order_number,o.order_number,r.complete,o.complete from asr_process_run o
full outer join asr_process_run_20250806 r ON r.order_number = o.order_number and r.result_test_code = o.result_test_code
where o.activitydate = '05-AUG-25'
and o.complete = 'N';
and r.complete not in ('R','D','Q');

delete asr_process_run;

insert into asr_process_run
select * from asr_process_run_20250807;

delete asr_process_run
where order_number IN ('5787X08','6107S38','6107538');

select order_number,result_test_code,complete,source,textual_result_full from asr_process_run
where activitydate = '07-AUG-25'
and source = 'NC';

delete asr_process_run
where order_number IN ('2634GZ4');



select * from
(SELECT requisition_id,to_char(release_date_time, 'dd-MON-yy hh24:mi') rel_date, result_test_code, textual_result_full,result_comment
FROM ih_dw.results
WHERE (requisition_id, result_test_code) IN (
    SELECT order_number, result_test_code 
    FROM asr_process_run
    WHERE activitydate = '06-AUG-25'
))
order by rel_date desc;

select * from ih_dw.dw_ods_activity
where requisition_id = '58856M8';

select * from asr_process_run
where activitydate = '08-AUG-25'
and source= 'NY'
and result_test_code = '111'
and complete='N';

select * from report_results
where source = 'AL';

select order_number from asr_process_run_20250806;

select result_test_code,source,count(1) from asr_process_run
where complete='N'
group by result_test_code,source
order by source;

where

where order_number IN
(select order_number from asr_process_run
where activitydate = '05-AUG-25'
and complete IN ('N')
;