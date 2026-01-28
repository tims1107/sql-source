declare p_out number;

begin

    SP_ASR_PROC_TRACK_RESULTS('TX',p_out);
    
    dbms_output.put_line('Count: ' || p_out);
end;

/

select * from asr_process_run
where activitydate = '20-AUG-25';

update asr_process_run
set complete = 'N'
where activitydate = '20-AUG-25'
and complete = 'L';

select
                            proc.*
                          from
                            asr_process_run_20250819_LF proc
                            join IH_DW.DW_ODS_ACTIVITY act on act.requisition_id = proc.order_number
                            JOIN IH_DW.RESULTS r ON r.requisition_id = proc.order_number and r.result_test_code = proc.result_test_code
                            and complete = 'N';
                            
select * from                             

select patient_account_state from gtt_results_extract
where accession_number = '066464Y48';

drop table gtt_results_extract_test;

create table gtt_results_extract_test
as
select * from gtt_results_extract;

/

insert into results_sent_log
select * from results_sent_log_oh;

select activitydate,complete,count(1) from asr_process_run_20250819_LF
group by activitydate,complete;

select * from asr_process_run_20250819_LF;
select * from gtt_results_extract_test;
where source = 'OH'
and regexp_like(result_test_code,'^(315|317L|322|323|327)$');

select result_test_code,patient_account_state from gtt_results_extract
order by result_test_code;

select ir.value_type,ir.requisition_id,ir.result_test_code,ir.textual_result_full,numeric_result from asr_process_run r
join ih_dw.results ir ON ir.requisition_id = r.order_number and ir.result_test_code = r.result_test_code
where activitydate='19-AUG-25'
and regexp_like(r.result_test_code,'^(315|317L|322|323|327|311L|311R)$')
and source = 'OH'
and complete='R';

select cm.*,cf.filter from condition_master cm
join condition_filters cf ON cf.condition_filter_pk = cm.condition_filter_fk
where state_fk = 62
and regexp_like(order_test_code,'^(322)');


Insert into CONDITION_MASTER (CONDITION_MASTER_PK,STATE_FK,CONDITION_FILTER_FK,ORDER_TEST_CODE,RESULT_TEST_CODE,CONDITION,VALUE_TYPE,CONDITION_VALUE,STATUS,CREATED_DATE,CREATED_BY,LAST_UPDATED_DATE,LAST_UPDATED_BY) 
values 
((select max(condition_master_pk) + 1 from condition_master),62,39,'322',322,'ST or NM','NM','9','active',systimestamp,'ASR_ADMIN_UPDATE',NULL,NULL);


delete condition_master
where condition_master_pk = 1688;