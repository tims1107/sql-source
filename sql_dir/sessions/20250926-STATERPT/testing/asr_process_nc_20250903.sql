select * from asr_process_run
where activitydate = '19-SEP-25'
--and complete IN ('N')
and not regexp_like(order_test_code,'^(317L|315|322|323|327)$')
and source = 'NC';

delete asr_process_NC_20250919
where order_test_code = '336';

select * from asr_process_NC_20250919;

create table asr_process_NC_20250919
as
select * from asr_process_run
where activitydate = '19-SEP-25'
--and complete IN ('N')
and not regexp_like(order_test_code,'^(317L|315|322|323|327)$')
and source = 'NC'
order by activitydate,order_number;

create table asr_process_NC_20250912
as
select * from asr_process_run
where activitydate IN ('12-SEP-25','13-SEP-25','14-SEP-25','15-SEP-25','16-SEP-25','17-SEP-25','18-SEP-25')
and complete IN ('N','R','S')
and not regexp_like(order_test_code,'^(317L|315|322)$')
and source = 'NC'
order by activitydate,order_number;



create table asr_process_NC_20250918
as
select * from asr_process_run
where activitydate = '18-SEP-25'
and complete IN ('R','S')
and not regexp_like(order_test_code,'^(317L|315|322)$')
and source = 'NC';

select * from asr_process_NC_20250912;

update asr_process_run
set complete = 'R'
where (order_number,result_test_code) IN
(select order_number,result_test_code from asr_process_NC_20250919);

update asr_process_run
set complete = 'R'
where (order_number,result_test_code) IN
(select order_number,result_test_code from asr_process_NC_20250912)
and order_test_code not IN ('332');

update asr_process_run
set complete = 'S'
where (order_number,result_test_code) IN
(select order_number,result_test_code from asr_process_NC_20250912)
and order_test_code IN ('332');

select * from asr_process_NC_20250903;

delete asr_process_run
where (order_number,result_test_code) IN
(select order_number,result_test_code from asr_process_run 
where complete = 'N'
);

create table results_sent_log_NC_20250919
as
select * from results_sent_log
where (order_number,result_test_code) IN
(select order_number,result_test_code from asr_process_NC_20250919);

delete results_sent_log
where (order_number,result_test_code) IN
(select order_number,result_test_code from asr_process_NC_20250919);

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