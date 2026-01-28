-- measles by state filtering function
CREATE OR REPLACE FUNCTION filter_measles_by_state(
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
         NOT REGEXP_LIKE(p_textual_result, '^(AL|AR|GU|ID|IL|IN|ME|MP|OH|PR|UT|VI)$', 'i')
                
    );
END filter_measles_by_state;
/

select * from state_master
where state_abbreviation = 'UT';