CREATE OR REPLACE FUNCTION build_condition_filter_sql(
    p_condition_id NUMBER,
    p_order_test_code VARCHAR2,
    p_result_test_code VARCHAR2,
    p_filter VARCHAR2,
    p_condition_value VARCHAR2,
    p_value_type VARCHAR2
) RETURN VARCHAR2
IS
    v_sql VARCHAR2(4000);
    v_processed_filter VARCHAR2(4000);
    v_formatted_value VARCHAR2(1000);
    v_safe_otc VARCHAR2(100);
    v_safe_rtc VARCHAR2(100);
BEGIN
    -- Sanitize input parameters
    v_safe_otc := REPLACE(REPLACE(p_order_test_code, '''', ''''''), CHR(0), '');
    v_safe_rtc := REPLACE(REPLACE(p_result_test_code, '''', ''''''), CHR(0), '');
    
    -- Base query without condition_master_pk
    v_sql := 'SELECT 
        gtt.*
    FROM GTT_RESULTS_EXTRACT gtt
    WHERE 1=1';
    
--    v_sql := 'SELECT 
--        gtt.*,
--        ' || p_condition_id || ' as condition_master_pk
--    FROM GTT_RESULTS_EXTRACT_TEST gtt
--    WHERE 1=1';
    
    -- Add test code filters
    IF v_safe_otc IS NOT NULL AND LENGTH(TRIM(v_safe_otc)) > 0 THEN
        v_sql := v_sql || ' AND gtt.order_test_code = ''' || v_safe_otc || '''';
    END IF;
    
    IF v_safe_rtc IS NOT NULL AND LENGTH(TRIM(v_safe_rtc)) > 0 THEN
        v_sql := v_sql || ' AND gtt.result_test_code = ''' || v_safe_rtc || '''';
    END IF;
    
    -- Process dynamic filter with smart replacement
    IF p_filter IS NOT NULL AND LENGTH(TRIM(p_filter)) > 0 THEN
        v_processed_filter := p_filter;
        
        -- Replace table alias first
        v_processed_filter := REPLACE(v_processed_filter, 'r.', 'gtt.');
        
        -- Smart replacement based on context and value type
        IF p_condition_value IS NOT NULL THEN
            IF UPPER(p_value_type) = 'ST' THEN
                -- For string values, check if {0} is already inside quotes
                IF INSTR(v_processed_filter, '''%{0}%''') > 0 OR 
                   INSTR(v_processed_filter, '''{0}''') > 0 OR
                   INSTR(v_processed_filter, '''%{0}') > 0 OR
                   INSTR(v_processed_filter, '{0}%''') > 0 THEN
                    -- {0} is already inside quotes, replace without adding quotes
                    v_formatted_value := REPLACE(p_condition_value, '''', '''''');
                ELSE
                    -- {0} is not inside quotes, add quotes
                    v_formatted_value := '''' || REPLACE(p_condition_value, '''', '''''') || '''';
                END IF;
            ELSIF UPPER(p_value_type) = 'NM' THEN
                -- Numeric values never need quotes
                v_formatted_value := p_condition_value;
            ELSE
                -- Default handling for unknown types
                IF INSTR(v_processed_filter, '''%{0}%''') > 0 OR 
                   INSTR(v_processed_filter, '''{0}''') > 0 THEN
                    v_formatted_value := REPLACE(p_condition_value, '''', '''''');
                ELSE
                    v_formatted_value := '''' || REPLACE(p_condition_value, '''', '''''') || '''';
                END IF;
            END IF;
        ELSE
            v_formatted_value := 'NULL';
        END IF;
        
        -- Replace {0} with the formatted value
        v_processed_filter := REPLACE(v_processed_filter, '{0}', v_formatted_value);
        
        -- Debug output
        DBMS_OUTPUT.PUT_LINE('Condition ' || p_condition_id || ':');
        DBMS_OUTPUT.PUT_LINE('  Original filter: ' || p_filter);
        DBMS_OUTPUT.PUT_LINE('  Value Type: ' || NVL(p_value_type, 'NULL'));
        DBMS_OUTPUT.PUT_LINE('  Raw Value: ' || NVL(p_condition_value, 'NULL'));
        DBMS_OUTPUT.PUT_LINE('  Formatted Value: ' || v_formatted_value);
        DBMS_OUTPUT.PUT_LINE('  Final filter: ' || v_processed_filter);
        
        IF is_filter_safe(v_processed_filter) THEN
            v_sql := v_sql || ' AND (' || TRIM(v_processed_filter) || ')';
        ELSE
            DBMS_OUTPUT.PUT_LINE('SECURITY WARNING: Unsafe filter for condition ' || p_condition_id);
        END IF;
    END IF;
    
    RETURN v_sql;
    
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error building SQL for condition ' || p_condition_id || ': ' || SQLERRM);
        RETURN 'SELECT gtt.* FROM GTT_RESULTS_EXTRACT gtt WHERE 1=0';
END build_condition_filter_sql;
/