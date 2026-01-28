declare v_qualitative varchar2(128);

begin

    
    
    for state_master IN (select state_master_pk,state_abbreviation,state from state_master s
        where regexp_like(state_abbreviation,'^([A-Z]{2})$')
        and entity_type = 'Abnormal'
        and status = 'active'
        order by state)
        loop
        for asr_load IN (select asr.*,cm.order_test_code cm_order_test_code,cm.result_test_code cm_result_test_code,cm.condition from asr_process_run asr
            join condition_master cm ON cm.state_fk = state_master.state_master_pk and cm.result_test_code = asr.result_test_code
            where complete = 'L'
            and cm.result_test_code = '301'
            and source = state_master.state_abbreviation)
            loop
                if(regexp_like(asr_load.condition,'Newly Confirmed','i')) then
--                dbms_output.put_line(asr_load.source || 
--                    chr(9) || asr_load.order_test_code ||
--                    chr(9) || asr_load.result_test_code ||
--                    chr(9) || asr_load.condition 
--                    );
                    if(not regexp_like(asr_load.textual_result_full,'Positive|Equivocal','i')
                        and asr_load.source not IN ('IL')) then
                        update asr_process_run
                        set complete = 'F'
                        where order_number = asr_load.order_number
                        and result_test_code = asr_load.result_test_code;
                    end if;
                else
                    dbms_output.put_line(asr_load.order_test_code || ' Not Filtered');
                end if;
            end loop;
            
            -- 310 Filtering
            for asr_load IN (select asr.* from asr_process_run asr
            
                where complete = 'L'
                and order_test_code = '310'
                and source = state_master.state_abbreviation
                order by order_number,asr.result_test_code)
            loop
                
                if(regexp_like(asr_load.result_test_code,'^(310)$','i')) then
--                dbms_output.put_line(asr_load.source || 
--                    chr(9) || asr_load.order_test_code ||
--                    chr(9) || asr_load.result_test_code ||
--                    chr(9) || asr_load.condition 
--                    );

--                    begin
--                        select textual_result_full into v_qualitative from asr_process_run
--                        where order_number = asr_load.order_number
--                        and result_test_code = asr_load.result_test_code;
--                        
--                        exception
--                        when others then dbms_output.put_line('No data found');
--                    end;
                    dbms_output.put_line('Result ' || asr_load.textual_result_full);
                    if(regexp_like(asr_load.textual_result_full,'Nonreactive','i')
                        ) then
                        
                        dbms_output.put_line('Update 310');
                        update asr_process_run
                        set complete = 'F'
                        where order_number = asr_load.order_number
                        and order_test_code = asr_load.order_test_code;
                 
                       
                    end if;
                
                else
                    dbms_output.put_line(asr_load.order_test_code || ' Not Filtered');
                end if;
            end loop;
            
            
        
        end loop;
               
  
end;

/

select * from dl_zip_code
where regexp_like(state,'american','i');

select state_master_pk,state_abbreviation,state from state_master s
where regexp_like(state_abbreviation,'^([A-Z]{2})$')
and entity_type = 'Abnormal'
and status = 'active'
order by state;

select state_abbreviation,cm.* from condition_master cm
join
(select s.state_master_pk,s.state_abbreviation,s.state from state_master s
where regexp_like(state_abbreviation,'^([A-Z]{2})$')
and entity_type = 'Abnormal'
and status = 'active') t1 ON t1.state_master_pk = cm.state_fk
where cm.order_test_code = '310'
order by state;