SELECT 
    '202507251029' AS result_released,
    '202507260307' AS ensemble_drop,
    
    -- Convert string timestamps to dates
    TO_DATE('202507251029', 'YYYYMMDDHH24MI') AS result_released_date,
    TO_DATE('202507260307', 'YYYYMMDDHH24MI') AS ensemble_drop_date,
    
    -- Calculate hours between timestamps (rounded to 2 decimal places)
    ROUND(
        (TO_DATE('202507260307', 'YYYYMMDDHH24MI') - 
         TO_DATE('202507251029', 'YYYYMMDDHH24MI')) * 24,
        2
    ) AS hours_between,
    
    -- Boolean indicator: 1 if within 24 hours, 0 if not
    CASE 
        WHEN (TO_DATE('202507260307', 'YYYYMMDDHH24MI') - 
              TO_DATE('202507251029', 'YYYYMMDDHH24MI')) * 24 <= 24 
        THEN 1 
        ELSE 0 
    END AS meets_24hour_requirement,
    
    -- Text indicator for readability
    CASE 
        WHEN (TO_DATE('202507260307', 'YYYYMMDDHH24MI') - 
              TO_DATE('202507251029', 'YYYYMMDDHH24MI')) * 24 <= 24 
        THEN 'YES' 
        ELSE 'NO' 
    END AS meets_requirement_text
FROM 
    dual;