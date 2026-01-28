select * from asr_process_run
where activitydate = '23-SEP-25'
--and complete IN ('N')
and not regexp_like(order_test_code,'^(317L|315|322|323|327)$')
and source = 'CA';


select * from asr_process_CA_20250923;

select * from asr_process_run
where activitydate = '23-SEP-25'
and complete IN ('N');

create table asr_process_CA_20250923
as
select * from asr_process_run
where activitydate = '23-SEP-25'
--and complete IN ('N')
and not regexp_like(order_test_code,'^(317L|315|322|323|327)$')
and source = 'CA'
order by activitydate,order_number;

update asr_process_run
set complete = 'N'
where (order_number,result_test_code) IN
(select order_number,result_test_code from asr_process_CA_20250923);

update asr_process_run
set complete = 'R'
where (order_number,result_test_code) IN
(select order_number,result_test_code from asr_process_CA_20250923);

-- create results_sent_log backup
create table results_sent_log_CA_20250923
as
select * from results_sent_log
where (order_number,result_test_code) IN
(select order_number,result_test_code from asr_process_CA_20250923);

delete results_sent_log
where (order_number,result_test_code) IN
(select order_number,result_test_code from asr_process_CA_20250923);

update condition_master
set status = 'inactive'
where regexp_like(order_test_code,'^(315|317L|322|323|327)$');



select * from asr_process_run
where activitydate = trunc(sysdate -1)
and order_test_code = '311'
and not regexp_like (source,'^(AL|CA|IL|LA|MD|NC|NJ|NM|NY|OR|PA|TX)$')
and regexp_like(textual_result_full,'^(Not Detected)$')
order by source,order_number;

update asr_process_run
set complete = 'Q'
where (order_number,result_test_code) IN
(select order_number,result_test_code from asr_process_run
where activitydate = trunc(sysdate -1)
and order_test_code = '311'
and not regexp_like (source,'^(AL|CA|IL|LA|MD|NC|NJ|NM|NY|OR|PA|TX)$')
and regexp_like(textual_result_full,'^(Not Detected)$')
and complete = 'N');

delete results_sent_log
where (order_number,result_test_code) IN
(select order_number,result_test_code from asr_process_run
where activitydate = trunc(sysdate -1)
and order_test_code = '311'
and not regexp_like (source,'^(AL|CA|IL|LA|MD|NC|NJ|NM|NY|OR|PA|TX)$')
and regexp_like(textual_result_full,'^(Not Detected)$')
and complete = 'Q');


order by source,order_number;

select result_test_code,textual_result_full from gtt_results_extract
where order_number = '8076B58'
and order_test_code = '310';

update asr_process_run
set complete = 'Q'
where source = 'NC'
and complete = 'N';

delete asr_process_PA_20250919
where complete not in ('R');

create table asr_process_CA_20250919
as
select * from asr_process_run
where activitydate = '19-SEP-25'
--and complete IN ('N')
and not regexp_like(order_test_code,'^(317L|315|322|323|327)$')
and source = 'PA'
order by activitydate,order_number;


update asr_process_run
set complete = 'N'
where (order_number,result_test_code) IN
(select order_number,result_test_code from asr_process_PA_20250919);

update asr_process_run
set complete = 'R'
where (order_number,result_test_code) IN
(select order_number,result_test_code from asr_process_PA_20250919);


create table results_sent_log_PA_20250919
as
select * from results_sent_log
where (order_number,result_test_code) IN
(select order_number,result_test_code from asr_process_PA_20250919);

delete results_sent_log
where (order_number,result_test_code) IN
(select order_number,result_test_code from asr_process_PA_20250919);

select source,order_number,result_test_code from asr_process_run
where complete = 'D'
and activitydate = trunc(sysdate -1 )
group by order_number,source,result_test_code
order by source,result_test_code;

select * from asr_process_run
where complete = 'N';


-- Change NC Context
-- NCHL7GeneratorContext 
-- Old context CAHL7GeneratorContext

select * from generator
where state_fk IN
(select state_master_pk from state_master
where state_abbreviation = 'NC');

update generator
set conversion_context = 'NCHL7GeneratorContext'
where generator_pk = 42;