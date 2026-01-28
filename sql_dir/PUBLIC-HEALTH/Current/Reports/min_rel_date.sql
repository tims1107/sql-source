select --regexp_substr(message_content,1,30) message 

* from hl7_message
where creation_date > '23-JUL-25'
and state_code = 'IL'
order by creation_date;



SELECT 
   creation_date,
   extract_from_clob(message_content,88,135) AS extracted_text
FROM 
   hl7_message
where creation_date > '23-JUL-25'
and state_code = 'IL'
order by creation_date;

/
SELECT 
        hl7_message_pk,
        state_code,
        message_type,
        creation_date,
        REGEXP_SUBSTR(message_content, '[^\r\n]+', 1, LEVEL) AS line,
        ROW_NUMBER() OVER (PARTITION BY hl7_message_pk ORDER BY LEVEL) AS line_num
    FROM 
        hl7_message
    CONNECT BY 
        REGEXP_SUBSTR(message_content, '[^\r\n]+', 1, LEVEL) IS NOT NULL
        AND PRIOR SYS_GUID() IS NOT NULL
        AND PRIOR hl7_message_pk = hl7_message_pk;
/

CREATE OR REPLACE FUNCTION extract_from_clob(
    p_clob IN CLOB,
    p_start_pos IN NUMBER,
    p_end_pos IN NUMBER
) RETURN VARCHAR2
IS
    v_result VARCHAR2(32767);
    v_length NUMBER := p_end_pos - p_start_pos + 1;
BEGIN
    -- Use DBMS_LOB.SUBSTR for efficient extraction
    v_result := DBMS_LOB.SUBSTR(p_clob, v_length, p_start_pos);
    RETURN v_result;
EXCEPTION
    WHEN OTHERS THEN
        RETURN NULL;
END;
/

-- Usage:
SELECT 
    extract_from_clob(clob_column, 50, 90) AS extracted_text
FROM 
    your_table;
    
/
select activitydate,source,to_char(min(ts_rel_date),'hh24:mi') min_rel_date,count(1) OBX_COUNT from
(select r.activitydate,source,r.order_number,to_char(rs.release_date_time,'hh24:mi') rel_date,rs.last_update_time,rs.release_date_time ts_rel_date from asr_process_run r
join results_sent_log rs ON rs.order_number = r.order_number
    and rs.result_test_code = r.result_test_code
where activitydate = '30-JUL-25'
and regexp_like(r.source,'^(CA|OR|NJ|NY|LA|MD|NM|AL|TX|IL|PA)$'))
group by activitydate,source
order by source;

select * from npi_registry_lookup
order by createdat desc;

/


/