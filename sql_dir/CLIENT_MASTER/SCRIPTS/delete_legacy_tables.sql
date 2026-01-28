declare
  row_count NUMBER;

begin
  delete legacy_clinic;
  row_count := SQL%ROWCOUNT;
  
  dbms_output.put_line(row_count);
  
  if(row_count > 0) then
  commit;
  end if;
  
  delete plac_printer_load;
  
  row_count := SQL%ROWCOUNT;
  dbms_output.put_line(row_count);
  
  if(row_count > 0) then
  commit;
  end if;
  
   delete clinic_open_close;
  
  row_count := SQL%ROWCOUNT;
  dbms_output.put_line(row_count);
  
  if(row_count > 0) then
  commit;
  end if;
  
end;