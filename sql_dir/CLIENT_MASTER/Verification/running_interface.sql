select * from cm_change_queue
where legacyupdate is null
and changetypeid not in (21)
order by cmpostdate desc;

select * from clinic_quest
where pat_quest_acct_number is not null;

select * from cm_change_queue
where changetypeid not in (21)
order by legacyupdate desc;

/

select components.componentid,components.componentdesc,t.changetypeid,t.changetypedesc,t.changeview,q.cmpostdate,q.legacyupdate,q.legacyupdate - q.cmpostdate time_to_update from cm_change_queue q
join cm_change_types t ON t.changetypeid = q.changetypeid
join cm_change_components components ON components.componentid = q.componentid
where legacyupdate is not null
and q.changetypeid not in (21)
and cmpostdate > sysdate - 5
order by cmpostdate;

/
DECLARE
    -- Variables for processing
    v_count NUMBER := 0;
    v_total_records NUMBER := 0;
    
    -- Cursor for main analysis
    CURSOR c_elapsed_time IS
        SELECT 
            components.componentid,
            components.componentdesc,
            t.changetypeid,
            t.changetypedesc,
            t.changeview,
            q.cmpostdate,
            q.legacyupdate,
            q.legacyupdate - q.cmpostdate AS elapsed_days,
            ROUND((q.legacyupdate - q.cmpostdate) * 24, 2) AS elapsed_hours,
            ROUND((q.legacyupdate - q.cmpostdate) * 24 * 60, 2) AS elapsed_minutes,
            CASE 
                WHEN q.legacyupdate - q.cmpostdate > 2 THEN 'VERY_SLOW'
                WHEN q.legacyupdate - q.cmpostdate > 1 THEN 'SLOW'
                WHEN q.legacyupdate - q.cmpostdate > 0.5 THEN 'MODERATE'
                WHEN q.legacyupdate - q.cmpostdate > 0.125 THEN 'FAST'
                ELSE 'VERY_FAST'
            END AS performance_category
        FROM cm_change_queue q
            JOIN cm_change_types t ON t.changetypeid = q.changetypeid
            JOIN cm_change_components components ON components.componentid = q.componentid
        WHERE q.legacyupdate IS NOT NULL
            AND q.changetypeid NOT IN (21)
            AND q.cmpostdate > SYSDATE - 5
        ORDER BY q.cmpostdate DESC;

