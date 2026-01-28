-- Create the update function
CREATE OR REPLACE FUNCTION update_asr_record(
    p_order_number VARCHAR2,
    p_result_test_code VARCHAR2 DEFAULT NULL,
    p_order_test_code VARCHAR2 DEFAULT NULL
) RETURN NUMBER
IS
    v_rows_updated NUMBER := 0;
BEGIN
    IF p_result_test_code IS NOT NULL THEN
        UPDATE asr_process_run
        SET complete = 'L'
        WHERE order_number = p_order_number
          AND result_test_code = p_result_test_code;
          dbms_output.put_line('Updated: ' || p_result_test_code);
    ELSIF p_order_test_code IS NOT NULL THEN
        UPDATE asr_process_run
        SET complete = 'L'
        WHERE order_number = p_order_number
          AND order_test_code = p_order_test_code;
    END IF;
    dbms_output.put_line(sql%rowcount);
    COMMIT;
    
    RETURN SQL%ROWCOUNT;
END update_asr_record;