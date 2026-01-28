-- ================================================================
-- COMPLETE get_base_condition_sql FUNCTION WITH 310 VALIDATION FIX
-- Full integration of 310 validation logic into existing function
-- ================================================================

FUNCTION get_base_condition_sql(
    p_state_abbrev VARCHAR2,
    p_process_date DATE
) RETURN CLOB IS
    v_final_sql CLOB := '';
    v_condition_sql VARCHAR2(4000);
    v_condition_count NUMBER := 0;
    v_state_pk NUMBER;
    v_test_code_count NUMBER := 0;
    
BEGIN
    -- Get state primary key
    BEGIN
        SELECT state_master_pk 
        INTO v_state_pk
        FROM state_master 
        WHERE state_abbreviation = p_state_abbrev;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('WARNING: State ' || p_state_abbrev || ' not found in state_master');
            RETURN 'SELECT gtt.*, 0 as condition_master_pk FROM GTT_RESULTS_EXTRACT gtt WHERE 1=0';
    END;
    
    -- Count valid test codes for logging
    SELECT COUNT(DISTINCT cm.order_test_code)
    INTO v_test_code_count
    FROM CONDITION_MASTER cm
    JOIN CONDITION_FILTERS cf ON cm.condition_filter_fk = cf.condition_filter_pk
    WHERE cm.state_fk = v_state_pk
    AND cm.status = 'active'
    AND cf.status = 'active'
    AND cm.order_test_code IS NOT NULL
    AND LENGTH(TRIM(cm.order_test_code)) > 0;
    
    DBMS_OUTPUT.PUT_LINE('Found ' || v_test_code_count || ' test codes for state ' || p_state_abbrev);
    
    -- If no valid test codes found, return empty result
    IF v_test_code_count = 0 THEN
        DBMS_OUTPUT.PUT_LINE('WARNING: No active test codes found for state ' || p_state_abbrev);
        RETURN 'SELECT gtt.*, 0 as condition_master_pk FROM GTT_RESULTS_EXTRACT gtt WHERE 1=0';
    END IF;
    
    -- Build conditions directly using cursor (no string parsing needed)
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
        WHERE cm.state_fk = v_state_pk
        AND cm.status = 'active'
        AND cf.status = 'active'
        AND cm.order_test_code IS NOT NULL
        AND LENGTH(TRIM(cm.order_test_code)) > 0
        ORDER BY cm.condition_master_pk
    ) LOOP
        v_condition_count := v_condition_count + 1;
        
        v_condition_sql := build_condition_filter_sql(
            rec.condition_master_pk,
            rec.order_test_code,
            rec.result_test_code,
            rec.filter,
            rec.condition_value,
            rec.value_type
        );
        
        IF v_condition_count = 1 THEN
            v_final_sql := v_condition_sql;
        ELSE
            v_final_sql := v_final_sql || ' UNION ALL ' || v_condition_sql || chr(10);
        END IF;
    END LOOP;
    
    DBMS_OUTPUT.PUT_LINE('Built ' || v_condition_count || ' conditions for state ' || p_state_abbrev);
    
    IF v_condition_count > 0 THEN
        -- Return SQL with integrated 310 validation logic
        RETURN 'SELECT * FROM (' || v_final_sql || ') base ' ||
               'WHERE patient_account_state = ''' || p_state_abbrev || '''' ||
               ' AND TRUNC(release_date_time) = DATE ''' || TO_CHAR(p_process_date, 'YYYY-MM-DD') || '''' ||
               -- *** 310 VALIDATION FIX: Check original GTT data for both 310 and 310A ***
               ' AND (base.order_test_code != ''310'' OR ' ||
               '(SELECT COUNT(DISTINCT result_test_code) ' ||
               'FROM GTT_RESULTS_EXTRACT orig_gtt ' ||
               'WHERE orig_gtt.accession_number = base.accession_number ' ||
               'AND orig_gtt.order_test_code = ''310'' ' ||
               'AND orig_gtt.result_test_code IN (''310'', ''310A'') ' ||
               'AND orig_gtt.patient_account_state = ''' || p_state_abbrev || ''' ' ||
               'AND TRUNC(orig_gtt.release_date_time) = DATE ''' || TO_CHAR(p_process_date, 'YYYY-MM-DD') || ''') = 2)';
    ELSE
        RETURN 'SELECT gtt.*, 0 as condition_master_pk FROM GTT_RESULTS_EXTRACT gtt WHERE 1=0';
    END IF;
    
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error in get_base_condition_sql: ' || SQLERRM);
        RAISE;
END get_base_condition_sql;
/

declare v_final_sql CLOB := '';

begin
    v_final_sql := condition_processor.get_base_condition_sql('TX',trunc(sysdate -1));
    
    dbms_output.put_line(v_final_sql);
end;

/

/

SELECT order_number,
    TO_CHAR(release_date_time, 'DD-MON-YYYY HH24:MI:SS') rel_date,
    order_test_code,
    result_test_code,
    numeric_result,
    textual_result,
    value_type,
    order_method,
    TO_CHAR(specimen_receive_date, 'yyyyMMddHHmiZ') rcv_date,
    TO_CHAR(collection_date_time, 'DD-MON-YYYY HH24:MI:SS') coll_date,
    collection_time
    
FROM (SELECT gtt.* FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT gtt WHERE 1=1 AND gtt.order_test_code = '301' AND gtt.result_test_code = '301' AND ((upper(result_comments) LIKE upper('%Newly confirmed Positive%') or upper(result_comments) LIKE upper('%New positive%'))) UNION ALL SELECT gtt.* FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT gtt WHERE 1=1 AND gtt.order_test_code = '310' AND gtt.result_test_code = '310' AND ((upper(textual_result_full) LIKE upper('Positive%') or upper(textual_result_full) LIKE upper('Equivocal%') or upper(textual_result_full) LIKE upper('Reactive%')))
 UNION ALL SELECT gtt.* FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT gtt WHERE 1=1 AND gtt.order_test_code = '312' AND gtt.result_test_code = '312' AND ((upper(textual_result_full) LIKE upper('Positive%') or upper(textual_result_full) LIKE upper('Equivocal%') or upper(textual_result_full) LIKE upper('Reactive%')))
 UNION ALL SELECT gtt.* FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT gtt WHERE 1=1 AND gtt.order_test_code = '319N' AND gtt.result_test_code = '319N' AND ((upper(textual_result_full) LIKE upper('Positive%') or upper(textual_result_full) LIKE upper('Equivocal%') or upper(textual_result_full) LIKE upper('Reactive%')))
 UNION ALL SELECT gtt.* FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT gtt WHERE 1=1 AND gtt.order_test_code = '9239' AND gtt.result_test_code = 'A409' AND ((upper(textual_result_full) LIKE upper('Positive%') or upper(textual_result_full) LIKE upper('Equivocal%') or upper(textual_result_full) LIKE upper('Reactive%')))
 UNION ALL SELECT gtt.* FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT gtt WHERE 1=1 AND gtt.order_test_code = '303' AND gtt.result_test_code = '303' AND ((upper(textual_result_full) LIKE upper('Positive%') or upper(textual_result_full) LIKE upper('Equivocal%') or upper(textual_result_full) LIKE upper('Reactive%')))
 UNION ALL SELECT gtt.* FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT gtt WHERE 1=1 AND gtt.order_test_code = '308' AND gtt.result_test_code = '308' AND ((upper(textual_result_full) LIKE upper('Positive%') or upper(textual_result_full) LIKE upper('Equivocal%') or upper(textual_result_full) LIKE upper('Reactive%')))
 UNION ALL SELECT gtt.* FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT gtt WHERE 1=1 AND gtt.order_test_code = '319C' AND gtt.result_test_code = '319T' AND ((upper(textual_result_full) LIKE upper('Positive%') or upper(textual_result_full) LIKE upper('Equivocal%') or upper(textual_result_full) LIKE upper('Reactive%')))
 UNION ALL SELECT gtt.* FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT gtt WHERE 1=1 AND gtt.order_test_code = '304' AND gtt.result_test_code = '304' AND ((upper(textual_result_full) LIKE upper('Positive%') or upper(textual_result_full) LIKE upper('Equivocal%') or upper(textual_result_full) LIKE upper('Reactive%')))
 UNION ALL SELECT gtt.* FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT gtt WHERE 1=1 AND gtt.order_test_code = '310' AND gtt.result_test_code = '310A' AND ((gtt.value_type = 'ST' and gtt.textual_result_full like '%>11.00%'))
 UNION ALL SELECT gtt.* FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT gtt WHERE 1=1 AND gtt.order_test_code = '332' AND gtt.result_test_code = '332' AND ((upper(textual_result_full) LIKE upper('Positive%') or upper(textual_result_full) LIKE upper('Equivocal%') or upper(textual_result_full) LIKE upper('Reactive%')))
 UNION ALL SELECT gtt.* FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT gtt WHERE 1=1 AND gtt.order_test_code = '336' AND gtt.result_test_code = '336' AND ((upper(textual_result_full) LIKE upper('Positive%') or upper(textual_result_full) LIKE upper('Equivocal%') or upper(textual_result_full) LIKE upper('Reactive%')))
 UNION ALL SELECT gtt.* FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT gtt WHERE 1=1 AND gtt.order_test_code = '311' AND ((upper(textual_result_full) LIKE upper('%')))
 UNION ALL SELECT gtt.* FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT gtt WHERE 1=1 AND gtt.order_test_code = '318' AND gtt.result_test_code = '318L' AND ((upper(textual_result_full) LIKE upper('%')))
 UNION ALL SELECT gtt.* FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT gtt WHERE 1=1 AND gtt.order_test_code = '318' AND gtt.result_test_code = '318R' AND ((upper(textual_result_full) LIKE upper('%')))
 UNION ALL SELECT gtt.* FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT gtt WHERE 1=1 AND gtt.order_test_code = '310' AND gtt.result_test_code = '310A' AND ((gtt.value_type = 'NM' and gtt.numeric_result > 0.00))
) base WHERE patient_account_state = 'NY' AND TRUNC(release_date_time) = DATE '2025-08-29' AND (base.order_test_code != '310' OR (SELECT COUNT(DISTINCT result_test_code) FROM GTT_RESULTS_EXTRACT orig_gtt WHERE orig_gtt.order_number = base.order_number AND orig_gtt.order_test_code = '310' AND orig_gtt.result_test_code IN ('310', '310A') AND orig_gtt.patient_account_state = 'TX' AND TRUNC(orig_gtt.release_date_time) = DATE '2025-09-02') = 2) AND result_status = 'F'

/
SELECT  * FROM (SELECT gtt.* FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT gtt WHERE 1=1 AND gtt.order_test_code = '301' AND gtt.result_test_code = '301' AND ((upper(result_comments) LIKE upper('%Newly confirmed Positive%') or upper(result_comments) LIKE upper('%New positive%'))) UNION ALL SELECT gtt.* FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT gtt WHERE 1=1 AND gtt.order_test_code = '318' AND ((upper(textual_result_full) LIKE upper('%')))
 UNION ALL SELECT gtt.* FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT gtt WHERE 1=1 AND gtt.order_test_code = '310' AND gtt.result_test_code = '310' AND ((upper(textual_result_full) LIKE upper('Positive%') or upper(textual_result_full) LIKE upper('Equivocal%') or upper(textual_result_full) LIKE upper('Reactive%')))
 UNION ALL SELECT gtt.* FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT gtt WHERE 1=1 AND gtt.order_test_code = '311' AND ((upper(textual_result_full) LIKE upper('%')))
 UNION ALL SELECT gtt.* FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT gtt WHERE 1=1 AND gtt.order_test_code = '312' AND gtt.result_test_code = '312' AND ((upper(textual_result_full) LIKE upper('Positive%') or upper(textual_result_full) LIKE upper('Equivocal%') or upper(textual_result_full) LIKE upper('Reactive%')))
 UNION ALL SELECT gtt.* FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT gtt WHERE 1=1 AND gtt.order_test_code = '319N' AND gtt.result_test_code = '319N' AND ((upper(textual_result_full) LIKE upper('Positive%') or upper(textual_result_full) LIKE upper('Equivocal%') or upper(textual_result_full) LIKE upper('Reactive%')))
 UNION ALL SELECT gtt.* FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT gtt WHERE 1=1 AND gtt.order_test_code = '9239' AND gtt.result_test_code = 'A409' AND ((upper(textual_result_full) LIKE upper('Positive%') or upper(textual_result_full) LIKE upper('Equivocal%') or upper(textual_result_full) LIKE upper('Reactive%')))
 UNION ALL SELECT gtt.* FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT gtt WHERE 1=1 AND gtt.order_test_code = '303' AND gtt.result_test_code = '303' AND ((upper(textual_result_full) LIKE upper('Positive%') or upper(textual_result_full) LIKE upper('Equivocal%') or upper(textual_result_full) LIKE upper('Reactive%')))
 UNION ALL SELECT gtt.* FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT gtt WHERE 1=1 AND gtt.order_test_code = '308' AND gtt.result_test_code = '308' AND ((upper(textual_result_full) LIKE upper('Positive%') or upper(textual_result_full) LIKE upper('Equivocal%') or upper(textual_result_full) LIKE upper('Reactive%')))
 UNION ALL SELECT gtt.* FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT gtt WHERE 1=1 AND gtt.order_test_code = '319C' AND gtt.result_test_code = '319T' AND ((upper(textual_result_full) LIKE upper('Positive%') or upper(textual_result_full) LIKE upper('Equivocal%') or upper(textual_result_full) LIKE upper('Reactive%')))
 UNION ALL SELECT gtt.* FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT gtt WHERE 1=1 AND gtt.order_test_code = '304' AND gtt.result_test_code = '304' AND ((upper(textual_result_full) LIKE upper('Positive%') or upper(textual_result_full) LIKE upper('Equivocal%') or upper(textual_result_full) LIKE upper('Reactive%')))
 UNION ALL SELECT gtt.* FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT gtt WHERE 1=1 AND gtt.order_test_code = '310' AND gtt.result_test_code = '310A' AND ((gtt.value_type = 'ST' and gtt.textual_result_full like '%>11.00%'))
 UNION ALL SELECT gtt.* FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT gtt WHERE 1=1 AND gtt.order_test_code = '332' AND gtt.result_test_code = '332' AND ((upper(textual_result_full) LIKE upper('Positive%') or upper(textual_result_full) LIKE upper('Negative%')))
 UNION ALL SELECT gtt.* FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT gtt WHERE 1=1 AND gtt.order_test_code = '336' AND gtt.result_test_code = '336' AND ((upper(textual_result_full) LIKE upper('Positive%') or upper(textual_result_full) LIKE upper('Equivocal%') or upper(textual_result_full) LIKE upper('Reactive%')))
) base 
WHERE (base.order_test_code != '310' OR 
             (SELECT COUNT(DISTINCT sub.result_test_code) 
             FROM (SELECT gtt.* FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT gtt WHERE 1=1 AND gtt.order_test_code = '301' AND gtt.result_test_code = '301' AND ((upper(result_comments) LIKE upper('%Newly confirmed Positive%') or upper(result_comments) LIKE upper('%New positive%'))) UNION ALL SELECT gtt.* FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT gtt WHERE 1=1 AND gtt.order_test_code = '318' AND ((upper(textual_result_full) LIKE upper('%')))
 UNION ALL SELECT gtt.* FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT gtt WHERE 1=1 AND gtt.order_test_code = '310' AND gtt.result_test_code = '310' AND ((upper(textual_result_full) LIKE upper('Positive%') or upper(textual_result_full) LIKE upper('Equivocal%') or upper(textual_result_full) LIKE upper('Reactive%')))
 UNION ALL SELECT gtt.* FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT gtt WHERE 1=1 AND gtt.order_test_code = '311' AND ((upper(textual_result_full) LIKE upper('%')))
 UNION ALL SELECT gtt.* FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT gtt WHERE 1=1 AND gtt.order_test_code = '312' AND gtt.result_test_code = '312' AND ((upper(textual_result_full) LIKE upper('Positive%') or upper(textual_result_full) LIKE upper('Equivocal%') or upper(textual_result_full) LIKE upper('Reactive%')))
 UNION ALL SELECT gtt.* FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT gtt WHERE 1=1 AND gtt.order_test_code = '319N' AND gtt.result_test_code = '319N' AND ((upper(textual_result_full) LIKE upper('Positive%') or upper(textual_result_full) LIKE upper('Equivocal%') or upper(textual_result_full) LIKE upper('Reactive%')))
 UNION ALL SELECT gtt.* FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT gtt WHERE 1=1 AND gtt.order_test_code = '9239' AND gtt.result_test_code = 'A409' AND ((upper(textual_result_full) LIKE upper('Positive%') or upper(textual_result_full) LIKE upper('Equivocal%') or upper(textual_result_full) LIKE upper('Reactive%')))
 UNION ALL SELECT gtt.* FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT gtt WHERE 1=1 AND gtt.order_test_code = '303' AND gtt.result_test_code = '303' AND ((upper(textual_result_full) LIKE upper('Positive%') or upper(textual_result_full) LIKE upper('Equivocal%') or upper(textual_result_full) LIKE upper('Reactive%')))
 UNION ALL SELECT gtt.* FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT gtt WHERE 1=1 AND gtt.order_test_code = '308' AND gtt.result_test_code = '308' AND ((upper(textual_result_full) LIKE upper('Positive%') or upper(textual_result_full) LIKE upper('Equivocal%') or upper(textual_result_full) LIKE upper('Reactive%')))
 UNION ALL SELECT gtt.* FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT gtt WHERE 1=1 AND gtt.order_test_code = '319C' AND gtt.result_test_code = '319T' AND ((upper(textual_result_full) LIKE upper('Positive%') or upper(textual_result_full) LIKE upper('Equivocal%') or upper(textual_result_full) LIKE upper('Reactive%')))
 UNION ALL SELECT gtt.* FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT gtt WHERE 1=1 AND gtt.order_test_code = '304' AND gtt.result_test_code = '304' AND ((upper(textual_result_full) LIKE upper('Positive%') or upper(textual_result_full) LIKE upper('Equivocal%') or upper(textual_result_full) LIKE upper('Reactive%')))
 UNION ALL SELECT gtt.* FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT gtt WHERE 1=1 AND gtt.order_test_code = '310' AND gtt.result_test_code = '310A' AND ((gtt.value_type = 'ST' and gtt.textual_result_full like '%>11.00%'))
 UNION ALL SELECT gtt.* FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT gtt WHERE 1=1 AND gtt.order_test_code = '332' AND gtt.result_test_code = '332' AND ((upper(textual_result_full) LIKE upper('Positive%') or upper(textual_result_full) LIKE upper('Negative%')))
 UNION ALL SELECT gtt.* FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT gtt WHERE 1=1 AND gtt.order_test_code = '336' AND gtt.result_test_code = '336' AND ((upper(textual_result_full) LIKE upper('Positive%') or upper(textual_result_full) LIKE upper('Equivocal%') or upper(textual_result_full) LIKE upper('Reactive%')))
) sub 
             WHERE sub.order_number = base.order_number 
             AND sub.order_test_code = ''310'' '
             AND sub.result_test_code IN (''310'', ''310A'')) = 2)';and order_number = '7039Y88';
             
             SELECT 'WHERE patient_account_state = ''' || 'AZ' || '''' ||
       ' AND TRUNC(release_date_time) = DATE ''' || TO_CHAR(SYSDATE, 'YYYY-MM-DD') || '''' 
FROM dual;

/

FUNCTION get_base_condition_sql(
    p_state_abbrev VARCHAR2,
    p_process_date DATE
) RETURN CLOB IS
    v_final_sql CLOB := '';
    v_condition_sql VARCHAR2(4000);
    v_condition_count NUMBER := 0;
    v_state_pk NUMBER;
    v_test_code_count NUMBER := 0;
    
BEGIN
    -- Get state primary key
    BEGIN
        SELECT state_master_pk 
        INTO v_state_pk
        FROM state_master 
        WHERE state_abbreviation = p_state_abbrev;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('WARNING: State ' || p_state_abbrev || ' not found in state_master');
            RETURN 'SELECT gtt.*, 0 as condition_master_pk FROM GTT_RESULTS_EXTRACT gtt WHERE 1=0';
    END;
    
    -- Count valid test codes for logging
    SELECT COUNT(DISTINCT cm.order_test_code)
    INTO v_test_code_count
    FROM CONDITION_MASTER cm
    JOIN CONDITION_FILTERS cf ON cm.condition_filter_fk = cf.condition_filter_pk
    WHERE cm.state_fk = v_state_pk
    AND cm.status = 'active'
    AND cf.status = 'active'
    AND cm.order_test_code IS NOT NULL
    AND LENGTH(TRIM(cm.order_test_code)) > 0;
    
    DBMS_OUTPUT.PUT_LINE('Found ' || v_test_code_count || ' test codes for state ' || p_state_abbrev);
    
    -- If no valid test codes found, return empty result
    IF v_test_code_count = 0 THEN
        DBMS_OUTPUT.PUT_LINE('WARNING: No active test codes found for state ' || p_state_abbrev);
        RETURN 'SELECT gtt.*, 0 as condition_master_pk FROM GTT_RESULTS_EXTRACT gtt WHERE 1=0';
    END IF;
    
    -- Build conditions directly using cursor (no string parsing needed)
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
        WHERE cm.state_fk = v_state_pk
        AND cm.status = 'active'
        AND cf.status = 'active'
        AND cm.order_test_code IS NOT NULL
        AND LENGTH(TRIM(cm.order_test_code)) > 0
        ORDER BY cm.condition_master_pk
    ) LOOP
        v_condition_count := v_condition_count + 1;
        
        v_condition_sql := build_condition_filter_sql(
            rec.condition_master_pk,
            rec.order_test_code,
            rec.result_test_code,
            rec.filter,
            rec.condition_value,
            rec.value_type
        );
        
        IF v_condition_count = 1 THEN
            v_final_sql := v_condition_sql;
        ELSE
            v_final_sql := v_final_sql || ' UNION ALL ' || v_condition_sql;
        END IF;
    END LOOP;
    
    DBMS_OUTPUT.PUT_LINE('Built ' || v_condition_count || ' conditions for state ' || p_state_abbrev);
    
    IF v_condition_count > 0 THEN
        RETURN 'SELECT * FROM (' || v_final_sql || ') ' ||
               'WHERE patient_account_state = ''' || p_state_abbrev || '''' ||
               ' AND TRUNC(release_date_time) = DATE ''' || TO_CHAR(p_process_date, 'YYYY-MM-DD') || '''';
    ELSE
        RETURN 'SELECT gtt.*, 0 as condition_master_pk FROM GTT_RESULTS_EXTRACT gtt WHERE 1=0';
    END IF;
    
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error in get_base_condition_sql: ' || SQLERRM);
        RAISE;
END get_base_condition_sql;