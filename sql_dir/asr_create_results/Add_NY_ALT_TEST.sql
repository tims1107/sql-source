-- Add_NY_ALT_TEST
begin


for nyrec IN (select * from asr_process_run
  where result_test_code = '111' 
  and complete IN ('D','N')
  and to_date(activitydate,'dd-MON-yy') = trunc(sysdate - 1))
  loop
  
  --dbms_output.put_line(nyrec.order_number || chr(9) || nyrec.activitydate);
  
  update asr_process_run
  set complete = 'D'
  where order_number = nyrec.order_number
  and result_test_code = '111';
  
  commit;
  
  --dbms_output.put_line(nyrec.order_number || chr(9) || nyrec.result_test_code || chr(9) || nyrec.activitydate);
  for orders IN (select * from asr_process_run 
    where order_number = nyrec.order_number
    and regexp_like(order_test_code,'^301|^310|^308|^311|^318|^303|^304')
    and source = 'NY'
    and complete IN ('N')
    and activitydate = to_char(sysdate - 1,'dd-MON-yy'))
    loop
   begin
      dbms_output.put_line(nyrec.order_number || chr(9) || nyrec.result_test_code || chr(9) || nyrec.activitydate);
      dbms_output.put_line(orders.result_test_code || chr(9) || orders.complete);
      
      update asr_process_run
      set complete = 'N'
        ,activitydate = to_char(sysdate - 1 ,'dd-MON-yy')
      where order_test_code = '111' 
        and order_number = orders.order_number
        and complete = 'D'
        and source = orders.source;
        
        dbms_output.put_line('Updated compete to N');
        
        Exception
        When others then dbms_output.put_line(sqlerrm);
      end;
      
    end loop;
  
  
  end loop;
  
  
  
end;

/
-- commit 111 ALT

commit;

/

set serveroutput on

select * from asr_process_run
where activitydate = '25-MAY-24'
and source = 'NY'
and complete = 'R';

update asr_process_run
set complete = 'Q'
where complete = 'N'
and patient_last_name like 'VM%'
and source IN ('PR','MS')
and activitydate = '08-JUN-24';



and result_test_code = '332';
where complete = 'N'

and source IN ('MD','','TX');

update asr_process_run
set complete = 'T'
where activitydate = '24-MAY-24'
and regexp_like(patient_last_name,'\d{4}');

