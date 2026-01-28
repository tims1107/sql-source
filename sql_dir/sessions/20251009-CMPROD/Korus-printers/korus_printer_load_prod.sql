select printer_type ,count(1) from korus_printer
group by printer_type;

select printertypeid,count(1) from clinic_printer
where printertypeid IN (1,2)
group by printertypeid;
where clinicid = 204746;

select * from clinic_printer
where printertypeid IN (1,2);

drop table korus_printer;

select * from korus_printer;

select * from printer_type;

delete clinic_printer
where printertypeid IN (1,2);

/

begin

    for rec IN (select * from 
        (select c.id,
        kp.hlab_num,
        kp.fmc_number,
        kp.printer_name,
        kp.ip_address,
        case kp.printer_type
        when 'Zebra' then 2
        when 'Laser' then 1 else 0 end printertypeid from korus_printer kp
        join clinic c ON c.hlabnumber = kp.hlab_num)
        )
        
        loop
        
        begin
        Insert into CLINIC_PRINTER (CLINICPRINTERID,CLINICID,PRINTERNAME,PRINTERIP,PRINTERTYPEID,PRINTERFAX,ALERTFAX,STATUS,CREATEDAT,CREATEDBY) 
        values (CLINIC_PRINTER_SEQ.nextval,rec.id,rec.printer_name,rec.ip_address,rec.printertypeid,null,null,1,systimestamp,'KORUS');
        
        Exception
        When others then dbms_output.put_line(sqlerrm);
        
        end;
        
        end loop;

 


end;