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
  
  -- Process data in batches
  WHILE v_has_more LOOP
    BEGIN
      -- Process ASR_PROCESS_RUN in batches - INSERT ONLY (no updates)
      FOR rec IN (
        SELECT 
          rr.ORDER_NUMBER, rr.ORDER_TEST_CODE, rr.RESULT_TEST_CODE, 
          rr.PERFORMING_LAB_ID, rr.TEXTUAL_RESULT_FULL, rr.PATIENT_LAST_NAME, 
          rr.SOURCE, rr.ACTIVITYDATE,
          CASE WHEN REGEXP_LIKE(rr.RESULT_TEST_CODE, '^P') THEN 'A' ELSE 'N' END AS COMPLETE,
          ROWNUM AS rn
        FROM report_results rr
        WHERE ROWNUM <= v_batch_size
        AND NOT EXISTS (
          SELECT 1 FROM ASR_PROCESS_RUN apr
          WHERE apr.ORDER_NUMBER = rr.ORDER_NUMBER
          AND apr.ORDER_TEST_CODE = rr.ORDER_TEST_CODE
          AND apr.RESULT_TEST_CODE = rr.RESULT_TEST_CODE
        )
      ) LOOP
        BEGIN
          INSERT INTO ASR_PROCESS_RUN (
            ORDER_NUMBER, ORDER_TEST_CODE, RESULT_TEST_CODE, 
            PERFORMING_LAB_ID, TEXTUAL_RESULT_FULL, PATIENT_LAST_NAME, 
            SOURCE, ACTIVITYDATE, COMPLETE
          ) VALUES (
            rec.ORDER_NUMBER, rec.ORDER_TEST_CODE, rec.RESULT_TEST_CODE, 
            rec.PERFORMING_LAB_ID, rec.TEXTUAL_RESULT_FULL, rec.PATIENT_LAST_NAME, 
            rec.SOURCE, rec.ACTIVITYDATE, rec.COMPLETE
          );
          
          v_total_count := v_total_count + 1;
          
          -- Also insert into PROMPT_TABLE if result_test_code starts with 'P'
          IF REGEXP_LIKE(rec.RESULT_TEST_CODE, '^P') THEN
            BEGIN
              INSERT INTO PROMPT_TABLE (
                ORDER_NUMBER, ORDER_TEST_CODE, RESULT_TEST_CODE, 
                PERFORMING_LAB_ID, TEXTUAL_RESULT_FULL, PATIENT_LAST_NAME, 
                SOURCE, ACTIVITYDATE, COMPLETE
              ) VALUES (
                rec.ORDER_NUMBER, rec.ORDER_TEST_CODE, rec.RESULT_TEST_CODE, 
                rec.PERFORMING_LAB_ID, rec.TEXTUAL_RESULT_FULL, rec.PATIENT_LAST_NAME, 
                rec.SOURCE, rec.ACTIVITYDATE, 'N'
              );
              
              v_prompt_count := v_prompt_count + 1;
            EXCEPTION
              WHEN DUP_VAL_ON_INDEX THEN
                NULL; -- Ignore duplicate records in PROMPT_TABLE
              WHEN OTHERS THEN
                log_message('Error inserting into PROMPT_TABLE: ' || SQLERRM || 
                            ' for record ' || rec.ORDER_NUMBER || '-' || rec.RESULT_TEST_CODE);
                v_error_count := v_error_count + 1;
            END;
          END IF;
          
        EXCEPTION
          WHEN DUP_VAL_ON_INDEX THEN
            NULL; -- Ignore duplicate records
          WHEN OTHERS THEN
            log_message('Error inserting into ASR_PROCESS_RUN: ' || SQLERRM || 
                        ' for record ' || rec.ORDER_NUMBER || '-' || rec.RESULT_TEST_CODE);
            v_error_count := v_error_count + 1;
        END;
      END LOOP;
      
      v_records_in_batch := SQL%ROWCOUNT;
      
      -- If we processed fewer records than the batch size, we're done
      v_has_more := (v_records_in_batch = v_batch_size);
      v_offset := v_offset + v_batch_size;
      
      COMMIT;
      log_message('Processed batch. Running total: ' || v_total_count || ' records');
      
    EXCEPTION
      WHEN OTHERS THEN
        log_message('Error processing batch: ' || SQLERRM);
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
with activity as 
(select lab_order_fk,requisition_id,last_updated_date from ih_dw.dw_ods_activity
where last_updated_date > trunc(sysdate))
select r.requisition_id,r.release_date_time,order_test_code,result_test_code,textual_result_full from activity a
join ih_dw.results r ON r.requisition_id = a.requisition_id
where regexp_like(order_test_code,'^(310)$')
and result_status = 'F'
and r.requisition_id IN ('2365FP4','2528KA4','5823JV8','6249K78');

and textual_result_full <> '>11.00'
order by r.requisition_id,order_test_code;
or textual_result_full = 'Reactive'
order by r.requisition_id,order_test_code;

-- 6248K08 310 textual_result_full = 'Nonreactive'
-- 5868AM8 
-- 6089MA8
