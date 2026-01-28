declare v_count number;
  v_missing number := 0;
  
begin
    for pmcheck IN (select * from il_output_results
        where order_test_code IN
        (select order_test_code from condition_master_test
        where state_fk IN
        (select state_master_pk from state_master
        where state_abbreviation = 'IL')
        and status = 'active'
        and not regexp_like(order_test_code,'^7'))
        --and (textual_result_full = 'Reactive'
        --or textual_result_full = '>11.00')
        order by order_test_code,requisition_id)
    loop
    
        if(pmcheck.state is null) then
            dbms_output.put_line(pmcheck.requisition_id);
            v_missing := v_missing + 1;
--        else
--            dbms_output.put_line(pmcheck.requisition_id);
        end if;
        
    insert into asr_process_run (    
    
    end loop;
    
    
    
    dbms_output.put_line('Missing : ' || v_missing);

end;