-- Script to check if state_copy_config table exists and has data
SET SERVEROUTPUT ON;

DECLARE
  v_table_exists NUMBER := 0;
  v_row_count NUMBER := 0;
BEGIN
  -- Check if table exists
  SELECT COUNT(*) INTO v_table_exists
  FROM user_tables
  WHERE table_name = 'STATE_COPY_CONFIG';
  
  IF v_table_exists > 0 THEN
    DBMS_OUTPUT.PUT_LINE('Table STATE_COPY_CONFIG exists.');
    
    -- Check if table has data
    EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM state_copy_config' INTO v_row_count;
    
    DBMS_OUTPUT.PUT_LINE('Table STATE_COPY_CONFIG has ' || v_row_count || ' rows.');
    
    -- Show data if any exists
    IF v_row_count > 0 THEN
      DBMS_OUTPUT.PUT_LINE('Data in STATE_COPY_CONFIG:');
      
      FOR rec IN (SELECT state_code, enabled, cron_expression, base_path, file_pattern, destination_path, destination_base_path FROM state_copy_config) LOOP
        DBMS_OUTPUT.PUT_LINE('State: ' || rec.state_code || 
                            ', Enabled: ' || rec.enabled || 
                            ', Cron: ' || rec.cron_expression || 
                            ', Pattern: ' || rec.file_pattern ||
                            ', Base path: ' || rec.base_path ||
                            ', Dest path: ' || rec.destination_path ||
                            ', Dest base path: ' || rec.destination_base_path);
      END LOOP;
    END IF;
  ELSE
    DBMS_OUTPUT.PUT_LINE('Table STATE_COPY_CONFIG does not exist!');
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;
/
