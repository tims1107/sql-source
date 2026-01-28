select * from asr_process_run
where activitydate = '03-SEP-25'
and complete = 'R'
and source = 'NC';

create table asr_process_NC_20250903
as
select * from asr_process_run
where complete IN ('R')
and source= 'NC'
and activitydate = '03-SEP-25'
--and order_test_code not in ('301')
order by result_test_code,order_number;

select * from asr_process_NC_20250903;

update asr_process_run
set complete = 'N'
where (order_number,result_test_code) IN
(select order_number,result_test_code from asr_process_NC_20250903);

select * from asr_process_NC_20250903;

delete asr_process_run
where (order_number,result_test_code) IN
(select order_number,result_test_code from asr_process_run 
where complete = 'N'
);

create table results_sent_log_NC_20250903
as
select * from results_sent_log
where (order_number,result_test_code) IN
(select order_number,result_test_code from asr_process_NC_20250903);

delete results_sent_log
where (order_number,result_test_code) IN
(select order_number,result_test_code from asr_process_NC_20250903);

select source,order_number,result_test_code from asr_process_run
where complete = 'D'
and activitydate = trunc(sysdate -1 )
group by order_number,source,result_test_code
order by source,result_test_code;

select 


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