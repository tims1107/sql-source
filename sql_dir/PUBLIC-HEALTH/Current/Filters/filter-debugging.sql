-- Add this debug version to your main script
DECLARE
    v_asr_data asr_filter_table;
    v_total_301_updated NUMBER := 0;
    v_total_310_updated NUMBER := 0;
    v_rows_updated NUMBER;
    v_should_filter_old BOOLEAN := FALSE;
    v_should_filter_new BOOLEAN := FALSE;
    
BEGIN
    -- Your data collection query (same as before)
    SELECT asr_filter_obj(
        asr.order_number, asr.result_test_code, asr.order_test_code,
        asr.textual_result_full, asr.source, asr.complete,
        s.state_abbreviation, r.result_comment
    )
    BULK COLLECT INTO v_asr_data
    FROM asr_process_run asr
    JOIN state_master s ON s.state_abbreviation = asr.source
    JOIN ih_dw.results r ON r.requisition_id = asr.order_number 
                        AND r.result_test_code = asr.result_test_code
    WHERE asr.complete = 'L'
      AND REGEXP_LIKE(s.state_abbreviation, '^([A-Z]{2})$')
      AND s.entity_type = 'Abnormal'
      AND s.status = 'active'
      AND asr.order_test_code IN ('301','310');

    DBMS_OUTPUT.PUT_LINE('Processing ' || v_asr_data.COUNT || ' records...');

    FOR i IN 1..v_asr_data.COUNT LOOP

        IF v_asr_data(i).order_test_code = '301' THEN
            
            -- Test both functions and show results
            v_should_filter_old := should_filter_301(
                v_asr_data(i).order_number,
                v_asr_data(i).result_test_code,
                v_asr_data(i).textual_result_full,
                v_asr_data(i).source,
                v_asr_data(i).result_comment
            );
            
            v_should_filter_new := should_filter_301_new(
                v_asr_data(i).order_number,
                v_asr_data(i).result_test_code,
                v_asr_data(i).textual_result_full,
                v_asr_data(i).source,
                v_asr_data(i).result_comment
            );
            
            -- Debug output for specific records
            IF v_asr_data(i).order_number IN ('6146328', '6128758', '6178M8') THEN
                DBMS_OUTPUT.PUT_LINE('=== DEBUG ORDER: ' || v_asr_data(i).order_number || ' ===');
                DBMS_OUTPUT.PUT_LINE('Textual Result: ' || v_asr_data(i).textual_result_full);
                DBMS_OUTPUT.PUT_LINE('Source: ' || v_asr_data(i).source);
                DBMS_OUTPUT.PUT_LINE('Comment: ' || NVL(v_asr_data(i).result_comment, 'NULL'));
                DBMS_OUTPUT.PUT_LINE('Old Function: ' || CASE WHEN v_should_filter_old THEN 'TRUE' ELSE 'FALSE' END);
                DBMS_OUTPUT.PUT_LINE('New Function: ' || CASE WHEN v_should_filter_new THEN 'TRUE' ELSE 'FALSE' END);
            END IF;
            
            -- Apply filtering
            IF v_should_filter_old OR v_should_filter_new THEN
                DBMS_OUTPUT.PUT_LINE('FILTERING: ' || v_asr_data(i).order_number);
                v_rows_updated := update_asr_record(
                    v_asr_data(i).order_number,
                    p_result_test_code => v_asr_data(i).result_test_code
                );
                v_total_301_updated := v_total_301_updated + v_rows_updated;
            END IF;

        -- Handle 310 filtering (same as before)
        ELSIF v_asr_data(i).order_test_code = '310' THEN
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

-- Test the functions directly
DECLARE
    v_result_old BOOLEAN;
    v_result_new BOOLEAN;
