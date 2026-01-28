CREATE OR REPLACE FUNCTION should_filter_301(
    p_order_number VARCHAR2,
    p_result_test_code VARCHAR2,
    p_textual_result VARCHAR2,
    p_source VARCHAR2,
    p_result_comment VARCHAR2 DEFAULT NULL
) RETURN BOOLEAN
IS
    v_condition_count NUMBER;
    v_state_master_pk NUMBER;
BEGIN
    -- Get state_master_pk for the source
    BEGIN
    
        SELECT state_master_pk INTO v_state_master_pk
        FROM state_master
        WHERE state_abbreviation = p_source
          AND REGEXP_LIKE(state_abbreviation, '^([A-Z]{2})$')
          AND entity_type = 'Abnormal'
          AND status = 'active'
          AND ROWNUM = 1;  -- Safety net in case multiple states match
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN FALSE;
    END;
    
    -- Check if any condition matches "Newly Confirmed" pattern
--    SELECT COUNT(1) INTO v_condition_count
--    FROM condition_master
--    WHERE state_fk = v_state_master_pk
--      AND result_test_code = p_result_test_code
--      AND REGEXP_LIKE(condition, 'Newly Confirmed', 'i');
--    
--    -- If no matching conditions found, don't filter
--    IF v_condition_count = 0 THEN
--        RETURN FALSE;
--    END IF;
    
    -- Apply filtering logic
    RETURN (
        REGEXP_LIKE(p_textual_result, 'Negative', 'i')
        AND p_source NOT IN ('IL')
    );
END should_filter_301;

/

CREATE OR REPLACE FUNCTION should_filter_301_New(
    p_order_number VARCHAR2,
    p_result_test_code VARCHAR2,
    p_textual_result VARCHAR2,
    p_source VARCHAR2,
    p_result_comment VARCHAR2 DEFAULT NULL
) RETURN BOOLEAN
IS
    v_condition_count NUMBER;
    v_state_master_pk NUMBER;
BEGIN
    -- Get state_master_pk for the source
    BEGIN
    
        SELECT state_master_pk INTO v_state_master_pk
        FROM state_master
        WHERE state_abbreviation = p_source
          AND REGEXP_LIKE(state_abbreviation, '^([A-Z]{2})$')
          AND entity_type = 'Abnormal'
          AND status = 'active'
          AND ROWNUM = 1;  -- Safety net in case multiple states match
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN FALSE;
    END;
    
     
    -- Apply filtering logic
    RETURN (
        REGEXP_LIKE(p_textual_result, 'Positive|Equivocal', 'i')
        AND p_source NOT IN ('IL')
        AND (p_result_comment IS NULL OR NOT REGEXP_LIKE(p_result_comment, 'Newly Confirmed', 'i'))
    );
END should_filter_301_New;

/

