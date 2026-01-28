-- 310 filtering function (no condition table needed for this one)
CREATE OR REPLACE FUNCTION should_filter_336(
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
         NOT REGEXP_LIKE(p_textual_result, '^(Reactive)$', 'i')
                
    );
END should_filter_336;
/