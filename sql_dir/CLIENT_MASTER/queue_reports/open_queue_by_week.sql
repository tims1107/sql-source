DECLARE
    v_week_start DATE;
    v_week_end DATE;
    v_week_num NUMBER;
    v_grand_total NUMBER := 0;
    
BEGIN
    -- Enable DBMS_OUTPUT
    DBMS_OUTPUT.ENABLE(1000000);
    
    -- Print header
    DBMS_OUTPUT.PUT_LINE('=================================================================');
    DBMS_OUTPUT.PUT_LINE('          CHANGE MANAGEMENT OPEN RECORDS WEEKLY REPORT');
    DBMS_OUTPUT.PUT_LINE('          Analysis Period: Last 52 Weeks');
    DBMS_OUTPUT.PUT_LINE('          Queue Processing: Every 30 seconds');
    DBMS_OUTPUT.PUT_LINE('          Filter: Open records only (legacyupdate IS NULL)');
    DBMS_OUTPUT.PUT_LINE('          Generated: ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI:SS'));
    DBMS_OUTPUT.PUT_LINE('=================================================================');
    DBMS_OUTPUT.PUT_LINE('');
    
    -- Column headers for open records
    DBMS_OUTPUT.PUT_LINE(RPAD('WEEK', 6) || ' | ' || 
                        RPAD('WEEK_START', 14) || ' | ' || 
                        RPAD('WEEK_END', 14) || ' | ' || 
                        RPAD('OPEN_CNT', 9) || ' | ' || 
                        RPAD('AGE_DAYS', 9) || ' | ' || 
                        RPAD('MAX_AGE', 8) || ' | ' || 
                        RPAD('OLD_CNT', 8) || ' | ' ||
                        RPAD('STATUS', 12));
    DBMS_OUTPUT.PUT_LINE(RPAD('-', 6, '-') || '-+-' || 
                        RPAD('-', 14, '-') || '-+-' || 
                        RPAD('-', 14, '-') || '-+-' || 
                        RPAD('-', 9, '-') || '-+-' || 
                        RPAD('-', 9, '-') || '-+-' || 
                        RPAD('-', 8, '-') || '-+-' || 
                        RPAD('-', 8, '-') || '-+-' ||
                        RPAD('-', 12, '-'));
    
    -- Process each week (52 weeks back from today)
    FOR week_offset IN 0..51 LOOP
        v_week_num := 52 - week_offset;
        v_week_start := TRUNC(SYSDATE - (week_offset * 7), 'IW'); -- Start of ISO week
        v_week_end := v_week_start + 6; -- End of week
        
        -- Declare variables for this week's statistics
        DECLARE
            v_open_count NUMBER := 0;
            v_avg_age_days NUMBER := 0;
            v_max_age_days NUMBER := 0;
            v_min_age_days NUMBER := 0;
            v_old_count NUMBER := 0;
            v_very_old_count NUMBER := 0;
            v_extremely_old_count NUMBER := 0;
            v_status VARCHAR2(12);
        BEGIN
            -- Get weekly open records statistics using proper date arithmetic
            SELECT 
                COUNT(*),
                NVL(ROUND(AVG(TRUNC(SYSDATE) - TRUNC(q.cmpostdate)), 1), 0),
                NVL(ROUND(MAX(TRUNC(SYSDATE) - TRUNC(q.cmpostdate)), 1), 0),
                NVL(ROUND(MIN(TRUNC(SYSDATE) - TRUNC(q.cmpostdate)), 1), 0),
                SUM(CASE WHEN (TRUNC(SYSDATE) - TRUNC(q.cmpostdate)) > 7 THEN 1 ELSE 0 END),
                SUM(CASE WHEN (TRUNC(SYSDATE) - TRUNC(q.cmpostdate)) > 30 THEN 1 ELSE 0 END),
                SUM(CASE WHEN (TRUNC(SYSDATE) - TRUNC(q.cmpostdate)) > 90 THEN 1 ELSE 0 END)
            INTO v_open_count, v_avg_age_days, v_max_age_days, v_min_age_days, 
                 v_old_count, v_very_old_count, v_extremely_old_count
            FROM cm_change_queue q
                JOIN cm_change_types t ON t.changetypeid = q.changetypeid
            WHERE q.legacyupdate IS NULL  -- Open records only
                AND q.changetypeid NOT IN (21)
                AND q.cmpostdate >= v_week_start
                AND q.cmpostdate < v_week_end + 1;
            
            -- Determine status based on open record characteristics
            IF v_open_count = 0 THEN
                v_status := 'ALL_CLOSED';
            ELSIF v_extremely_old_count > 0 THEN
                v_status := 'CRITICAL';
            ELSIF v_very_old_count > 0 THEN
                v_status := 'WARNING';
            ELSIF v_old_count > 5 THEN
                v_status := 'ATTENTION';
            ELSIF v_avg_age_days > 3 THEN
                v_status := 'MODERATE';
            ELSE
                v_status := 'NORMAL';
            END IF;
            
            -- Output weekly summary
            DBMS_OUTPUT.PUT_LINE(
                RPAD(v_week_num, 6) || ' | ' ||
                RPAD(TO_CHAR(v_week_start, 'MM-DD-YY'), 14) || ' | ' ||
                RPAD(TO_CHAR(v_week_end, 'MM-DD-YY'), 14) || ' | ' ||
                RPAD(TO_CHAR(v_open_count), 9) || ' | ' ||
                RPAD(TO_CHAR(v_avg_age_days), 9) || ' | ' ||
                RPAD(TO_CHAR(v_max_age_days), 8) || ' | ' ||
                RPAD(TO_CHAR(v_old_count), 8) || ' | ' ||
                RPAD(v_status, 12)
            );
            
            -- Add to grand total
            v_grand_total := v_grand_total + v_open_count;
            
            -- Enhanced detailed warnings for open records
            IF v_extremely_old_count > 0 THEN
                DBMS_OUTPUT.PUT_LINE('    *** CRITICAL - EXTREMELY OLD RECORDS ***');
                DBMS_OUTPUT.PUT_LINE('        Week ' || v_week_num || ' (' || TO_CHAR(v_week_start, 'MM-DD-YY') || ' to ' || TO_CHAR(v_week_end, 'MM-DD-YY') || ')');
                DBMS_OUTPUT.PUT_LINE('        Extremely Old Records: ' || v_extremely_old_count || ' (>90 days old)');
                DBMS_OUTPUT.PUT_LINE('        Very Old Records: ' || v_very_old_count || ' (>30 days old)');
                DBMS_OUTPUT.PUT_LINE('        Maximum Age: ' || v_max_age_days || ' days');
                DBMS_OUTPUT.PUT_LINE('        Average Age: ' || v_avg_age_days || ' days');
                DBMS_OUTPUT.PUT_LINE('        Impact: Potential stuck processes or system issues');
            ELSIF v_very_old_count > 0 THEN
                DBMS_OUTPUT.PUT_LINE('    *** WARNING - VERY OLD RECORDS ***');
                DBMS_OUTPUT.PUT_LINE('        Week ' || v_week_num || ' (' || TO_CHAR(v_week_start, 'MM-DD-YY') || ' to ' || TO_CHAR(v_week_end, 'MM-DD-YY') || ')');
                DBMS_OUTPUT.PUT_LINE('        Very Old Records: ' || v_very_old_count || ' (>30 days old)');
                DBMS_OUTPUT.PUT_LINE('        Old Records: ' || v_old_count || ' (>7 days old)');
                DBMS_OUTPUT.PUT_LINE('        Maximum Age: ' || v_max_age_days || ' days');
                DBMS_OUTPUT.PUT_LINE('        Recommend investigation of unprocessed items');
            ELSIF v_old_count > 10 THEN
                DBMS_OUTPUT.PUT_LINE('    ** HIGH OLD RECORD COUNT **');
                DBMS_OUTPUT.PUT_LINE('        ' || v_old_count || ' records >7 days old (' || ROUND((v_old_count * 100.0 / GREATEST(v_open_count, 1)), 1) || '% of open records)');
                DBMS_OUTPUT.PUT_LINE('        Max age: ' || v_max_age_days || ' days, Avg age: ' || v_avg_age_days || ' days');
            ELSIF v_old_count > 5 THEN
                DBMS_OUTPUT.PUT_LINE('    ** MODERATE OLD RECORD COUNT **');
                DBMS_OUTPUT.PUT_LINE('        ' || v_old_count || ' records >7 days old, Max: ' || v_max_age_days || ' days');
            END IF;
            
            -- High volume of open records warning
            IF v_open_count > 100 THEN
                DBMS_OUTPUT.PUT_LINE('    ** HIGH OPEN RECORD VOLUME **');
                DBMS_OUTPUT.PUT_LINE('        ' || v_open_count || ' open records from this week');
                DBMS_OUTPUT.PUT_LINE('        May indicate processing bottleneck or system capacity issue');
            ELSIF v_open_count > 50 THEN
                DBMS_OUTPUT.PUT_LINE('    ** ELEVATED OPEN RECORD COUNT **');
                DBMS_OUTPUT.PUT_LINE('        ' || v_open_count || ' open records - monitor for processing delays');
            END IF;
            
            -- Recent high-age average warning
            IF v_avg_age_days > 14 AND week_offset < 8 THEN -- Recent 8 weeks
                DBMS_OUTPUT.PUT_LINE('    ** RECENT HIGH AVERAGE AGE **');
                DBMS_OUTPUT.PUT_LINE('        Average age of ' || v_avg_age_days || ' days indicates processing delays');
                DBMS_OUTPUT.PUT_LINE('        Range: ' || v_min_age_days || ' - ' || v_max_age_days || ' days');
            END IF;
        END;
    END LOOP;
    
    -- Get current overall open records statistics
    DECLARE
        v_current_open NUMBER := 0;
        v_current_old NUMBER := 0;
        v_current_very_old NUMBER := 0;
        v_current_extremely_old NUMBER := 0;
        v_current_avg_age NUMBER := 0;
        v_current_max_age NUMBER := 0;
    BEGIN
        SELECT 
            COUNT(*),
            SUM(CASE WHEN (TRUNC(SYSDATE) - TRUNC(q.cmpostdate)) > 7 THEN 1 ELSE 0 END),
            SUM(CASE WHEN (TRUNC(SYSDATE) - TRUNC(q.cmpostdate)) > 30 THEN 1 ELSE 0 END),
            SUM(CASE WHEN (TRUNC(SYSDATE) - TRUNC(q.cmpostdate)) > 90 THEN 1 ELSE 0 END),
            NVL(ROUND(AVG(TRUNC(SYSDATE) - TRUNC(q.cmpostdate)), 1), 0),
            NVL(ROUND(MAX(TRUNC(SYSDATE) - TRUNC(q.cmpostdate)), 1), 0)
        INTO v_current_open, v_current_old, v_current_very_old, v_current_extremely_old, v_current_avg_age, v_current_max_age
        FROM cm_change_queue q
            JOIN cm_change_types t ON t.changetypeid = q.changetypeid
        WHERE q.legacyupdate IS NULL
            AND q.changetypeid NOT IN (21);
    
        -- Enhanced summary statistics
        DBMS_OUTPUT.PUT_LINE('');
        DBMS_OUTPUT.PUT_LINE('=================================================================');
        DBMS_OUTPUT.PUT_LINE('OPEN RECORDS SUMMARY - LAST 52 WEEKS');
        DBMS_OUTPUT.PUT_LINE('=================================================================');
        DBMS_OUTPUT.PUT_LINE('Analysis Period           : ' || TO_CHAR(SYSDATE - 365, 'MM-DD-YY') || ' to ' || TO_CHAR(SYSDATE, 'MM-DD-YY'));
        DBMS_OUTPUT.PUT_LINE('Total Open Records Created: ' || v_grand_total || ' (from last 52 weeks)');
        DBMS_OUTPUT.PUT_LINE('Average Open/Week         : ' || ROUND(v_grand_total/52, 1));
        DBMS_OUTPUT.PUT_LINE('');
        DBMS_OUTPUT.PUT_LINE('CURRENT OPEN RECORDS STATUS:');
        DBMS_OUTPUT.PUT_LINE('-------------------------------');
        DBMS_OUTPUT.PUT_LINE('Currently Open Records    : ' || v_current_open);
        DBMS_OUTPUT.PUT_LINE('Records >7 days old       : ' || v_current_old || ' (' || ROUND((v_current_old * 100.0 / GREATEST(v_current_open, 1)), 1) || '%)');
        DBMS_OUTPUT.PUT_LINE('Records >30 days old      : ' || v_current_very_old || ' (' || ROUND((v_current_very_old * 100.0 / GREATEST(v_current_open, 1)), 1) || '%)');
        DBMS_OUTPUT.PUT_LINE('Records >90 days old      : ' || v_current_extremely_old || ' (' || ROUND((v_current_extremely_old * 100.0 / GREATEST(v_current_open, 1)), 1) || '%)');
        DBMS_OUTPUT.PUT_LINE('Average Age of Open Items : ' || v_current_avg_age || ' days');
        DBMS_OUTPUT.PUT_LINE('Oldest Open Record        : ' || v_current_max_age || ' days');
        
        -- Current status assessment
        DBMS_OUTPUT.PUT_LINE('');
        DBMS_OUTPUT.PUT_LINE('CURRENT STATUS ASSESSMENT:');
        DBMS_OUTPUT.PUT_LINE('-----------------------------');
        IF v_current_extremely_old > 0 THEN
            DBMS_OUTPUT.PUT_LINE('STATUS: CRITICAL - ' || v_current_extremely_old || ' records over 90 days old');
            DBMS_OUTPUT.PUT_LINE('ACTION: Immediate investigation required for stuck processes');
        ELSIF v_current_very_old > 0 THEN
            DBMS_OUTPUT.PUT_LINE('STATUS: WARNING - ' || v_current_very_old || ' records over 30 days old');
            DBMS_OUTPUT.PUT_LINE('ACTION: Review processing queue and system performance');
        ELSIF v_current_old > 10 THEN
            DBMS_OUTPUT.PUT_LINE('STATUS: ATTENTION - ' || v_current_old || ' records over 7 days old');
            DBMS_OUTPUT.PUT_LINE('ACTION: Monitor processing times and queue capacity');
        ELSIF v_current_avg_age > 3 THEN
            DBMS_OUTPUT.PUT_LINE('STATUS: MODERATE - Average age of ' || v_current_avg_age || ' days');
            DBMS_OUTPUT.PUT_LINE('ACTION: Normal monitoring, slight processing delay');
        ELSE
            DBMS_OUTPUT.PUT_LINE('STATUS: NORMAL - Processing within expected timeframes');
            DBMS_OUTPUT.PUT_LINE('ACTION: Continue routine monitoring');
        END IF;
    END;
    
    DBMS_OUTPUT.PUT_LINE('=================================================================');
    
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('ERROR: ' || SQLERRM);
        RAISE;
END;
/