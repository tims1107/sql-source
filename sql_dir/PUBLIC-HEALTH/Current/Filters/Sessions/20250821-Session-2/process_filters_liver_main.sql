DECLARE
    v_asr_data asr_filter_table;
    v_total_301_updated NUMBER := 0;
    v_total_310_updated NUMBER := 0;
    v_rows_updated NUMBER;
    v_asr_func boolean := false;
    
BEGIN
    -- Fixed constructor call with correct number of arguments
    SELECT asr_filter_obj(
        asr.order_number,           -- 1
        asr.result_test_code,       -- 2
        asr.order_test_code,        -- 3
        asr.textual_result_full,    -- 4
        asr.source,                 -- 5
        asr.complete,               -- 6
        s.state_abbreviation,       -- 7
        r.result_comment            -- 8
    )
    BULK COLLECT INTO v_asr_data
    FROM asr_process_run_20250814_LF asr
    JOIN state_master s ON s.state_abbreviation = asr.source
    JOIN ih_dw.results r ON r.requisition_id = asr.order_number 
                        AND r.result_test_code = asr.result_test_code
    WHERE asr.complete = 'L'
      AND REGEXP_LIKE(s.state_abbreviation, '^([A-Z]{2})$')
      AND s.entity_type = 'Abnormal'
      AND s.status = 'active'
      AND (
          asr.order_test_code IN ('110','111','113')
         
      );

    DBMS_OUTPUT.PUT_LINE('Processing ' || v_asr_data.COUNT || ' records...');

    -- Processing loop (now functions exist)
    FOR i IN 1..v_asr_data.COUNT LOOP

                     
              
        
               
            IF should_filter_111_110_113(
                
                v_asr_data(i).order_number,
                v_asr_data(i).result_test_code,
                v_asr_data(i).textual_result_full,
                v_asr_data(i).source,
                v_asr_data(i).result_comment
            ) THEN
                dbms_output.put_line(v_asr_data(i).result_test_code);
                v_rows_updated := update_asr_record(
                    v_asr_data(i).order_number,
                    p_result_test_code => v_asr_data(i).result_test_code
                );
                v_total_301_updated := v_total_301_updated + v_rows_updated;
            END IF;
            
            

    END LOOP;

    DBMS_OUTPUT.PUT_LINE('301 Records updated: ' || v_total_301_updated);
    DBMS_OUTPUT.PUT_LINE('310 Records updated: ' || v_total_310_updated);

    COMMIT;

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
        RAISE;
END;

/

DECLARE
    v_result BOOLEAN;
BEGIN
    v_result := should_filter_301_debug('58470S8', '301', 'Negative', 'IL', NULL);
END;
/

