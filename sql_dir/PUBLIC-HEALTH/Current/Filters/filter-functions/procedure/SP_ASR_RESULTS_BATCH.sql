CREATE OR REPLACE PROCEDURE SP_ASR_RESULTS_BATCH (
    p_state_fk IN NUMBER,
    p_recordset OUT SYS_REFCURSOR
) AS
    v_final_sql CLOB := '';
    v_condition_sql VARCHAR2(4000);
    v_condition_count NUMBER := 0;
    
BEGIN
    -- Build UNION ALL query including value_type
    FOR rec IN (
        SELECT 
            cm.condition_master_pk,
            cm.order_test_code,
            cm.result_test_code,
            cm.condition_value,
            cm.value_type,  -- Add this field
            cf.filter
        FROM CONDITION_MASTER cm
        JOIN CONDITION_FILTERS cf ON cm.condition_filter_fk = cf.condition_filter_pk
        WHERE cm.state_fk = p_state_fk
        AND cm.status = 'active'
        AND cf.status = 'active'
        AND regexp_like(cm.order_test_code,'^(301|303|304|310|311|318|332|336|322|315|317L|323|327)$') 
        ORDER BY cm.condition_master_pk
    ) LOOP
        v_condition_count := v_condition_count + 1;
        
        -- Use the function with value_type parameter
        v_condition_sql := build_condition_filter_sql(
            rec.condition_master_pk,
            rec.order_test_code,
            rec.result_test_code,
            rec.filter,
            rec.condition_value,
            rec.value_type  -- Pass the value_type
        );
        
        -- Add to UNION ALL
        IF v_condition_count = 1 THEN
            v_final_sql := v_condition_sql;
        ELSE
            v_final_sql := v_final_sql || ' UNION ALL ' || v_condition_sql;
        END IF;
        
    END LOOP;
    
    -- Execute final query
    IF v_condition_count > 0 THEN
        v_final_sql := 'SELECT * FROM (' || v_final_sql || ') 
                        ORDER BY accession_number, order_test_code';
        
        DBMS_OUTPUT.PUT_LINE('Processing ' || v_condition_count || ' conditions for state_fk: ' || p_state_fk);
        
        dbms_output.put_line(v_final_sql);
        
        OPEN p_recordset FOR v_final_sql;
    ELSE
        DBMS_OUTPUT.PUT_LINE('No active conditions found for state_fk: ' || p_state_fk);
        OPEN p_recordset FOR 
            SELECT gtt.*, 0 as condition_master_pk
            FROM GTT_RESULTS_EXTRACT gtt WHERE 1=0;
    END IF;
    
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error in SP_ASR_RESULTS_BATCH: ' || SQLERRM);
        DBMS_OUTPUT.PUT_LINE('Last condition SQL: ' || SUBSTR(v_condition_sql, 1, 500));
        RAISE;
END SP_ASR_RESULTS_BATCH;
/

update gtt_results_extract_test
set facility_id = 'X123457'
where accession_number = '336393NJ8';


/

DECLARE 
    v_recordset SYS_REFCURSOR;
    v_sql VARCHAR2(4000);
    v_cursor_id NUMBER;
    v_col_count NUMBER;
    v_desc_tab DBMS_SQL.DESC_TAB;
    v_row_count NUMBER := 0;
    v_value VARCHAR2(4000);
BEGIN
    -- Call your procedure
    SP_ASR_RESULTS_BATCH(12, v_recordset);
    
    -- Convert REF CURSOR to DBMS_SQL cursor for dynamic processing
    v_cursor_id := DBMS_SQL.TO_CURSOR_NUMBER(v_recordset);
    
    -- Describe the cursor to get column information
    DBMS_SQL.DESCRIBE_COLUMNS(v_cursor_id, v_col_count, v_desc_tab);
    
    -- Print column headers
    DBMS_OUTPUT.PUT_LINE('=== RESULTS ===');
    FOR i IN 1..10 LOOP
        DBMS_OUTPUT.PUT(RPAD(v_desc_tab(i).col_name, 20) || ' | ');
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('');
    
    -- Print separator line
    FOR i IN 1..10 LOOP
        DBMS_OUTPUT.PUT(RPAD('-', 20, '-') || ' | ');
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('');
    
    -- Define columns for fetching
    FOR i IN 1..10 LOOP
        DBMS_SQL.DEFINE_COLUMN(v_cursor_id, i, v_value, 4000);
    END LOOP;
    
    -- Fetch and display rows
    WHILE DBMS_SQL.FETCH_ROWS(v_cursor_id) > 0 LOOP
        v_row_count := v_row_count + 1;
        
        FOR i IN 1..10 LOOP
            DBMS_SQL.COLUMN_VALUE(v_cursor_id, i, v_value);
            DBMS_OUTPUT.PUT(RPAD(NVL(v_value, 'NULL'), 20) || ' | ');
        END LOOP;
        DBMS_OUTPUT.PUT_LINE('');
        
        -- Limit output to prevent overwhelming the console
        IF v_row_count >= 50 THEN
            DBMS_OUTPUT.PUT_LINE('... (showing first 50 rows only)');
            EXIT;
        END IF;
    END LOOP;
    
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('Total rows processed: ' || v_row_count);
    
    -- Close cursor
    DBMS_SQL.CLOSE_CURSOR(v_cursor_id);
    
EXCEPTION
    WHEN OTHERS THEN
        IF DBMS_SQL.IS_OPEN(v_cursor_id) THEN
            DBMS_SQL.CLOSE_CURSOR(v_cursor_id);
        END IF;
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;
/

/

select cm.*,filter from condition_master cm
join condition_filters cf ON cf.condition_filter_pk = cm.condition_filter_fk
and state_fk = 12
order by condition_master_pk;

select state_master_pk,state_abbreviation,state from state_master
--where state_abbreviation = 'TX'
where entity_type = 'Abnormal'
and status = 'active'
and length(state_abbreviation) = 2
order by state_abbreviation;

SELECT 
        gtt.*,
        1919 as condition_master_pk
    FROM GTT_RESULTS_EXTRACT gtt
    WHERE 1=1 AND gtt.order_test_code = '310' AND gtt.result_test_code = '310A' AND ((gtt.value_type = 'NM' and gtt.numeric_result > 0.00));
    
SELECT 
        gtt.*,
        860 as condition_master_pk
    FROM GTT_RESULTS_EXTRACT gtt
    WHERE 1=1 AND gtt.order_test_code = '310' AND gtt.result_test_code = '310A' AND ((gtt.value_type = 'ST' and gtt.textual_result_full like '%>11.00%'));