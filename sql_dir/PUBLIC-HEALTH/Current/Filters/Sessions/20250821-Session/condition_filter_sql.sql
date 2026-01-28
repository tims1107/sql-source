declare v_order_test_code varchar2(10);
v_order_number varchar2(7);
v_cursor_id NUMBER;

begin

SELECT * FROM (SELECT 
        gtt.*
    FROM GTT_RESULTS_EXTRACT gtt
    WHERE 1=1 AND gtt.order_test_code = '301' AND gtt.result_test_code = '301' AND ((upper(result_comments) LIKE upper('%Newly confirmed Positive%') or upper(result_comments) LIKE upper('%New positive%'))) UNION ALL SELECT 
        gtt.*
    FROM GTT_RESULTS_EXTRACT gtt
    WHERE 1=1 AND gtt.order_test_code = '310' AND gtt.result_test_code = '310' AND ((upper(textual_result_full) LIKE upper('Positive%') or upper(textual_result_full) LIKE upper('Equivocal%') or upper(textual_result_full) LIKE upper('Reactive%'))) UNION ALL SELECT 
        gtt.*
    FROM GTT_RESULTS_EXTRACT gtt
    WHERE 1=1 AND gtt.order_test_code = '303' AND gtt.result_test_code = '303' AND ((upper(textual_result_full) LIKE upper('Positive%') or upper(textual_result_full) LIKE upper('Equivocal%') or upper(textual_result_full) LIKE upper('Reactive%'))) UNION ALL SELECT 
        gtt.*
    FROM GTT_RESULTS_EXTRACT gtt
    WHERE 1=1 AND gtt.order_test_code = '304' AND gtt.result_test_code = '304' AND ((upper(textual_result_full) LIKE upper('Positive%') or upper(textual_result_full) LIKE upper('Equivocal%') or upper(textual_result_full) LIKE upper('Reactive%'))) UNION ALL SELECT 
        gtt.*
    FROM GTT_RESULTS_EXTRACT gtt
    WHERE 1=1 AND gtt.order_test_code = '310' AND gtt.result_test_code = '310A' AND ((gtt.value_type = 'ST' and gtt.textual_result_full like '%>11.00%')) UNION ALL SELECT 
        gtt.*
    FROM GTT_RESULTS_EXTRACT gtt
    WHERE 1=1 AND gtt.order_test_code = '332' AND gtt.result_test_code = '332' AND ((upper(textual_result_full) LIKE upper('Positive%') or upper(textual_result_full) LIKE upper('Equivocal%') or upper(textual_result_full) LIKE upper('Reactive%'))) UNION ALL SELECT 
        gtt.*
    FROM GTT_RESULTS_EXTRACT gtt
    WHERE 1=1 AND gtt.order_test_code = '336' AND gtt.result_test_code = '336' AND ((upper(textual_result_full) LIKE upper('Positive%') or upper(textual_result_full) LIKE upper('Equivocal%') or upper(textual_result_full) LIKE upper('Reactive%'))) UNION ALL SELECT 
        gtt.*
    FROM GTT_RESULTS_EXTRACT gtt
    WHERE 1=1 AND gtt.order_test_code = '311' AND ((upper(textual_result_full) LIKE upper('%'))) UNION ALL SELECT 
        gtt.*
    FROM GTT_RESULTS_EXTRACT gtt
    WHERE 1=1 AND gtt.order_test_code = '318' AND gtt.result_test_code = '318L' AND ((upper(textual_result_full) LIKE upper('%'))) UNION ALL SELECT 
        gtt.*
    FROM GTT_RESULTS_EXTRACT gtt
    WHERE 1=1 AND gtt.order_test_code = '318' AND gtt.result_test_code = '318R' AND ((upper(textual_result_full) LIKE upper('%'))) UNION ALL SELECT 
        gtt.*
    FROM GTT_RESULTS_EXTRACT gtt
    WHERE 1=1 AND gtt.order_test_code = '310' AND gtt.result_test_code = '310A' AND ((gtt.value_type = 'NM' and gtt.numeric_result > 0.00)))
    where order_test_code = '310'
    group by order_number,order_test_code
    having count(1) < 2;
                        
