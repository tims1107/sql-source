
declare v_cnt number := 0;
v_exists number := 0;

begin
   for alt IN ( select * from asr_process_run
    where order_number IN
    (select order_number from asr_process_run
      where result_test_code = '111' 
      and complete IN ('N')
      and source = 'NY'
      and activitydate =  trunc(sysdate - 1)
    ))
    loop
        --dbms_output.put_line('ALT: ' || chr(9)  || alt.order_number || chr(9) || alt.result_test_code);
        
        select count(1) into v_exists from asr_process_run where 
            regexp_like(order_test_code,'^(301|^310|^308|^311|^318|^303|^304|312)$')
            and order_number = alt.order_number
            and complete = 'N';
            if (v_exists > 0) then
            
            dbms_output.put_line(alt.order_number || chr(9) || alt.complete);
            else
                update asr_process_run
                set complete = 'D'
                where order_number = alt.order_number and alt.result_test_code = '111';
                commit;
            end if;
       
        
        
    end loop;
    

end;

/

select result_source,result_test_code,order_number from results_sent_log
where last_update_time > sysdate - .2
order by last_update_time desc;

select r.order_number,r.result_test_code,r.textual_result_full,s.order_number,r.performing_lab_id,source,r.patient_last_name,activitydate from asr_process_run r
left outer join results_sent_log s ON s.order_number = r.order_number and s.result_test_code = r.result_test_code
where activitydate = to_char(sysdate - 1,'dd-MON-yy')
and complete = 'D'
and source = 'NY';

select * from asr_process_run
where order_number = '21110W4';

select * from asr_process_run
where activitydate = '27-MAR-25';


and source = 'CA';
and complete = 'N'
order by order_number;

delete results_sent_log
where order_number = '21110W4';

update asr_process_run
set complete = 'N'
where order_number = '21110W4';