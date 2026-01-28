create or replace procedure sp_filter_states 
(
    p_state_fk IN number

)
as

    v_recordset SYS_REFCURSOR;
    v_sql VARCHAR2(4000);
    v_cursor_id NUMBER;
    v_col_count NUMBER;
    v_desc_tab DBMS_SQL.DESC_TAB;
    v_row_count NUMBER := 0;
    v_value VARCHAR2(4000);
    v_value_count number;
    v_order_number varchar2(10);
    v_order_test_code varchar2(5);
    v_result_test_code varchar2(5);
    v_update_count number := 0;
    
    v_extracted_value VARCHAR2(64);
BEGIN

-- 13	AK	Alaska
-- 22	AL	Alabama
-- 26	AR	Arkansas
-- 24	AS	AmericanSamoa
-- 25	AZ	Arizona
-- 21	CA	California
-- 1	CO	Colorado
-- 29	CT	Connecticut
-- 31	DC	DistrictofColumbia
-- 30	DE	Delaware
-- 33	FL	Florida
-- 32	FM	Federated States of Micronesia
-- 34	GA	Georgia
-- 35	GU	Guam
-- 36	HI	Hawaii
-- 40	IA	Iowa
-- 37	ID	Idaho
-- 14	IL	Illinois
-- 39	IN	Indiana
-- 41	KS	Kansas
-- 42	KY	Kentucky
-- 43	LA	Louisiana
-- 47	MA	Massachusetts
-- 11	MD	Maryland
-- 44	ME	Maine
-- 45	MH	Marshall Islands
-- 2	MI	Michigan
-- 49	MN	Minnesota
-- 51	MO	Missouri
-- 61	MP	Saipan
-- 50	MS	Mississippi
-- 52	MT	Montana
-- 4	NC	North Carolina
-- 60	ND	NorthDakota
-- 53	NE	Nebraska
-- 55	NH	NewHampshire
-- 5	NJ	New Jersey
-- 57	NM	NewMexico
-- 54	NV	Nevada
-- 3	NY	New York
-- 62	OH	Ohio
-- 63	OK	Oklahoma
-- 20	OR	Oregon
-- 66	PA	Pennsylvania
-- 67	PR	PuertoRico
-- 65	PW	Palau
-- 68	RI	RhodeIsland
-- 69	SC	SouthCarolina
-- 70	SD	SouthDakota
-- 71	TN	Tennessee
-- 12	TX	Texas
-- 73	UT	Utah
-- 76	VA	Virginia
-- 75	VI	VirginIslands
-- 74	VT	Vermont
-- 77	WA	Washington
-- 79	WI	Wisconsin
-- 78	WV	WestVirginia
    
    -- Call your procedure
    SP_ASR_RESULTS_BATCH(p_state_fk, v_recordset);
    dbms_output.put_line(p_state_fk);
    
    -- Convert REF CURSOR to DBMS_SQL cursor for dynamic processing
    v_cursor_id := DBMS_SQL.TO_CURSOR_NUMBER(v_recordset);
    
    -- Describe the cursor to get column information
    DBMS_SQL.DESCRIBE_COLUMNS(v_cursor_id, v_col_count, v_desc_tab);
    
    -- Print column headers
--    DBMS_OUTPUT.PUT_LINE('=== RESULTS ===');
--    FOR i IN 1..v_col_count LOOP
--        DBMS_OUTPUT.PUT(RPAD(i || chr(9) || v_desc_tab(i).col_name, 20) || ' | ');
--        DBMS_OUTPUT.PUT_LINE('');
--    END LOOP;
--    DBMS_OUTPUT.PUT_LINE('');
    
    -- Print separator line
--    FOR i IN 1..10 LOOP
--        DBMS_OUTPUT.PUT(RPAD('-', 20, '-') || ' | ');
--    END LOOP;
--    DBMS_OUTPUT.PUT_LINE('');
--    
    -- Define columns for fetching
    FOR i IN 1..v_col_count LOOP
        DBMS_SQL.DEFINE_COLUMN(v_cursor_id, i, v_value, 4000);
    END LOOP;
    
    -- Fetch and display rows
    WHILE DBMS_SQL.FETCH_ROWS(v_cursor_id) > 0 LOOP
        v_row_count := v_row_count + 1;
        
        DBMS_SQL.COLUMN_VALUE(v_cursor_id, 39, v_order_number);
        DBMS_SQL.COLUMN_VALUE(v_cursor_id, 25, v_result_test_code);
        
--        if(v_result_test_code='310A') then
--            dbms_output.put_line(v_value);
--        end if;
        
        v_update_count := update_asr_record(v_order_number,v_result_test_code);
        
        --FOR i IN 1..10 LOOP
--            DBMS_SQL.COLUMN_VALUE(v_cursor_id, 58, v_value);
--            DBMS_OUTPUT.PUT(RPAD(NVL(v_value, 'NULL'), 3) || ' | ');
--            DBMS_SQL.COLUMN_VALUE(v_cursor_id, 63, v_value);
--            DBMS_OUTPUT.PUT(RPAD(NVL(v_value, 'NULL'), 3) || ' | ');
--            DBMS_SQL.COLUMN_VALUE(v_cursor_id, 1, v_value);
--            DBMS_OUTPUT.PUT(RPAD(NVL(v_value, 'NULL'), 10) || ' | ');
--            DBMS_SQL.COLUMN_VALUE(v_cursor_id, 23, v_value);
--            DBMS_OUTPUT.PUT(RPAD(NVL(v_value, 'NULL'), 6) || ' | ');
--            DBMS_SQL.COLUMN_VALUE(v_cursor_id, 25, v_value);
--            DBMS_OUTPUT.PUT(RPAD(NVL(v_value, 'NULL'), 6) || ' | ');
--            DBMS_SQL.COLUMN_VALUE(v_cursor_id, 29, v_value);
--            DBMS_OUTPUT.PUT(RPAD(NVL(v_value, 'NULL'), 30) || ' | ');
--            DBMS_SQL.COLUMN_VALUE(v_cursor_id, 30, v_value);
--            DBMS_OUTPUT.PUT(RPAD(NVL(v_value, 'NULL'), 12) || ' | ');
--            
--            -- result_comments
--            DBMS_SQL.COLUMN_VALUE(v_cursor_id, 35, v_value);
--            v_extracted_value := REGEXP_SUBSTR(v_value, 'Newly confirmed', 1, 1, 'i');
--            DBMS_OUTPUT.PUT(RPAD(NVL(v_extracted_value, 'NULL'), 32) || ' | ');
            
        --END LOOP;
        DBMS_OUTPUT.PUT_LINE('');
        
        -- Limit output to prevent overwhelming the console
        IF v_row_count >= 150 THEN
            DBMS_OUTPUT.PUT_LINE('... (showing first 50 rows only)');
            EXIT;
        END IF;
    END LOOP;
    
--    DBMS_OUTPUT.PUT_LINE('');
--    DBMS_OUTPUT.PUT_LINE('Total rows processed: ' || v_row_count);
    
    -- Close cursor
    DBMS_SQL.CLOSE_CURSOR(v_cursor_id);
    
EXCEPTION
    WHEN OTHERS THEN
        IF DBMS_SQL.IS_OPEN(v_cursor_id) THEN
            DBMS_SQL.CLOSE_CURSOR(v_cursor_id);
        END IF;
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;

/
