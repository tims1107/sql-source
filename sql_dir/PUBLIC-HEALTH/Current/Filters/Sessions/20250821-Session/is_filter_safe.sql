CREATE OR REPLACE FUNCTION is_filter_safe(p_filter VARCHAR2) RETURN BOOLEAN
IS
    v_upper_filter VARCHAR2(4000);
BEGIN
    IF p_filter IS NULL THEN
        RETURN TRUE;
    END IF;
    
    v_upper_filter := UPPER(TRIM(p_filter));
    
    -- Check for dangerous SQL keywords
    IF v_upper_filter LIKE '%DROP%' OR
       v_upper_filter LIKE '%DELETE%' OR
       v_upper_filter LIKE '%INSERT%' OR
       v_upper_filter LIKE '%UPDATE%' OR
       v_upper_filter LIKE '%TRUNCATE%' OR
       v_upper_filter LIKE '%ALTER%' OR
       v_upper_filter LIKE '%CREATE%' OR
       v_upper_filter LIKE '%EXEC%' OR
       v_upper_filter LIKE '%GRANT%' OR
       v_upper_filter LIKE '%REVOKE%' THEN
        RETURN FALSE;
    END IF;
    
    RETURN TRUE;
END is_filter_safe;
/