-- 310 filtering function (no condition table needed for this one)
CREATE OR REPLACE FUNCTION should_filter_310(
    p_order_number VARCHAR2,
    p_result_test_code VARCHAR2,
    p_textual_result VARCHAR2,
    p_source VARCHAR2,
    p_result_comment VARCHAR2 DEFAULT NULL
) RETURN BOOLEAN
IS
    v_state_exists NUMBER;
BEGIN
    -- Verify state is valid
    SELECT COUNT(1) INTO v_state_exists
    FROM state_master
    WHERE state_abbreviation = p_source
      AND REGEXP_LIKE(state_abbreviation, '^([A-Z]{2})$')
      AND entity_type = 'Abnormal'
      AND status = 'active';
    
    IF v_state_exists = 0 THEN
        RETURN FALSE;
    END IF;
    
    -- Apply filtering logic
    RETURN (
        REGEXP_LIKE(p_result_test_code, '^(310)$', 'i')
        AND REGEXP_LIKE(p_textual_result, 'Nonreactive', 'i')
    );
END should_filter_310;
/

-- 310A filtering function (no condition table needed for this one)
CREATE OR REPLACE FUNCTION should_filter_310A(
    p_order_number VARCHAR2,
    p_result_test_code VARCHAR2,
    p_textual_result VARCHAR2,
    p_source VARCHAR2,
    p_result_comment VARCHAR2 DEFAULT NULL
) RETURN BOOLEAN
IS
    v_state_exists NUMBER;
    v_text_result NUMBER;
BEGIN
    -- Verify state is valid
    SELECT COUNT(1) INTO v_state_exists
    FROM state_master
    WHERE state_abbreviation = p_source
      AND REGEXP_LIKE(state_abbreviation, '^([A-Z]{2})$')
      AND entity_type = 'Abnormal'
      AND status = 'active';
    
    IF v_state_exists = 0 THEN
        RETURN FALSE;
    END IF;
    
     -- Verify 310A qualify
    SELECT COUNT(1) INTO v_text_result
    FROM asr_process_run
    WHERE order_number = p_order_number
      AND result_test_code = '310A'
      AND NOT REGEXP_LIKE(textual_result_full, '^(>11.00)$')
      AND NOT regexp_like(p_source,'^(AL|AK|AR|GA|MI|MP|NY|NC|OK|OR|SC|TX|WA|PR|GU|VI)$');
      
    IF v_text_result = 0 THEN
        RETURN FALSE;
    END IF;
    
    
    -- Apply filtering logic
    RETURN (
        REGEXP_LIKE(p_result_test_code, '^(310)$', 'i')
        AND REGEXP_LIKE(p_textual_result, 'Reactive|Equivocal', 'i')
        
    );
END should_filter_310A;
/