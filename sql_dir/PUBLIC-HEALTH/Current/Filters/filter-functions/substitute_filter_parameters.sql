CREATE OR REPLACE FUNCTION substitute_filter_parameters(
    p_filter VARCHAR2,
    p_condition_value VARCHAR2
) RETURN VARCHAR2
IS
    v_result VARCHAR2(4000);
BEGIN
    v_result := p_filter;
    
    -- Replace {0} with condition_value
    v_result := REPLACE(v_result, '{0}', NVL(p_condition_value, ''));
    
    -- Replace table alias 'r.' with 'gtt.'
    v_result := REPLACE(v_result, 'r.', 'gtt.');
    
    -- You could add more parameter substitutions here if needed
    -- v_result := REPLACE(v_result, '{1}', some_other_value);
    
    RETURN v_result;
END substitute_filter_parameters;
/