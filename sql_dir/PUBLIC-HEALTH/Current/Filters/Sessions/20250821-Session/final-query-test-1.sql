SELECT * FROM (SELECT 
        gtt.*,
        845 as condition_master_pk
    FROM GTT_RESULTS_EXTRACT gtt
    WHERE 1=1 AND gtt.order_test_code = '301' AND gtt.result_test_code = '301' AND ((upper(result_comments) LIKE upper('%Newly confirmed Positive%') or upper(result_comments) LIKE upper('%New positive%'))) UNION ALL SELECT 
        gtt.*,
        847 as condition_master_pk
    FROM GTT_RESULTS_EXTRACT gtt
    WHERE 1=1 AND gtt.order_test_code = '310' AND gtt.result_test_code = '310' AND ((upper(textual_result_full) LIKE upper('Positive%') or upper(textual_result_full) LIKE upper('Equivocal%') or upper(textual_result_full) LIKE upper('Reactive%'))) UNION ALL SELECT 
        gtt.*,
        853 as condition_master_pk
    FROM GTT_RESULTS_EXTRACT gtt
    WHERE 1=1 AND gtt.order_test_code = '303' AND gtt.result_test_code = '303' AND ((upper(textual_result_full) LIKE upper('Positive%') or upper(textual_result_full) LIKE upper('Equivocal%') or upper(textual_result_full) LIKE upper('Reactive%'))) UNION ALL SELECT 
        gtt.*,
        856 as condition_master_pk
    FROM GTT_RESULTS_EXTRACT gtt
    WHERE 1=1 AND gtt.order_test_code = '304' AND gtt.result_test_code = '304' AND ((upper(textual_result_full) LIKE upper('Positive%') or upper(textual_result_full) LIKE upper('Equivocal%') or upper(textual_result_full) LIKE upper('Reactive%'))) UNION ALL SELECT 
        gtt.*,
        860 as condition_master_pk
    FROM GTT_RESULTS_EXTRACT gtt
    WHERE 1=1 AND gtt.order_test_code = '310' AND gtt.result_test_code = '310A' AND ((gtt.value_type = 'ST' and gtt.textual_result_full like '%>11.00%')) UNION ALL SELECT 
        gtt.*,
        1902 as condition_master_pk
    FROM GTT_RESULTS_EXTRACT gtt
    WHERE 1=1 AND gtt.order_test_code = '311' AND ((upper(textual_result_full) LIKE upper('%'))) UNION ALL SELECT 
        gtt.*,
        1904 as condition_master_pk
    FROM GTT_RESULTS_EXTRACT gtt
    WHERE 1=1 AND gtt.order_test_code = '318' AND gtt.result_test_code = '318L' AND ((upper(textual_result_full) LIKE upper('%'))) UNION ALL SELECT 
        gtt.*,
        1905 as condition_master_pk
    FROM GTT_RESULTS_EXTRACT gtt
    WHERE 1=1 AND gtt.order_test_code = '318' AND gtt.result_test_code = '318R' AND ((upper(textual_result_full) LIKE upper('%'))) UNION ALL SELECT 
        gtt.*,
        1919 as condition_master_pk
    FROM GTT_RESULTS_EXTRACT gtt
    WHERE 1=1 AND gtt.order_test_code = '310' AND gtt.result_test_code = '310A' AND ((gtt.value_type = 'NM' and gtt.numeric_result > 0.00))) 
                        ORDER BY condition_master_pk, accession_number, order_test_code;
                        
SELECT order_number,result_test_code FROM (SELECT 
        gtt.*
    FROM GTT_RESULTS_EXTRACT gtt
    WHERE 1=1 AND gtt.order_test_code = '311' AND ((upper(textual_result_full) LIKE upper('%')))); 
    
/
SELECT * FROM (SELECT 
        gtt.*,
        845 as condition_master_pk
    FROM GTT_RESULTS_EXTRACT gtt
    WHERE 1=1 AND gtt.order_test_code = '301' AND gtt.result_test_code = '301' AND ((upper(result_comments) LIKE upper('%Newly confirmed Positive%') or upper(result_comments) LIKE upper('%New positive%'))) UNION ALL SELECT 
        gtt.*,
        847 as condition_master_pk
    FROM GTT_RESULTS_EXTRACT gtt
    WHERE 1=1 AND gtt.order_test_code = '310' AND gtt.result_test_code = '310' AND ((upper(textual_result_full) LIKE upper('Positive%') or upper(textual_result_full) LIKE upper('Equivocal%') or upper(textual_result_full) LIKE upper('Reactive%'))) UNION ALL SELECT 
        gtt.*,
        854 as condition_master_pk
    FROM GTT_RESULTS_EXTRACT gtt
    WHERE 1=1 AND gtt.order_test_code = '308' AND gtt.result_test_code = '308' AND ((upper(textual_result_full) LIKE upper('Positive%') or upper(textual_result_full) LIKE upper('Equivocal%') or upper(textual_result_full) LIKE upper('Reactive%'))) UNION ALL SELECT 
        gtt.*,
        860 as condition_master_pk
    FROM GTT_RESULTS_EXTRACT gtt
    WHERE 1=1 AND gtt.order_test_code = '310' AND gtt.result_test_code = '310A' AND ((gtt.value_type = 'ST' and gtt.textual_result_full like '%>11.00%')) UNION ALL SELECT 
        gtt.*,
        1902 as condition_master_pk
    FROM GTT_RESULTS_EXTRACT gtt
    WHERE 1=1 AND gtt.order_test_code = '311' AND ((upper(textual_result_full) LIKE upper('%'))) UNION ALL SELECT 
        gtt.*,
        1904 as condition_master_pk
    FROM GTT_RESULTS_EXTRACT gtt
    WHERE 1=1 AND gtt.order_test_code = '318' AND gtt.result_test_code = '318L' AND ((upper(textual_result_full) LIKE upper('%'))) UNION ALL SELECT 
        gtt.*,
        1905 as condition_master_pk
    FROM GTT_RESULTS_EXTRACT gtt
    WHERE 1=1 AND gtt.order_test_code = '318' AND gtt.result_test_code = '318R' AND ((upper(textual_result_full) LIKE upper('%'))) UNION ALL SELECT 
        gtt.*,
        1919 as condition_master_pk
    FROM GTT_RESULTS_EXTRACT gtt
    WHERE 1=1 AND gtt.order_test_code = '310' AND gtt.result_test_code = '310A' AND ((gtt.value_type = 'NM' and gtt.numeric_result > 0.00))) 
                        ORDER BY condition_master_pk, accession_number, order_test_code;

update asr_process_run
set complete = 'R'
where order_number IN
(select order_number from asr_process_run
where complete='N');

create table asr_process_run_20250820_LF
as
select * from asr_process_run
where activitydate = '20-AUG-25'
and source = 'IL'
and complete = 'N';

delete asr_process_run
where activitydate = '20-AUG-25'
and complete = 'N';

select result_test_code,textual_result_full from asr_process_run
where activitydate = '20-AUG-25'
and source = 'IL'
group by result_test_code,textual_result_full;

and complete = 'N';


insert into results_sent_log
select * from results_sent_log_20250818;

select result_test_code,textual_result_full,count(1) from results_sent_log
where last_update_time > '20-AUG-25 12.28.19.456486000 AM'
and patient_account_state = 'IL'
group by result_test_code,textual_result_full;
order by last_update_time desc;
                                                