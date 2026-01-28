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
          asr.order_test_code IN ('301','310','312','303','308','336','332','315','317L','322','323','327','311')
         
      );

    DBMS_OUTPUT.PUT_LINE('Processing ' || v_asr_data.COUNT || ' records...');

    -- Processing loop (now functions exist)
    FOR i IN 1..v_asr_data.COUNT LOOP

                     
              
        IF v_asr_data(i).order_test_code = '301' THEN
               
            IF should_filter_301(
                
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
            
            If should_filter_301_new(
                
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
                -- Handle 310 filtering 
        ELSIF v_asr_data(i).order_test_code = '310' 
            and v_asr_data(i).result_test_code = '310'THEN
            
            --  Nonreactive
            IF should_filter_310(
                v_asr_data(i).order_number,
                v_asr_data(i).result_test_code,
                v_asr_data(i).textual_result_full,
                v_asr_data(i).source,
                v_asr_data(i).result_comment
            ) THEN
                v_rows_updated := update_asr_record(
                    v_asr_data(i).order_number,
                    p_order_test_code => v_asr_data(i).order_test_code
                );
                v_total_310_updated := v_total_310_updated + v_rows_updated;
            END IF;
            
            -- 310A Reactive and not >11.00 textual_result
            IF should_filter_310A(
                
                v_asr_data(i).order_number,
                v_asr_data(i).result_test_code,
                v_asr_data(i).textual_result_full,
                v_asr_data(i).source,
                v_asr_data(i).result_comment
            ) THEN
                dbms_output.put_line(v_asr_data(i).result_test_code);
                v_rows_updated := update_asr_record(
                    v_asr_data(i).order_number,
                    p_order_test_code => v_asr_data(i).order_test_code
                );
                v_total_310_updated := v_total_310_updated + v_rows_updated;    
            
            END IF;
               
        -- Handle 110 filtering 
        ELSIF v_asr_data(i).order_test_code = '110' 
            and v_asr_data(i).result_test_code = '110'THEN
            
            --  Nonreactive
            IF should_filter_110(
                v_asr_data(i).order_number,
                v_asr_data(i).result_test_code,
                v_asr_data(i).textual_result_full,
                v_asr_data(i).source,
                v_asr_data(i).result_comment
            ) THEN
                v_rows_updated := update_asr_record(
                    v_asr_data(i).order_number,
                    p_order_test_code => v_asr_data(i).order_test_code
                );
                v_total_310_updated := v_total_310_updated + v_rows_updated;
            END IF;
          
                
        -- Handle 111 filtering 
        ELSIF v_asr_data(i).order_test_code = '111' 
            and v_asr_data(i).result_test_code = '111' THEN
            
            --  Nonreactive
            IF should_filter_111(
                v_asr_data(i).order_number,
                v_asr_data(i).result_test_code,
                v_asr_data(i).textual_result_full,
                v_asr_data(i).source,
                v_asr_data(i).result_comment
            ) THEN
                v_rows_updated := update_asr_record(
                    v_asr_data(i).order_number,
                    p_order_test_code => v_asr_data(i).order_test_code
                );
                v_total_310_updated := v_total_310_updated + v_rows_updated;
            END IF;
          
                
        -- Handle 113 filtering 
        ELSIF v_asr_data(i).order_test_code = '113' 
            and v_asr_data(i).result_test_code = '113'THEN
            
            --  Nonreactive
            IF should_filter_113(
                v_asr_data(i).order_number,
                v_asr_data(i).result_test_code,
                v_asr_data(i).textual_result_full,
                v_asr_data(i).source,
                v_asr_data(i).result_comment
            ) THEN
                v_rows_updated := update_asr_record(
                    v_asr_data(i).order_number,
                    p_order_test_code => v_asr_data(i).order_test_code
                );
                v_total_310_updated := v_total_310_updated + v_rows_updated;
            END IF;
            
        -- Handle 312 filtering 
        ELSIF v_asr_data(i).order_test_code = '312' 
            and v_asr_data(i).result_test_code = '312' THEN
            
            --  Nonreactive
            IF should_filter_312(
                v_asr_data(i).order_number,
                v_asr_data(i).result_test_code,
                v_asr_data(i).textual_result_full,
                v_asr_data(i).source,
                v_asr_data(i).result_comment
            ) THEN
                v_rows_updated := update_asr_record(
                    v_asr_data(i).order_number,
                    p_order_test_code => v_asr_data(i).order_test_code
                );
                v_total_310_updated := v_total_310_updated + v_rows_updated;
            END IF;
            
            -- Handle 303 filtering 
        ELSIF v_asr_data(i).order_test_code = '303' 
            and v_asr_data(i).result_test_code = '303' THEN
            
            --  Nonreactive
            IF should_filter_303(
                v_asr_data(i).order_number,
                v_asr_data(i).result_test_code,
                v_asr_data(i).textual_result_full,
                v_asr_data(i).source,
                v_asr_data(i).result_comment
            ) THEN
                v_rows_updated := update_asr_record(
                    v_asr_data(i).order_number,
                    p_order_test_code => v_asr_data(i).order_test_code
                );
                v_total_310_updated := v_total_310_updated + v_rows_updated;
            END IF;
            
              -- Handle 308 filtering 
        ELSIF v_asr_data(i).order_test_code = '308' 
            and v_asr_data(i).result_test_code = '308' THEN
            
            --  Nonreactive
            IF should_filter_308(
                v_asr_data(i).order_number,
                v_asr_data(i).result_test_code,
                v_asr_data(i).textual_result_full,
                v_asr_data(i).source,
                v_asr_data(i).result_comment
            ) THEN
                v_rows_updated := update_asr_record(
                    v_asr_data(i).order_number,
                    p_order_test_code => v_asr_data(i).order_test_code
                );
                v_total_310_updated := v_total_310_updated + v_rows_updated;
            END IF;
            
                -- Handle 336 filtering 
        ELSIF v_asr_data(i).order_test_code = '336' 
            and v_asr_data(i).result_test_code = '336' THEN
            
            --  Nonreactive
            IF should_filter_336(
                v_asr_data(i).order_number,
                v_asr_data(i).result_test_code,
                v_asr_data(i).textual_result_full,
                v_asr_data(i).source,
                v_asr_data(i).result_comment
            ) THEN
                v_rows_updated := update_asr_record(
                    v_asr_data(i).order_number,
                    p_order_test_code => v_asr_data(i).order_test_code
                );
                v_total_310_updated := v_total_310_updated + v_rows_updated;
            END IF;
            
                   -- Handle 332 filtering 
        ELSIF v_asr_data(i).order_test_code = '332' 
            and v_asr_data(i).result_test_code = '332' THEN
            
            --  Nonreactive
            IF should_filter_332(
                v_asr_data(i).order_number,
                v_asr_data(i).result_test_code,
                v_asr_data(i).textual_result_full,
                v_asr_data(i).source,
                v_asr_data(i).result_comment
            ) THEN
                v_rows_updated := update_asr_record(
                    v_asr_data(i).order_number,
                    p_order_test_code => v_asr_data(i).order_test_code
                );
                v_total_310_updated := v_total_310_updated + v_rows_updated;
            END IF;
              -- Handle exclude measles by state filtering 
        ELSIF regexp_like(v_asr_data(i).order_test_code,'^(315|317L|322|323|327)$')
             THEN
            
            --  Nonreactive
            IF filter_measles_by_state(
                v_asr_data(i).order_number,
                v_asr_data(i).order_test_code,
                v_asr_data(i).textual_result_full,
                v_asr_data(i).source
                
            ) THEN
                v_rows_updated := update_asr_record(
                    v_asr_data(i).order_number,
                    p_order_test_code => v_asr_data(i).order_test_code
                );
                v_total_310_updated := v_total_310_updated + v_rows_updated;
                
            END IF;
            
              -- 311L Filtering 
        ELSIF regexp_like(v_asr_data(i).result_test_code,'^(311L)$')
             THEN
            
                v_rows_updated := update_asr_record(
                    v_asr_data(i).order_number,
                    p_result_test_code => v_asr_data(i).order_test_code
                );
                v_total_310_updated := v_total_310_updated + v_rows_updated;
               -- 311L Filtering 
        ELSIF regexp_like(v_asr_data(i).result_test_code,'^(311R)$')
             THEN
            
                v_rows_updated := update_asr_record(
                    v_asr_data(i).order_number,
                    p_result_test_code => v_asr_data(i).order_test_code
                );
                v_total_310_updated := v_total_310_updated + v_rows_updated;        
          
           
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


-- Create the update function
CREATE OR REPLACE FUNCTION update_asr_record(
    p_order_number VARCHAR2,
    p_result_test_code VARCHAR2 DEFAULT NULL,
    p_order_test_code VARCHAR2 DEFAULT NULL
) RETURN NUMBER
IS
    v_rows_updated NUMBER := 0;
BEGIN
    IF p_result_test_code IS NOT NULL THEN
        UPDATE asr_process_run_20250814_LF
        SET complete = 'F'
        WHERE order_number = p_order_number
          AND result_test_code = p_result_test_code;
          dbms_output.put_line('Updated: ' || p_result_test_code);
    ELSIF p_order_test_code IS NOT NULL THEN
        UPDATE asr_process_run_20250814_LF
        SET complete = 'F'
        WHERE order_number = p_order_number
          AND order_test_code = p_order_test_code;
    END IF;
    dbms_output.put_line(sql%rowcount);
    
    RETURN SQL%ROWCOUNT;
END update_asr_record;
/
DECLARE
    v_result BOOLEAN;
BEGIN
    v_result := should_filter_301_debug('58470S8', '301', 'Negative', 'IL', NULL);
END;
/

/