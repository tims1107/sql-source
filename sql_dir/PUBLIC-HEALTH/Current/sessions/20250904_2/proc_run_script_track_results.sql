declare v_out number;

begin

SP_ASR_PROC_TRACK_RESULTS_NN('NC',v_out);

end;

/

/
select l.order_number ext_order_number,e.order_number,l.release_date_time,l.result_test_code,l.textual_result_full from gtt_results_extract l
full outer join results_sent_log e ON e.order_number = l.order_number 
    and e.result_test_code = l.result_test_code
where regexp_like(l.result_test_code,'^(301|303|304|310|311|318|332|336|322|315|317L|323|327)$');
and e.order_number is not null;

select order_number from gtt_results_extract
where regexp_like(order_test_code,'^(301|303|304|310|311|318|332|336|322|315|317L|323|327)$');

/

declare v_out number;
    v_count number := 0;
    v_activitydate varchar2(10) := trunc(sysdate -2);
    v_state varchar2(2) := null;

begin

    for states IN (select state_abbreviation,state_master_pk  from state_master
                where entity_type = 'Abnormal' and regexp_like(
                and status = 'active'
                and regexp_like(state_abbreviation,'AZ')
                order by state_abbreviation)
    loop
    
        v_state := states.state_abbreviation;
    
        dbms_output.put_line(states.state_abbreviation);
        
        SP_ASR_PROC_TRACK_RESULTS_LF(states.state_abbreviation,v_out);
        
        if(v_out > 0) then
        
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
                        
                        update asr_process_run
                        set complete = 'F'
                        where order_number = t.order_number and order_test_code = t.order_test_code;
                        
                        commit;
                    elsif(t.result_test_code='310A' 
                        and t.complete = 'N') then
                    
                        dbms_output.put_line('Updating ....');
                        
                        update asr_process_run
                        set complete = 'F'
                        where order_number = t.order_number and order_test_code = t.order_test_code;
                        
                        commit;
                    else
                        update asr_process_run
                        set complete = 'F'
                        where order_number = t.order_number and result_test_code = t.result_test_code
                        and complete= 'N';
                        
                        commit;
                    end if;
                end loop;
--       
            end loop;
        end if;
        
    end loop;
    
end;

/



update asr_process_run
set complete = 'F'
where activitydate='22-AUG-25'
and result_test_code  IN ('110','111','113')
and source NOT IN ('NY');