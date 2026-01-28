declare p_out number;

begin

    SP_ASR_PROC_TRACK_RESULTS_LF('AL',p_out);
    
    dbms_output.put_line('Count: ' || p_out);
end;

/

create table results_sent_log_20250822
as
select * from results_sent_log
where last_update_time > trunc(sysdate - 1);

create table asr_process_run_20250822_RSQ
as
select * from asr_process_run
where activitydate = '22-AUG-25';

select * from asr_process_run_20250822_RSQ;
select * from results_sent_log_20250822;

select * from asr_process_run
where activitydate = '22-AUG-25'
and complete = 'L';

update asr_process_run
set complete = 'N'
where activitydate = '22-AUG-25';

delete asr_process_run
where activitydate = '22-AUG-25';

delete results_sent_log
where last_update_time > trunc(sysdate - 1);

insert into asr_process_run
select * from asr_process_run_20250822_LF;

select r.order_number,a.order_number,a.complete from results_sent_log_20250822 r
full outer join (select * from asr_process_run_20250822_RSQ
where activitydate = '22-AUG-25'
and complete IN ('R','S')) a ON a.order_number = r.order_number and a.result_test_code = r.result_test_code
where r.order_number is not null;
;

select * from asr_process_run
where order_number = '26937R4';

select * from asr_process_run
where activitydate = '22-AUG-25'
and complete IN ('R','S');

select * from gtt_results_extract
where reportable_state NOT IN 
and source_state = 'patient';

select * from asr_process_run
where source= 'AL'
and activitydate='22-AUG-25'
--and order_test_code = '310'
and complete = 'N'
and order_number IN ('2691XM4','26974A4','26974A4','26974A4','26974A4','26974A4','26974J4','26974J4','26974J4','26974J4','26974J4','2697V34','2697V34','2697V34');
order by order_number;
and complete='N';

select * from gtt_results_extract
where order_number IN ('2691XM4','26974A4','26974A4','26974A4','26974A4','26974A4','26974J4','26974J4','26974J4','26974J4','26974J4','2697V34','2697V34','2697V34');

select * from asr_process_run
where activitydate='22-AUG-25'
and source = 'MD'
and complete IN ('N')
and order_test_code='310'
order by order_number;

/


/

declare v_out number;
    v_count number := 0;
    v_activitydate varchar2(10) := trunc(sysdate - 2);
    v_count number;

begin

    dbms_output.put_line(v_activitydate);

    SP_ASR_PROC_TRACK_RESULTS_LF('MD',v_out);
    
    for gtt IN (select * from asr_process_run
        where source = 'MD' and activitydate=v_activitydate
        and complete = 'N' )
    loop
    
        dbms_output.put_line('GTT order_number: ' || gtt.order_number);
    
    end loop;
    
    for res IN (select order_number,order_test_code,count(1) result_count from asr_process_run
            where activitydate=v_activitydate
            and source = 'MD'
            group by order_number,order_test_code)
        loop
        
        --dbms_output.put_line('outer loop');
            
            for t IN (select * from asr_process_run
                where order_number = res.order_number and order_test_code = res.order_test_code)
            loop
                if(t.result_test_code='310') then
                
                    dbms_output.put_line('Updating ....');
                    
                    update asr_process_run
                    set complete = t.complete
                    where order_number = t.order_number and order_test_code = t.order_test_code;
                    
                    commit;
                end if;
            end loop;
--       
        end loop;

end;



/

declare v_out number;
    v_count number := 0;
    v_activitydate varchar2(10) := trunc(sysdate -2);
    v_state varchar2(2) := null;

begin

    for states IN (select state_abbreviation,state_master_pk  from state_master
                where entity_type = 'Abnormal' and length(state_abbreviation) = 2
                and status = 'active'
                and regexp_like(state_abbreviation,'^([A-Z]{2})$')
                order by state_abbreviation)
    loop
    
        v_state := states.state_abbreviation;
    
        dbms_output.put_line(states.state_abbreviation);
        
        SP_ASR_PROC_TRACK_RESULTS_LF(states.state_abbreviation,v_out);
        
        if(v_count > 0) then
        
            select trunc(release_date_time) into v_activitydate from gtt_results_extract
                where rownum < 2;
        
            dbms_output.put_line(v_activitydate);
        
            sp_filter_states(states.state_master_pk);
            
            for res IN (select order_number,order_test_code,count(1) result_count from asr_process_run
                where activitydate=v_activitydate
                and source = v_state
                group by order_number,order_test_code)
            loop
        
                --dbms_output.put_line('outer loop');
            
                for t IN (select * from asr_process_run
                    where order_number = res.order_number and order_test_code = res.order_test_code)
                loop
                    if(t.result_test_code='310' 
                        and regexp_like(t.textual_result_full,'Nonreactive','i')) then
                    
                        dbms_output.put_line('Updating ....');
                        
--                        update asr_process_run
--                        set complete = 'F'
--                        where order_number = t.order_number and order_test_code = t.order_test_code;
--                        
--                        commit;
                    elsif(t.result_test_code='310A' 
                        and t.complete = 'N') then
                    
                        dbms_output.put_line('Updating ....');
                        
--                        update asr_process_run
--                        set complete = 'F'
--                        where order_number = t.order_number and order_test_code = t.order_test_code;
--                        
--                        commit;
                    end if;
                end loop;
--       
            end loop;
        end if;
        
        
        
        
        
        
    
end;
/

select distinct a.* from asr_process_run a
join
(select order_number,order_test_code,complete from asr_process_run
where activitydate='22-AUG-25'
and order_test_code='310'
group by order_number,order_test_code,complete
having count(1) = 1) t1 ON t1.order_number = a.order_number
where a.order_test_code = '310'
order by a.order_number;


select * from asr_process_run
where complete = 'L';

select patient_account_state from gtt_results_extract;

-- exclude 110,111,113
select * from asr_process_run
where activitydate = '22-AUG-25'
and not regexp_like(source ,'^(GA|IL|MS|NY|RI)$')
and regexp_like(result_test_code,'^(110|111|113)$');

update asr_process_run
set complete = 'F'
where activitydate = '22-AUG-25'
and not regexp_like(source ,'^(GA|IL|MS|NY|RI)$')
and regexp_like(result_test_code,'^(110|111|113)$');


update asr_process_run
set complete = 'N'
where activitydate = '22-AUG-25'
and complete = 'L';

create table asr_process_run_20250822_LF
as
select * from asr_process_run
where activitydate='22-AUG-25';

select * from asr_process_run_20250822_LF;

delete asr_process_run
where activitydate='22-AUG-25';

select
                            proc.*
                          from
                            asr_process_run_20250819_LF proc
                            join IH_DW.DW_ODS_ACTIVITY act on act.requisition_id = proc.order_number
                            JOIN IH_DW.RESULTS r ON r.requisition_id = proc.order_number and r.result_test_code = proc.result_test_code
                            and complete = 'N';
                            
                            

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