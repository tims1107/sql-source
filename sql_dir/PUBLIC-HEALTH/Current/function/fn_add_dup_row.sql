create or replace function fn_add_dup_row(
  input_cursor IN SYS_REFCURSOR,
  p_resultcode IN varchar2
) RETURN SYS_REFCURSOR AS 
  TYPE t_result_tab IS TABLE OF GTT_RESULTS_EXTRACT%ROWTYPE;
  v_results t_result_tab;
  v_match_row GTT_RESULTS_EXTRACT%ROWTYPE;
  output_cursor SYS_REFCURSOR;
  v_found boolean := false;
  v_text_part varchar2(64);
  v_numeric_part varchar2(32);

BEGIN
  -- Bulk collect all rows from the cursor into a PL/SQL collection
  FETCH input_cursor BULK COLLECT INTO v_results;

  -- Close the input cursor immediately after reading
  --CLOSE input_cursor;

  -- Clear the GTT table
  --EXECUTE IMMEDIATE 'TRUNCATE TABLE gtt_results_extract';

  -- Process the collection and find the matching row
  FOR i IN 1..v_results.COUNT LOOP
    -- Check if this is the row we want to duplicate

    -- Insert the original row
      --INSERT INTO gtt_results_extract VALUES v_results(i);
    IF v_results(i).result_test_code = p_resultcode THEN

     v_match_row := v_results(i);

     -- Delete and update original
     delete gtt_results_extract
     where result_test_code = v_match_row.result_test_code 
     and order_number = v_results(i).order_number;

     -- Insert the original row
     v_match_row.textual_result_full := 'Reactive';
      v_match_row.textual_result := 'Reactive';
      INSERT INTO gtt_results_extract VALUES v_match_row;

      -- Create a copy of the row for modification




      -- Modify the duplicate row as needed
      v_match_row.loinc_code := '31147-2';
      v_match_row.loinc_name := 'Reagin Ab:Titr:Pt:Ser:SemiQn:RPR';
      v_match_row.reference_range := null;
      v_match_row.units := 'titer';

      v_text_part := REGEXP_SUBSTR(v_results(i).textual_result_full, '([[:alpha:]]+)', 1, 1, NULL, 1);
      v_numeric_part := REGEXP_SUBSTR(v_results(i).textual_result_full, '[[:alpha:]]+[[:space:]]+([[:digit:]:]+)', 1, 1, NULL, 1);

      v_match_row.textual_result_full := v_numeric_part;
      v_match_row.textual_result := v_numeric_part;



      -- You can modify any other columns as needed
      -- v_match_row.some_column := new_value;

       --Insert the modified duplicate row
      INSERT INTO gtt_results_extract VALUES v_match_row;

      v_found := true;
      dbms_output.put_line('Found and duplicated row with result_test_code: ' || v_results(i).result_test_code);
    ELSE
      -- Insert non-matching rows as they are
      --INSERT INTO gtt_results_extract VALUES v_results(i);
      dbms_output.put_line('Not inserted: ' || v_results(i).result_test_code);
    END IF;
  END LOOP;

  IF NOT v_found THEN
    dbms_output.put_line('No matching row found for result_test_code: ' || p_resultcode);
  END IF;

  -- Return all rows from the GTT table, including the duplicated row
  OPEN output_cursor FOR
    SELECT * FROM gtt_results_extract;

  RETURN output_cursor;
END;