BEGIN
    -- Enable DBMS_OUTPUT
    DBMS_OUTPUT.ENABLE(1000000);
    
    -- Print header
    DBMS_OUTPUT.PUT_LINE('=================================================================');
    DBMS_OUTPUT.PUT_LINE('          CHANGE MANAGEMENT ELAPSED TIME ANALYSIS');
    DBMS_OUTPUT.PUT_LINE('          Analysis Period: Last 5 Days');
    DBMS_OUTPUT.PUT_LINE('          Generated: ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI:SS'));
    DBMS_OUTPUT.PUT_LINE('=================================================================');
    DBMS_OUTPUT.PUT_LINE('');
    
    -- Column headers
    DBMS_OUTPUT.PUT_LINE(RPAD('COMP_ID', 8) || ' | ' || 
                        RPAD('CHANGE_TYPE', 12) || ' | ' || 
                        RPAD('COMPONENT_DESC', 25) || ' | ' || 
                        RPAD('ELAPSED_HRS', 12) || ' | ' || 
                        RPAD('PERFORMANCE', 12));
    DBMS_OUTPUT.PUT_LINE(RPAD('-', 8, '-') || '-+-' || 
                        RPAD('-', 12, '-') || '-+-' || 
                        RPAD('-', 25, '-') || '-+-' || 
                        RPAD('-', 12, '-') || '-+-' || 
                        RPAD('-', 12, '-'));
    
    -- Process each record
    FOR rec IN c_elapsed_time LOOP
        v_count := v_count + 1;
        
        DBMS_OUTPUT.PUT_LINE(
            RPAD(NVL(TO_CHAR(rec.componentid), 'N/A'), 8) || ' | ' ||
            RPAD(NVL(TO_CHAR(rec.changetypeid), 'N/A'), 12) || ' | ' ||
            RPAD(SUBSTR(NVL(rec.componentdesc, 'N/A'), 1, 25), 25) || ' | ' ||
            RPAD(NVL(TO_CHAR(rec.elapsed_hours), 'N/A'), 12) || ' | ' ||
            RPAD(NVL(rec.performance_category, 'N/A'), 12)
        );
        
        -- Add details for slow updates
        IF rec.elapsed_days > 1 THEN
            DBMS_OUTPUT.PUT_LINE('    ??  SLOW UPDATE: ' || 
                               TO_CHAR(rec.cmpostdate, 'YYYY-MM-DD HH24:MI') || 
                               ' ? ' || 
                               TO_CHAR(rec.legacyupdate, 'YYYY-MM-DD HH24:MI'));
        END IF;
        
        -- Limit output for readability
        IF v_count >= 50 THEN
            DBMS_OUTPUT.PUT_LINE('... (showing first 50 records)');
            EXIT;
        END IF;
    END LOOP;
    
    -- Get total count
    SELECT COUNT(*) INTO v_total_records
    FROM cm_change_queue q
        JOIN cm_change_types t ON t.changetypeid = q.changetypeid
        JOIN cm_change_components components ON components.componentid = q.componentid
    WHERE q.legacyupdate IS NOT NULL
        AND q.changetypeid NOT IN (21)
        AND q.cmpostdate > SYSDATE - 5;
    
    -- Summary statistics
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('=================================================================');
    DBMS_OUTPUT.PUT_LINE('SUMMARY STATISTICS');
    DBMS_OUTPUT.PUT_LINE('=================================================================');
    DBMS_OUTPUT.PUT_LINE('Total Records Found: ' || v_total_records);
    DBMS_OUTPUT.PUT_LINE('Records Displayed: ' || LEAST(v_count, 50));
    
    -- Performance breakdown
    FOR perf_rec IN (
        SELECT 
            CASE 
                WHEN q.legacyupdate - q.cmpostdate > 2 THEN 'VERY_SLOW (>2 days)'
                WHEN q.legacyupdate - q.cmpostdate > 1 THEN 'SLOW (1-2 days)'
                WHEN q.legacyupdate - q.cmpostdate > 0.5 THEN 'MODERATE (12-24 hrs)'
                WHEN q.legacyupdate - q.cmpostdate > 0.125 THEN 'FAST (3-12 hrs)'
                ELSE 'VERY_FAST (<3 hrs)'
            END AS category,
            COUNT(*) AS count_records,
            ROUND(AVG(q.legacyupdate - q.cmpostdate) * 24, 2) AS avg_hours
        FROM cm_change_queue q
            JOIN cm_change_types t ON t.changetypeid = q.changetypeid
        WHERE q.legacyupdate IS NOT NULL
            AND q.changetypeid NOT IN (21)
            AND q.cmpostdate > SYSDATE - 5
        GROUP BY 
            CASE 
                WHEN q.legacyupdate - q.cmpostdate > 2 THEN 'VERY_SLOW (>2 days)'
                WHEN q.legacyupdate - q.cmpostdate > 1 THEN 'SLOW (1-2 days)'
                WHEN q.legacyupdate - q.cmpostdate > 0.5 THEN 'MODERATE (12-24 hrs)'
                WHEN q.legacyupdate - q.cmpostdate > 0.125 THEN 'FAST (3-12 hrs)'
                ELSE 'VERY_FAST (<3 hrs)'
            END
        ORDER BY avg_hours DESC
    ) LOOP
        DBMS_OUTPUT.PUT_LINE(RPAD(perf_rec.category, 25) || ': ' || 
                           LPAD(perf_rec.count_records, 4) || ' records (avg: ' || 
                           perf_rec.avg_hours || ' hrs)');
    END LOOP;
    
    DBMS_OUTPUT.PUT_LINE('=================================================================');
    
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('ERROR: ' || SQLERRM);
        RAISE;
END;
/


/


select * from gen_audit
where tab = 'CLINIC_DETAIL'
and col = 'STATUSID'
and pk = 607213;

select * from cm_change_types;

select * from vw_legacy_cohort
where clinicid = 225695;

select * from cm_change_queue
where legacyupdate is null
order by cmpostdate desc;