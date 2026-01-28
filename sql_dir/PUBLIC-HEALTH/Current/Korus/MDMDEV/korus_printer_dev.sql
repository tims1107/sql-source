declare 
    v_rec_limit number := 100;
    v_rec_count number := 0;
    v_insert_count number := 0;
    v_update_count number := 0;
    v_delete_count number := 0;
    v_exists number;
    v_printer_type number;
begin
    -- Process each record from korus_printer
    for kp_rec in (
        select kp.ID, kp.HLAB_NUM, kp.FMC_NUMBER, kp.INTERNAL_EXTERNAL_FLAG, 
               kp.PRINTER_NAME, kp.IP_ADDRESS, kp.PRINTER_TYPE,
               c.id as clinicid
        from korus_printer kp
        join clinic c ON c.hlabnumber = kp.HLAB_NUM
        where kp.PRINTER_NAME IS NOT NULL
        and kp.HLAB_NUM IS NOT NULL
    ) loop
        -- Determine printer type ID based on korus_printer.PRINTER_TYPE
        if kp_rec.PRINTER_TYPE = 'Zebra' then
            v_printer_type := 1;
        elsif kp_rec.PRINTER_TYPE = 'Laser' then
            v_printer_type := 2;
        else
            v_printer_type := 3;
        end if;
        
        -- Check if record exists in clinic_printer
        select count(*) into v_exists
        from clinic_printer
        where PRINTERNAME = kp_rec.PRINTER_NAME
        and CLINICID = kp_rec.clinicid;
        
        if v_exists > 0 then
            -- Record exists, update it
            update clinic_printer
            set PRINTERIP = kp_rec.IP_ADDRESS,
                PRINTERTYPEID = v_printer_type,
                STATUS = 1
            where PRINTERNAME = kp_rec.PRINTER_NAME
            and CLINICID = kp_rec.clinicid
            and (PRINTERIP != kp_rec.IP_ADDRESS or PRINTERTYPEID != v_printer_type);
            
            if SQL%ROWCOUNT > 0 then
                v_update_count := v_update_count + SQL%ROWCOUNT;
            end if;
        else
            -- Record doesn't exist, insert it
            insert into clinic_printer (
                CLINICPRINTERID, CLINICID, PRINTERNAME, PRINTERIP, PRINTERTYPEID, 
                PRINTERFAX, ALERTFAX, STATUS, CREATEDAT, CREATEDBY
            ) values (
                clinic_printer_seq.NEXTVAL,
                kp_rec.clinicid,
                kp_rec.PRINTER_NAME,
                kp_rec.IP_ADDRESS,
                v_printer_type,
                NULL, -- PRINTERFAX
                NULL, -- ALERTFAX
                1,    -- STATUS (active)
                SYSDATE,
                USER
            );
            
            v_insert_count := v_insert_count + 1;
        end if;
        
        v_rec_count := v_rec_count + 1;
        
        -- Optional: Display progress for first few records
        if v_rec_count <= v_rec_limit then
            dbms_output.put_line('Processing: ' || kp_rec.PRINTER_NAME || ' at clinic ID ' || kp_rec.clinicid);
        end if;
    end loop;
    
    -- Handle deletes: Remove records in clinic_printer that don't exist in korus_printer
    delete from clinic_printer cp
    where cp.PRINTERTYPEID IN (1,2)
    and not exists (
        select 1
        from korus_printer kp
        join clinic c on c.hlabnumber = kp.HLAB_NUM
        where kp.PRINTER_NAME = cp.PRINTERNAME
        and c.id = cp.CLINICID
    );
    
    v_delete_count := SQL%ROWCOUNT;
    
    -- Print summary
    dbms_output.put_line('Total records processed: ' || v_rec_count);
    dbms_output.put_line('Records inserted: ' || v_insert_count);
    dbms_output.put_line('Records updated: ' || v_update_count);
    dbms_output.put_line('Records deleted: ' || v_delete_count);
end;
/

-- Verify results
select count(*) from clinic_printer where PRINTERTYPEID IN (1,2);