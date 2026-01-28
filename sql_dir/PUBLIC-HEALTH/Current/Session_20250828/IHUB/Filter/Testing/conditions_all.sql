SELECT * FROM (SELECT 
        gtt.*
    FROM GTT_RESULTS_EXTRACT gtt
    WHERE 1=1 AND gtt.order_test_code = '301' AND gtt.result_test_code = '301' AND ((upper(result_comments) LIKE upper('%Newly confirmed Positive%') or upper(result_comments) LIKE upper('%New positive%'))) UNION ALL SELECT 
        gtt.*
    FROM GTT_RESULTS_EXTRACT gtt
    WHERE 1=1 AND gtt.order_test_code = '318' AND ((upper(textual_result_full) LIKE upper('%'))) UNION ALL SELECT 
        gtt.*
    FROM GTT_RESULTS_EXTRACT gtt
    WHERE 1=1 AND gtt.order_test_code = '310' AND gtt.result_test_code = '310' AND ((upper(textual_result_full) LIKE upper('Positive%') or upper(textual_result_full) LIKE upper('Equivocal%') or upper(textual_result_full) LIKE upper('Reactive%'))) UNION ALL SELECT 
        gtt.*
    FROM GTT_RESULTS_EXTRACT gtt
    WHERE 1=1 AND gtt.order_test_code = '311' AND ((upper(textual_result_full) LIKE upper('%'))) UNION ALL SELECT 
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
    WHERE 1=1 AND gtt.order_test_code = '332' AND gtt.result_test_code = '332' AND ((upper(textual_result_full) LIKE upper('Positive%') or upper(textual_result_full) LIKE upper('Negative%'))) UNION ALL SELECT 
        gtt.*
    FROM GTT_RESULTS_EXTRACT gtt
    WHERE 1=1 AND gtt.order_test_code = '336' AND gtt.result_test_code = '336' AND ((upper(textual_result_full) LIKE upper('Positive%') or upper(textual_result_full) LIKE upper('Equivocal%') or upper(textual_result_full) LIKE upper('Reactive%'))))
    where reportable_state = 'TX';                   
                        
   -- where order_number = '26937R4'
                        ORDER BY accession_number, order_test_code;
                        
    select * from gtt_results_extract
    where reportable_state = 'AZ';
    where order_number = '2704B04';
    
    select * from asr_process_run
    where complete = 'N';
                        
select TO_NUMBER(REGEXP_SUBSTR(textual_result_full, '[0-9]+(\.[0-9]+)?')) from gtt_results_extract
where result_test_code = '327'
and order_number = '26937R4';

SELECT 
        gtt.*
    FROM GTT_RESULTS_EXTRACT gtt
    WHERE 1=1 AND gtt.order_test_code = '327' AND gtt.result_test_code = '327' AND (TO_NUMBER(REGEXP_SUBSTR(gtt.textual_result_full, '[0-9]+(\.[0-9]+)?')) >= 1) ;
    
    select * from gtt_results_extract
    where  order_number = '26937R4';