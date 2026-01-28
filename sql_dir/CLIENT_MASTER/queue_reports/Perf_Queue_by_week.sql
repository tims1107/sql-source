DECLARE
    v_week_start DATE;
    v_week_end DATE;
    v_week_num NUMBER;
    v_grand_total NUMBER := 0;
    v_grand_excluded NUMBER := 0;
    
BEGIN
    -- Enable DBMS_OUTPUT
    DBMS_OUTPUT.ENABLE(1000000);
    
    -- Print header
    DBMS_OUTPUT.PUT_LINE('=================================================================');
    DBMS_OUTPUT.PUT_LINE('          CHANGE MANAGEMENT WEEKLY SUMMARY REPORT');
    DBMS_OUTPUT.PUT_LINE('          Analysis Period: Last 52 Weeks');
    DBMS_OUTPUT.PUT_LINE('          Queue Processing: Every 30 seconds');
    DBMS_OUTPUT.PUT_LINE('          Filter: Excluding records > 12 hours (720 minutes)');
    DBMS_OUTPUT.PUT_LINE('          Generated: ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI:SS'));
    DBMS_OUTPUT.PUT_LINE('=================================================================');
    DBMS_OUTPUT.PUT_LINE('');
    
    -- Column headers with exclusion tracking
    DBMS_OUTPUT.PUT_LINE(RPAD('WEEK', 6) || ' | ' || 
                        RPAD('WEEK_START', 14) || ' | ' || 
                        RPAD('WEEK_END', 14) || ' | ' || 
                        RPAD('RECORDS', 8) || ' | ' || 
                        RPAD('EXCLUDED', 9) || ' | ' || 
                        RPAD('AVG_MIN', 8) || ' | ' || 
                        RPAD('MAX_MIN', 8) || ' | ' || 
                        RPAD('SLOW_CNT', 9) || ' | ' ||
                        RPAD('PERFORMANCE', 12));
    DBMS_OUTPUT.PUT_LINE(RPAD('-', 6, '-') || '-+-' || 
                        RPAD('-', 14, '-') || '-+-' || 
                        RPAD('-', 14, '-') || '-+-' || 
                        RPAD('-', 8, '-') || '-+-' || 
                        RPAD('-', 9, '-') || '-+-' || 
                        RPAD('-', 8, '-') || '-+-' || 
                        RPAD('-', 8, '-') || '-+-' || 
                        RPAD('-', 9, '-') || '-+-' ||
                        RPAD('-', 12, '-'));
    
    -- Process each week (52 weeks back from today)
    FOR week_offset IN 0..51 LOOP
        v_week_num := 52 - week_offset;
        v_week_start := TRUNC(SYSDATE - (week_offset * 7), 'IW'); -- Start of ISO week
        v_week_end := v_week_start + 6; -- End of week
        
        -- Get weekly statistics including excluded records
        FOR week_stats IN (
            SELECT 
                -- Included records (?12 hours)
                SUM(CASE WHEN ROUND(EXTRACT(DAY FROM (q.legacyupdate - q.cmpostdate)) * 1440 + 
                                   EXTRACT(HOUR FROM (q.legacyupdate - q.cmpostdate)) * 60 + 
                                   EXTRACT(MINUTE FROM (q.legacyupdate - q.cmpostdate)) + 
                                   EXTRACT(SECOND FROM (q.legacyupdate - q.cmpostdate))/60, 2) <= 720 
                         THEN 1 ELSE 0 END) as record_count,
                
                -- Excluded records (>12 hours)
                SUM(CASE WHEN ROUND(EXTRACT(DAY FROM (q.legacyupdate - q.cmpostdate)) * 1440 + 
                                   EXTRACT(HOUR FROM (q.legacyupdate - q.cmpostdate)) * 60 + 
                                   EXTRACT(MINUTE FROM (q.legacyupdate - q.cmpostdate)) + 
                                   EXTRACT(SECOND FROM (q.legacyupdate - q.cmpostdate))/60, 2) > 720 
                         THEN 1 ELSE 0 END) as excluded_count,
                
                -- Statistics for included records only
                ROUND(AVG(CASE WHEN ROUND(EXTRACT(DAY FROM (q.legacyupdate - q.cmpostdate)) * 1440 + 
                                         EXTRACT(HOUR FROM (q.legacyupdate - q.cmpostdate)) * 60 + 
                                         EXTRACT(MINUTE FROM (q.legacyupdate - q.cmpostdate)) + 
                                         EXTRACT(SECOND FROM (q.legacyupdate - q.cmpostdate))/60, 2) <= 720 
                               THEN EXTRACT(DAY FROM (q.legacyupdate - q.cmpostdate)) * 1440 + 
                                    EXTRACT(HOUR FROM (q.legacyupdate - q.cmpostdate)) * 60 + 
                                    EXTRACT(MINUTE FROM (q.legacyupdate - q.cmpostdate)) + 
                                    EXTRACT(SECOND FROM (q.legacyupdate - q.cmpostdate))/60 
                               END), 2) as avg_minutes,
                
                ROUND(MAX(CASE WHEN ROUND(EXTRACT(DAY FROM (q.legacyupdate - q.cmpostdate)) * 1440 + 
                                         EXTRACT(HOUR FROM (q.legacyupdate - q.cmpostdate)) * 60 + 
                                         EXTRACT(MINUTE FROM (q.legacyupdate - q.cmpostdate)) + 
                                         EXTRACT(SECOND FROM (q.legacyupdate - q.cmpostdate))/60, 2) <= 720 
                               THEN EXTRACT(DAY FROM (q.legacyupdate - q.cmpostdate)) * 1440 + 
                                    EXTRACT(HOUR FROM (q.legacyupdate - q.cmpostdate)) * 60 + 
                                    EXTRACT(MINUTE FROM (q.legacyupdate - q.cmpostdate)) + 
                                    EXTRACT(SECOND FROM (q.legacyupdate - q.cmpostdate))/60 
                               END), 2) as max_minutes,
                
                SUM(CASE WHEN ROUND(EXTRACT(DAY FROM (q.legacyupdate - q.cmpostdate)) * 1440 + 
                                   EXTRACT(HOUR FROM (q.legacyupdate - q.cmpostdate)) * 60 + 
                                   EXTRACT(MINUTE FROM (q.legacyupdate - q.cmpostdate)) + 
                                   EXTRACT(SECOND FROM (q.legacyupdate - q.cmpostdate))/60, 2) > 180 
                             AND ROUND(EXTRACT(DAY FROM (q.legacyupdate - q.cmpostdate)) * 1440 + 
                                      EXTRACT(HOUR FROM (q.legacyupdate - q.cmpostdate)) * 60 + 
                                      EXTRACT(MINUTE FROM (q.legacyupdate - q.cmpostdate)) + 
                                      EXTRACT(SECOND FROM (q.legacyupdate - q.cmpostdate))/60, 2) <= 720 
                         THEN 1 ELSE 0 END) as slow_count,
                
                -- Additional metrics for detailed warnings
                SUM(CASE WHEN ROUND(EXTRACT(DAY FROM (q.legacyupdate - q.cmpostdate)) * 1440 + 
                                   EXTRACT(HOUR FROM (q.legacyupdate - q.cmpostdate)) * 60 + 
                                   EXTRACT(MINUTE FROM (q.legacyupdate - q.cmpostdate)) + 
                                   EXTRACT(SECOND FROM (q.legacyupdate - q.cmpostdate))/60, 2) > 360 
                             AND ROUND(EXTRACT(DAY FROM (q.legacyupdate - q.cmpostdate)) * 1440 + 
                                      EXTRACT(HOUR FROM (q.legacyupdate - q.cmpostdate)) * 60 + 
                                      EXTRACT(MINUTE FROM (q.legacyupdate - q.cmpostdate)) + 
                                      EXTRACT(SECOND FROM (q.legacyupdate - q.cmpostdate))/60, 2) <= 720 
                         THEN 1 ELSE 0 END) as very_slow_count,
                
                ROUND(MIN(CASE WHEN ROUND(EXTRACT(DAY FROM (q.legacyupdate - q.cmpostdate)) * 1440 + 
                                         EXTRACT(HOUR FROM (q.legacyupdate - q.cmpostdate)) * 60 + 
                                         EXTRACT(MINUTE FROM (q.legacyupdate - q.cmpostdate)) + 
                                         EXTRACT(SECOND FROM (q.legacyupdate - q.cmpostdate))/60, 2) <= 720 
                               THEN EXTRACT(DAY FROM (q.legacyupdate - q.cmpostdate)) * 1440 + 
                                    EXTRACT(HOUR FROM (q.legacyupdate - q.cmpostdate)) * 60 + 
                                    EXTRACT(MINUTE FROM (q.legacyupdate - q.cmpostdate)) + 
                                    EXTRACT(SECOND FROM (q.legacyupdate - q.cmpostdate))/60 
                               END), 2) as min_minutes,
                
                -- Maximum excluded record time for extreme exclusion alerts
                ROUND(MAX(CASE WHEN ROUND(EXTRACT(DAY FROM (q.legacyupdate - q.cmpostdate)) * 1440 + 
                                         EXTRACT(HOUR FROM (q.legacyupdate - q.cmpostdate)) * 60 + 
                                         EXTRACT(MINUTE FROM (q.legacyupdate - q.cmpostdate)) + 
                                         EXTRACT(SECOND FROM (q.legacyupdate - q.cmpostdate))/60, 2) > 720 
                               THEN EXTRACT(DAY FROM (q.legacyupdate - q.cmpostdate)) * 1440 + 
                                    EXTRACT(HOUR FROM (q.legacyupdate - q.cmpostdate)) * 60 + 
                                    EXTRACT(MINUTE FROM (q.legacyupdate - q.cmpostdate)) + 
                                    EXTRACT(SECOND FROM (q.legacyupdate - q.cmpostdate))/60 
                               END), 2) as max_excluded_minutes
                
            FROM cm_change_queue q
                JOIN cm_change_types t ON t.changetypeid = q.changetypeid
            WHERE q.legacyupdate IS NOT NULL
                AND q.changetypeid NOT IN (21)
                AND q.cmpostdate >= v_week_start
                AND q.cmpostdate < v_week_end + 1
        ) LOOP
            
            -- Determine weekly performance
            DECLARE
                v_performance VARCHAR2(12);
                v_total_week_records NUMBER;
                v_exclusion_rate NUMBER;
            BEGIN
                v_total_week_records := NVL(week_stats.record_count, 0) + NVL(week_stats.excluded_count, 0);
                
                IF v_total_week_records > 0 THEN
                    v_exclusion_rate := ROUND((NVL(week_stats.excluded_count, 0) * 100.0 / v_total_week_records), 1);
                ELSE
                    v_exclusion_rate := 0;
                END IF;
                
                IF week_stats.record_count = 0 THEN
                    v_performance := 'NO_DATA';
                ELSIF week_stats.avg_minutes > 60 THEN
                    v_performance := 'POOR';
                ELSIF week_stats.avg_minutes > 10 THEN
                    v_performance := 'MODERATE';
                ELSIF week_stats.avg_minutes > 2 THEN
                    v_performance := 'GOOD';
                ELSE
                    v_performance := 'EXCELLENT';
                END IF;
                
                -- Output weekly summary with exclusion data
                DBMS_OUTPUT.PUT_LINE(
                    RPAD(v_week_num, 6) || ' | ' ||
                    RPAD(TO_CHAR(v_week_start, 'MM-DD-YY'), 14) || ' | ' ||
                    RPAD(TO_CHAR(v_week_end, 'MM-DD-YY'), 14) || ' | ' ||
                    RPAD(NVL(TO_CHAR(week_stats.record_count), '0'), 8) || ' | ' ||
                    RPAD(NVL(TO_CHAR(week_stats.excluded_count), '0'), 9) || ' | ' ||
                    RPAD(NVL(TO_CHAR(week_stats.avg_minutes), '0'), 8) || ' | ' ||
                    RPAD(NVL(TO_CHAR(week_stats.max_minutes), '0'), 8) || ' | ' ||
                    RPAD(NVL(TO_CHAR(week_stats.slow_count), '0'), 9) || ' | ' ||
                    RPAD(v_performance, 12)
                );
                
                -- Add to grand totals
                v_grand_total := v_grand_total + NVL(week_stats.record_count, 0);
                v_grand_excluded := v_grand_excluded + NVL(week_stats.excluded_count, 0);
                
                -- Enhanced detailed warnings with exclusion information
                IF week_stats.excluded_count > 0 THEN
                    IF week_stats.excluded_count > 5 OR v_exclusion_rate > 10 THEN
                        DBMS_OUTPUT.PUT_LINE('    *** HIGH EXCLUSION ALERT ***');
                        DBMS_OUTPUT.PUT_LINE('        Week ' || v_week_num || ' (' || TO_CHAR(v_week_start, 'MM-DD-YY') || ' to ' || TO_CHAR(v_week_end, 'MM-DD-YY') || ')');
                        DBMS_OUTPUT.PUT_LINE('        Excluded Records: ' || week_stats.excluded_count || ' (>' || ROUND(720/60, 0) || ' hours)');
                        DBMS_OUTPUT.PUT_LINE('        Exclusion Rate: ' || v_exclusion_rate || '% of total week records');
                        DBMS_OUTPUT.PUT_LINE('        Max Excluded Time: ' || ROUND(week_stats.max_excluded_minutes/60, 1) || ' hours');
                        DBMS_OUTPUT.PUT_LINE('        Impact: Significant data excluded from analysis');
                    ELSE
                        DBMS_OUTPUT.PUT_LINE('    ** EXCLUSION NOTICE **');
                        DBMS_OUTPUT.PUT_LINE('        ' || week_stats.excluded_count || ' records excluded (>' || ROUND(720/60, 0) || 'hrs), ' || v_exclusion_rate || '% of week');
                    END IF;
                END IF;
                
                IF week_stats.slow_count > 10 THEN
                    DBMS_OUTPUT.PUT_LINE('    *** HIGH SLOW COUNT WARNING ***');
                    DBMS_OUTPUT.PUT_LINE('        Week ' || v_week_num || ' (' || TO_CHAR(v_week_start, 'MM-DD-YY') || ' to ' || TO_CHAR(v_week_end, 'MM-DD-YY') || ')');
                    DBMS_OUTPUT.PUT_LINE('        Total Slow Records: ' || week_stats.slow_count || ' (>3 hours)');
                    DBMS_OUTPUT.PUT_LINE('        Very Slow Records: ' || week_stats.very_slow_count || ' (>6 hours)');
                    DBMS_OUTPUT.PUT_LINE('        Percentage Slow: ' || ROUND((week_stats.slow_count * 100.0 / week_stats.record_count), 1) || '%');
                    DBMS_OUTPUT.PUT_LINE('        Avg Processing: ' || week_stats.avg_minutes || ' minutes');
                    DBMS_OUTPUT.PUT_LINE('        Range: ' || week_stats.min_minutes || ' - ' || week_stats.max_minutes || ' minutes');
                ELSIF week_stats.slow_count > 5 THEN
                    DBMS_OUTPUT.PUT_LINE('    ** MODERATE SLOW COUNT ALERT **');
                    DBMS_OUTPUT.PUT_LINE('        ' || week_stats.slow_count || ' records >3hrs (' || ROUND((week_stats.slow_count * 100.0 / week_stats.record_count), 1) || '% of analyzed records)');
                END IF;
                
                IF week_stats.max_minutes > 600 THEN -- > 10 hours
                    DBMS_OUTPUT.PUT_LINE('    *** EXTREME DELAY ALERT ***');
                    DBMS_OUTPUT.PUT_LINE('        Week ' || v_week_num || ' (' || TO_CHAR(v_week_start, 'MM-DD-YY') || ' to ' || TO_CHAR(v_week_end, 'MM-DD-YY') || ')');
                    DBMS_OUTPUT.PUT_LINE('        Maximum Delay: ' || ROUND(week_stats.max_minutes/60, 1) || ' hours (' || week_stats.max_minutes || ' minutes)');
                    DBMS_OUTPUT.PUT_LINE('        Average for Week: ' || week_stats.avg_minutes || ' minutes');
                    DBMS_OUTPUT.PUT_LINE('        Impact: Potential system performance issue or stuck process');
                ELSIF week_stats.max_minutes > 300 THEN -- > 5 hours
                    DBMS_OUTPUT.PUT_LINE('    ** SIGNIFICANT DELAY NOTICE **');
                    DBMS_OUTPUT.PUT_LINE('        Max delay: ' || ROUND(week_stats.max_minutes/60, 1) || 'hrs, Week avg: ' || week_stats.avg_minutes || 'min');
                END IF;
                
                -- Performance degradation warning
                IF week_stats.avg_minutes > 30 AND week_stats.record_count > 10 THEN
                    DBMS_OUTPUT.PUT_LINE('    ** PERFORMANCE DEGRADATION **');
                    DBMS_OUTPUT.PUT_LINE('        Week average (' || week_stats.avg_minutes || 'min) significantly above normal');
                    DBMS_OUTPUT.PUT_LINE('        Recommend investigation of system performance');
                END IF;
                
                -- Low activity warning
                IF v_total_week_records < 10 AND week_offset < 4 THEN -- Recent weeks only
                    DBMS_OUTPUT.PUT_LINE('    ** LOW ACTIVITY ALERT **');
                    DBMS_OUTPUT.PUT_LINE('        Only ' || v_total_week_records || ' total records processed this week');
                    DBMS_OUTPUT.PUT_LINE('        (' || NVL(week_stats.record_count, 0) || ' analyzed, ' || NVL(week_stats.excluded_count, 0) || ' excluded)');
                    DBMS_OUTPUT.PUT_LINE('        May indicate system downtime or reduced usage');
                END IF;
                
            END;
        END LOOP;
    END LOOP;
    
    -- Enhanced summary statistics with exclusion data
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('=================================================================');
    DBMS_OUTPUT.PUT_LINE('WEEKLY SUMMARY STATISTICS - LAST 52 WEEKS');
    DBMS_OUTPUT.PUT_LINE('=================================================================');
    DBMS_OUTPUT.PUT_LINE('Analysis Period         : ' || TO_CHAR(SYSDATE - 365, 'MM-DD-YY') || ' to ' || TO_CHAR(SYSDATE, 'MM-DD-YY'));
    DBMS_OUTPUT.PUT_LINE('Total Records Analyzed  : ' || v_grand_total);
    DBMS_OUTPUT.PUT_LINE('Total Records Excluded  : ' || v_grand_excluded || ' (>12 hours)');
    DBMS_OUTPUT.PUT_LINE('Grand Total Records     : ' || (v_grand_total + v_grand_excluded));
    DBMS_OUTPUT.PUT_LINE('Overall Exclusion Rate  : ' || ROUND((v_grand_excluded * 100.0 / (v_grand_total + v_grand_excluded)), 2) || '%');
    DBMS_OUTPUT.PUT_LINE('Average Records/Week    : ' || ROUND(v_grand_total/52, 1) || ' analyzed');
    DBMS_OUTPUT.PUT_LINE('Average Excluded/Week   : ' || ROUND(v_grand_excluded/52, 1) || ' excluded');
    DBMS_OUTPUT.PUT_LINE('');
    
    -- Rest of the performance summary remains the same...
    DBMS_OUTPUT.PUT_LINE('WEEKLY PERFORMANCE SUMMARY:');
    DBMS_OUTPUT.PUT_LINE('---------------------------');
    
    -- Count weeks by performance category
    DECLARE
        v_excellent_weeks NUMBER := 0;
        v_good_weeks NUMBER := 0;
        v_moderate_weeks NUMBER := 0;
        v_poor_weeks NUMBER := 0;
        v_no_data_weeks NUMBER := 0;
    BEGIN
        -- Count performance categories by re-running simplified queries
        FOR perf_count IN (
            SELECT 
                CASE 
                    WHEN COUNT(CASE WHEN ROUND(EXTRACT(DAY FROM (q.legacyupdate - q.cmpostdate)) * 1440 + 
                                            EXTRACT(HOUR FROM (q.legacyupdate - q.cmpostdate)) * 60 + 
                                            EXTRACT(MINUTE FROM (q.legacyupdate - q.cmpostdate)) + 
                                            EXTRACT(SECOND FROM (q.legacyupdate - q.cmpostdate))/60, 2) <= 720 
                                     THEN 1 END) = 0 THEN 'NO_DATA'
                    WHEN AVG(CASE WHEN ROUND(EXTRACT(DAY FROM (q.legacyupdate - q.cmpostdate)) * 1440 + 
                                           EXTRACT(HOUR FROM (q.legacyupdate - q.cmpostdate)) * 60 + 
                                           EXTRACT(MINUTE FROM (q.legacyupdate - q.cmpostdate)) + 
                                           EXTRACT(SECOND FROM (q.legacyupdate - q.cmpostdate))/60, 2) <= 720 
                                   THEN EXTRACT(DAY FROM (q.legacyupdate - q.cmpostdate)) * 1440 + 
                                        EXTRACT(HOUR FROM (q.legacyupdate - q.cmpostdate)) * 60 + 
                                        EXTRACT(MINUTE FROM (q.legacyupdate - q.cmpostdate)) + 
                                        EXTRACT(SECOND FROM (q.legacyupdate - q.cmpostdate))/60 
                                   END) > 60 
                    THEN 'POOR'
                    WHEN AVG(CASE WHEN ROUND(EXTRACT(DAY FROM (q.legacyupdate - q.cmpostdate)) * 1440 + 
                                           EXTRACT(HOUR FROM (q.legacyupdate - q.cmpostdate)) * 60 + 
                                           EXTRACT(MINUTE FROM (q.legacyupdate - q.cmpostdate)) + 
                                           EXTRACT(SECOND FROM (q.legacyupdate - q.cmpostdate))/60, 2) <= 720 
                                   THEN EXTRACT(DAY FROM (q.legacyupdate - q.cmpostdate)) * 1440 + 
                                        EXTRACT(HOUR FROM (q.legacyupdate - q.cmpostdate)) * 60 + 
                                        EXTRACT(MINUTE FROM (q.legacyupdate - q.cmpostdate)) + 
                                        EXTRACT(SECOND FROM (q.legacyupdate - q.cmpostdate))/60 
                                   END) > 10 
                    THEN 'MODERATE'
                    WHEN AVG(CASE WHEN ROUND(EXTRACT(DAY FROM (q.legacyupdate - q.cmpostdate)) * 1440 + 
                                           EXTRACT(HOUR FROM (q.legacyupdate - q.cmpostdate)) * 60 + 
                                           EXTRACT(MINUTE FROM (q.legacyupdate - q.cmpostdate)) + 
                                           EXTRACT(SECOND FROM (q.legacyupdate - q.cmpostdate))/60, 2) <= 720 
                                   THEN EXTRACT(DAY FROM (q.legacyupdate - q.cmpostdate)) * 1440 + 
                                        EXTRACT(HOUR FROM (q.legacyupdate - q.cmpostdate)) * 60 + 
                                        EXTRACT(MINUTE FROM (q.legacyupdate - q.cmpostdate)) + 
                                        EXTRACT(SECOND FROM (q.legacyupdate - q.cmpostdate))/60 
                                   END) > 2 
                    THEN 'GOOD'
                    ELSE 'EXCELLENT'
                END AS performance_category,
                TRUNC(q.cmpostdate, 'IW') as week_start
            FROM cm_change_queue q
                JOIN cm_change_types t ON t.changetypeid = q.changetypeid
            WHERE q.legacyupdate IS NOT NULL
                AND q.changetypeid NOT IN (21)
                AND q.cmpostdate > SYSDATE - 365
            GROUP BY TRUNC(q.cmpostdate, 'IW')
            ORDER BY week_start DESC
        ) LOOP
            IF perf_count.performance_category = 'EXCELLENT' THEN
                v_excellent_weeks := v_excellent_weeks + 1;
            ELSIF perf_count.performance_category = 'GOOD' THEN
                v_good_weeks := v_good_weeks + 1;
            ELSIF perf_count.performance_category = 'MODERATE' THEN
                v_moderate_weeks := v_moderate_weeks + 1;
            ELSIF perf_count.performance_category = 'POOR' THEN
                v_poor_weeks := v_poor_weeks + 1;
            ELSE
                v_no_data_weeks := v_no_data_weeks + 1;
            END IF;
        END LOOP;
        
        -- Output performance summary
        DBMS_OUTPUT.PUT_LINE('EXCELLENT weeks (<2min avg) : ' || v_excellent_weeks || ' (' || ROUND(v_excellent_weeks*100/52,1) || '%)');
        DBMS_OUTPUT.PUT_LINE('GOOD weeks (2-10min avg)    : ' || v_good_weeks || ' (' || ROUND(v_good_weeks*100/52,1) || '%)');
        DBMS_OUTPUT.PUT_LINE('MODERATE weeks (10-60min)   : ' || v_moderate_weeks || ' (' || ROUND(v_moderate_weeks*100/52,1) || '%)');
        DBMS_OUTPUT.PUT_LINE('POOR weeks (>60min avg)     : ' || v_poor_weeks || ' (' || ROUND(v_poor_weeks*100/52,1) || '%)');
        DBMS_OUTPUT.PUT_LINE('NO_DATA weeks               : ' || v_no_data_weeks || ' (' || ROUND(v_no_data_weeks*100/52,1) || '%)');
    END;
    
    DBMS_OUTPUT.PUT_LINE('=================================================================');
    
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('ERROR: ' || SQLERRM);
        RAISE;
END;
/