/
SELECT order_number,result_test_code,value_type,textual_result_full,numeric_result FROM (SELECT 
        gtt.*
    FROM GTT_RESULTS_EXTRACT_TEST gtt
    WHERE 1=1 AND gtt.order_test_code = '301' AND gtt.result_test_code = '301' AND ((upper(result_comments) LIKE upper('%Newly confirmed Positive%') or upper(result_comments) LIKE upper('%New positive%'))) UNION ALL SELECT 
        gtt.*
    FROM GTT_RESULTS_EXTRACT_TEST gtt
    WHERE 1=1 AND gtt.order_test_code = '318' AND ((upper(textual_result_full) LIKE upper('%'))) UNION ALL SELECT 
        gtt.*
    FROM GTT_RESULTS_EXTRACT_TEST gtt
    WHERE 1=1 AND gtt.order_test_code = '310' AND gtt.result_test_code = '310' AND ((upper(textual_result_full) LIKE upper('Positive%') or upper(textual_result_full) LIKE upper('Equivocal%') or upper(textual_result_full) LIKE upper('Reactive%'))) UNION ALL SELECT 
        gtt.*
    FROM GTT_RESULTS_EXTRACT_TEST gtt
    WHERE 1=1 AND gtt.order_test_code = '311' AND ((upper(textual_result_full) LIKE upper('%'))) UNION ALL SELECT 
        gtt.*
    FROM GTT_RESULTS_EXTRACT_TEST gtt
    WHERE 1=1 AND gtt.order_test_code = '303' AND gtt.result_test_code = '303' AND ((upper(textual_result_full) LIKE upper('Positive%') or upper(textual_result_full) LIKE upper('Equivocal%') or upper(textual_result_full) LIKE upper('Reactive%'))) UNION ALL SELECT 
        gtt.*
    FROM GTT_RESULTS_EXTRACT_TEST gtt
    WHERE 1=1 AND gtt.order_test_code = '304' AND gtt.result_test_code = '304' AND ((upper(textual_result_full) LIKE upper('Positive%') or upper(textual_result_full) LIKE upper('Equivocal%') or upper(textual_result_full) LIKE upper('Reactive%'))) UNION ALL SELECT 
        gtt.*
    FROM GTT_RESULTS_EXTRACT_TEST gtt
    WHERE 1=1 AND gtt.order_test_code = '310' AND gtt.result_test_code = '310A' AND ((gtt.value_type = 'NM' and gtt.numeric_result > 0.00)) UNION ALL SELECT 
        gtt.*
    FROM GTT_RESULTS_EXTRACT_TEST gtt
    WHERE 1=1 AND gtt.order_test_code = '310' AND gtt.result_test_code = '310A' AND ((gtt.value_type = 'ST' and gtt.textual_result_full like '%>11.00%')) UNION ALL SELECT 
        gtt.*
    FROM GTT_RESULTS_EXTRACT_TEST gtt
    WHERE 1=1 AND gtt.order_test_code = '323' AND gtt.result_test_code = '323' AND ((gtt.value_type = 'NM' and gtt.numeric_result >= 135.0)) UNION ALL SELECT 
        gtt.*
    FROM GTT_RESULTS_EXTRACT_TEST gtt
    WHERE 1=1 AND gtt.order_test_code = '317L' AND ((gtt.value_type = 'NM' and gtt.numeric_result >= '25') or (gtt.value_type = 'ST' and regexp_like(gtt.textual_result_full,'>\d{3}'))) UNION ALL SELECT 
        gtt.*
    FROM GTT_RESULTS_EXTRACT_TEST gtt
    WHERE 1=1 AND gtt.order_test_code = '322' AND gtt.result_test_code = '322' AND ((gtt.value_type = 'NM' and gtt.numeric_result >= 9.0)) UNION ALL SELECT 
        gtt.*
    FROM GTT_RESULTS_EXTRACT_TEST gtt
    WHERE 1=1 AND gtt.order_test_code = '315' AND ((gtt.value_type = 'NM' and gtt.numeric_result >= '5') or (gtt.value_type = 'ST' and regexp_like(gtt.textual_result_full,'>\d{3}'))) UNION ALL SELECT 
        gtt.*
    FROM GTT_RESULTS_EXTRACT_TEST gtt
    WHERE 1=1 AND gtt.order_test_code = '332' AND gtt.result_test_code = '332' AND ((upper(textual_result_full) LIKE upper('Positive%') or upper(textual_result_full) LIKE upper('Negative%')))) 
    where patient_account_state = 'OH'
                        ORDER BY accession_number, order_test_code;
                        
/
-- 322 NM filter
SELECT 
        gtt.*
    FROM GTT_RESULTS_EXTRACT_TEST gtt
    WHERE 1=1 AND gtt.order_test_code = '322' AND gtt.result_test_code = '322' AND ((gtt.value_type = 'NM' and gtt.numeric_result >= 9.0));
    
-- 322 ST filter
SELECT 
        gtt.*
    FROM GTT_RESULTS_EXTRACT_TEST gtt
    WHERE 1=1 AND gtt.order_test_code = '322' AND gtt.result_test_code = '322' AND ((gtt.value_type = 'ST' and gtt.numeric_result >= 9.0))

/


                        
/

select * from asr_process_run_20250819_LF
where complete = 'N'
and order_test_code='315';

update asr_process_run_20250819_LF
set complete = 'L'
where source not in ('OH');

select * from gtt_results_extract
where order_test_code = '317L';

select order_number,result_test_code,value_type from results_sent_log
where last_update_time > sysdate - 1
and regexp_like(patient_account_state,'OH');

create table results_sent_log_oh
as
select * from results_sent_log
where order_number IN
(
'2684ZN4'
,'2684Y64');

delete results_sent_log
where order_number IN
(
'2684ZN4'
,'2684Y64');

SELECT 
        gtt.*
    FROM GTT_RESULTS_EXTRACT_TEST gtt
    WHERE 1=1 AND gtt.order_test_code = '317L'; AND ((gtt.value_type = 'NM' and gtt.numeric_result >= '25') or (gtt.value_type = 'ST' and regexp_like(gtt.textual_result_full,'>\d{3}')));