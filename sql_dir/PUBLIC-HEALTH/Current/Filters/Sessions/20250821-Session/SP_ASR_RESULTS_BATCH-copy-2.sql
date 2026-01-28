CREATE OR REPLACE PROCEDURE SP_ASR_RESULTS_BATCH (
    p_state_fk IN NUMBER,
    p_recordset OUT SYS_REFCURSOR
) AS
    v_final_sql CLOB := '';
    v_condition_sql VARCHAR2(4000);
    v_condition_count NUMBER := 0;
    v_test_cursor SYS_REFCURSOR;
    v_test_count NUMBER;
    
BEGIN
    -- Build and test each condition individually before adding to UNION
    FOR rec IN (
        SELECT 
            cm.condition_master_pk,
            cm.order_test_code,
            cm.result_test_code,
            cm.condition_value,
            cm.value_type,
            cf.filter
        FROM CONDITION_MASTER cm
        JOIN CONDITION_FILTERS cf ON cm.condition_filter_fk = cf.condition_filter_pk
        WHERE cm.state_fk = p_state_fk
        AND cm.status = 'active'
        AND cf.status = 'active'
        AND regexp_like(cm.order_test_code,'^(301|308|310|311|318)$') 
        ORDER BY cm.condition_master_pk
    ) LOOP
        v_condition_count := v_condition_count + 1;
        
        DBMS_OUTPUT.PUT_LINE('=== Testing Condition ' || rec.condition_master_pk || ' ===');
        DBMS_OUTPUT.PUT_LINE('OTC: ' || NVL(rec.order_test_code, 'NULL'));
        DBMS_OUTPUT.PUT_LINE('RTC: ' || NVL(rec.result_test_code, 'NULL'));
        DBMS_OUTPUT.PUT_LINE('Value: ' || NVL(rec.condition_value, 'NULL'));
        DBMS_OUTPUT.PUT_LINE('Value Type: ' || NVL(rec.value_type, 'NULL'));
        DBMS_OUTPUT.PUT_LINE('Filter: ' || NVL(rec.filter, 'NULL'));
        
        -- Build SQL for this condition
        v_condition_sql := build_condition_filter_sql(
            rec.condition_master_pk,
            rec.order_test_code,
            rec.result_test_code,
            rec.filter,
            rec.condition_value,
            rec.value_type
        );
        
        DBMS_OUTPUT.PUT_LINE('Generated SQL: ' || v_condition_sql);
        
        -- Test this individual condition SQL
        BEGIN
            EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM (' || v_condition_sql || ')' INTO v_test_count;
            DBMS_OUTPUT.PUT_LINE('? Condition ' || rec.condition_master_pk || ' test PASSED, count: ' || v_test_count);
            
            -- Add to UNION ALL only if test passed
            IF v_condition_count = 1 THEN
                v_final_sql := v_condition_sql;
            ELSE
                v_final_sql := v_final_sql || ' UNION ALL ' || v_condition_sql;
            END IF;
            
        EXCEPTION
            WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE('? ERROR in condition ' || rec.condition_master_pk || ': ' || SQLERRM);
                DBMS_OUTPUT.PUT_LINE('Problematic SQL: ' || v_condition_sql);
                -- Skip this condition and continue with others
                v_condition_count := v_condition_count - 1;
        END;
        
        DBMS_OUTPUT.PUT_LINE(''); -- Empty line for readability
    END LOOP;
    
    -- Execute final query
    IF v_condition_count > 0 THEN
        v_final_sql := 'SELECT * FROM (' || v_final_sql || ') 
                        ORDER BY condition_master_pk, accession_number, order_test_code';
        
        DBMS_OUTPUT.PUT_LINE('Final query built successfully with ' || v_condition_count || ' conditions');
        
        -- Test the final UNION query
        BEGIN
            EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM (' || v_final_sql || ')' INTO v_test_count;
            DBMS_OUTPUT.PUT_LINE('Final UNION query test PASSED, total count: ' || v_test_count);
            
            dbms_output.put_line('-----------------------------------------------------------------------');
            dbms_output.put_line(v_final_sql);
            OPEN p_recordset FOR v_final_sql;
        EXCEPTION
            WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE('ERROR in final UNION query: ' || SQLERRM);
                DBMS_OUTPUT.PUT_LINE('Final SQL length: ' || LENGTH(v_final_sql));
                DBMS_OUTPUT.PUT_LINE('First 1000 chars: ' || SUBSTR(v_final_sql, 1, 1000));
                RAISE;
        END;
    ELSE
        DBMS_OUTPUT.PUT_LINE('No valid conditions found for state_fk: ' || p_state_fk);
        OPEN p_recordset FOR 
            SELECT gtt.*, 0 as condition_master_pk
            FROM GTT_RESULTS_EXTRACT gtt WHERE 1=0;
    END IF;
    
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error in SP_ASR_RESULTS_BATCH: ' || SQLERRM);
        RAISE;
END SP_ASR_RESULTS_BATCH;
/