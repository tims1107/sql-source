
-- average
select from_date,average_hour_diff,count(1) from
(select '01-JAN-25 01.01.01.000000000 AM' from_date,average_hour_diff from
(SELECT 
    last_update_time,
    order_number,
    result_source,
    result_test_code,
    TO_CHAR(release_date_time, 'DD-MON-YY HH24:MI') AS release_date_time,
    hour_diff,
    ROUND(AVG(hour_diff) OVER (), 2) AS average_hour_diff
FROM 
    (SELECT 
        last_update_time,
        order_number,
        result_source,
        result_test_code,
        release_date_time,
        ROUND((CAST(last_update_time AS DATE) - CAST(release_date_time AS DATE)) * 24, 2) AS hour_diff
    FROM 
        results_sent_log
    WHERE 
        
        last_update_time > '01-JAN-25 01.01.12.185418000 AM'
        --and not regexp_like(result_source,'EIP')
        AND regexp_like(patient_account_state,'^(AL|CA|IL|LA|MD|NC|NJ|NM|OR|TX|PA)$')
        --and regexp_like(result_test_code,'^(332)$'))
        AND NOT regexp_like(result_test_code,'^7'))
WHERE 
    hour_diff < 48))
group by from_date,average_hour_diff;
ORDER BY 
    hour_diff DESC, last_update_time;