BEGIN
    -- Test with a sample record (adjust values based on what you see above)
    v_result_old := should_filter_301('SAMPLE_ORDER', '301', 'Positive', 'AL', 'Newly confirmed');
    v_result_new := should_filter_301_new('SAMPLE_ORDER', '301', 'Positive', 'AL', NULL);
    
    DBMS_OUTPUT.PUT_LINE('Old function result: ' || CASE WHEN v_result_old THEN 'TRUE' ELSE 'FALSE' END);
    DBMS_OUTPUT.PUT_LINE('New function result: ' || CASE WHEN v_result_new THEN 'TRUE' ELSE 'FALSE' END);
END;
/
-- Check if AL state exists
SELECT state_master_pk, state_abbreviation, entity_type, status
FROM state_master 
WHERE state_abbreviation = 'AL';

/

-- Debug version of should_filter_301_new
CREATE OR REPLACE FUNCTION should_filter_301_new_debug(
    p_order_number VARCHAR2,
    p_result_test_code VARCHAR2,
    p_textual_result VARCHAR2,
    p_source VARCHAR2,
    p_result_comment VARCHAR2 DEFAULT NULL
) RETURN BOOLEAN
IS
    v_state_master_pk NUMBER;
    v_state_count NUMBER;
    v_text_check BOOLEAN;
    v_comment_check BOOLEAN;
    v_source_check BOOLEAN;
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== DEBUG NEW FUNCTION ===');
    DBMS_OUTPUT.PUT_LINE('Input - Source: ' || p_source);
    DBMS_OUTPUT.PUT_LINE('Input - Result: ' || p_textual_result);
    DBMS_OUTPUT.PUT_LINE('Input - Comment: ' || NVL(p_result_comment, 'NULL'));
    
    -- Check if state exists
    SELECT COUNT(1) INTO v_state_count
    FROM state_master
    WHERE state_abbreviation = p_source
      AND REGEXP_LIKE(state_abbreviation, '^([A-Z]{2})$')
      AND entity_type = 'Abnormal'
      AND status = 'active';
    
    DBMS_OUTPUT.PUT_LINE('State count found: ' || v_state_count);
    
    IF v_state_count = 0 THEN
        DBMS_OUTPUT.PUT_LINE('No state found - returning FALSE');
        RETURN FALSE;
    END IF;
    
    -- Get state_master_pk
    BEGIN
        SELECT state_master_pk INTO v_state_master_pk
        FROM state_master
        WHERE state_abbreviation = p_source
          AND REGEXP_LIKE(state_abbreviation, '^([A-Z]{2})$')
          AND entity_type = 'Abnormal'
          AND status = 'active'
          AND ROWNUM = 1;
        DBMS_OUTPUT.PUT_LINE('State master PK: ' || v_state_master_pk);
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('No state master found - returning FALSE');
            RETURN FALSE;
    END;
    
    -- Check individual conditions
    v_text_check := REGEXP_LIKE(p_textual_result, 'Positive|Equivocal', 'i');
    
    v_comment_check := (p_result_comment IS NULL OR NOT REGEXP_LIKE(p_result_comment, 'Newly Confirmed', 'i'));
    v_source_check := p_source NOT IN ('IL');
    
    DBMS_OUTPUT.PUT_LINE('Text check (Positive|Equivocal): ' || CASE WHEN v_text_check THEN 'TRUE' ELSE 'FALSE' END);
    DBMS_OUTPUT.PUT_LINE('Comment check (NOT Newly Confirmed): ' || CASE WHEN v_comment_check THEN 'TRUE' ELSE 'FALSE' END);
    DBMS_OUTPUT.PUT_LINE('Source check (NOT IL): ' || CASE WHEN v_source_check THEN 'TRUE' ELSE 'FALSE' END);
    
    DBMS_OUTPUT.PUT_LINE('Final result: ' || CASE WHEN (v_text_check AND v_comment_check AND v_source_check) THEN 'TRUE' ELSE 'FALSE' END);
    
    RETURN (v_text_check AND v_comment_check AND v_source_check);
END should_filter_301_new_debug;
/
DECLARE
    v_result BOOLEAN;
BEGIN
    v_result := should_filter_301_new_debug('SAMPLE_ORDER', '301', 'Positive', 'AL','Newly confirmed');
END;
/