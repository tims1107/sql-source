-- 110 111 113 filtering function (no condition table needed for this one)
CREATE OR REPLACE FUNCTION should_filter_111_110_113(
    p_order_number VARCHAR2,
    p_result_test_code VARCHAR2,
    p_textual_result VARCHAR2,
    p_source VARCHAR2,
    p_result_comment VARCHAR2 DEFAULT NULL
) RETURN BOOLEAN
IS
    v_state_exists NUMBER;
    v_primary_exists NUMBER;
BEGIN
    -- Verify state is valid
    SELECT COUNT(1) INTO v_state_exists
    FROM state_master
    WHERE state_abbreviation = p_source
      AND REGEXP_LIKE(state_abbreviation, '^([A-Z]{2})$')
      AND entity_type = 'Abnormal'
      AND status = 'active'
      and regexp_like(p_source,'^(NY|IL)$');
    
    IF v_state_exists = 0 THEN
        RETURN FALSE;
    END IF;
    
    -- Verify primary general
    SELECT COUNT(1) INTO v_primary_exists
    FROM asr_process_run_20250814_LF
    WHERE complete = 'L'
      AND order_test_code IN ('301','303','308','310','312','311','318')
      AND order_number = p_order_number
      AND NOT regexp_like(textual_result_full,'Negative','i');
    
    IF v_primary_exists = 1 THEN
        RETURN FALSE;
    END IF;
    
    -- Apply filtering logic
    RETURN (
        
        TRUE
        
    );
END should_filter_111_110_113;
/