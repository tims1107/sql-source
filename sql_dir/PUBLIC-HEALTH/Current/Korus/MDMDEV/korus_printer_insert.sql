

declare 
    v_rec_limit number := 100;
    v_rec_count number := 0;
    v_insert_count number := 0;
    v_update_count number := 0;
    v_delete_count number := 0;
    v_printer_type number;
    v_exists number;
begin
    -- First, mark all existing clinic_printer records for potential deletion
    update clinic_printer set STATUS = 0 where PRINTERTYPEID IN (1,2);
    
    -- Process each record from korus_printer with Laser or Zebra printer types
    for kp_rec in (
        select kp.ID, kp.HLAB_NUM, kp.FMC_NUMBER, kp.INTERNAL_EXTERNAL_FLAG, 
               kp.PRINTER_NAME, kp.IP_ADDRESS, kp.PRINTER_TYPE,
               c.id as clinicid
        from korus_printer kp
        join clinic c ON c.hlabnumber = kp.HLAB_NUM
        where kp.PRINTER_NAME IS NOT NULL
        and kp.HLAB_NUM IS NOT NULL
        and kp.PRINTER_TYPE IN ('Zebra', 'Laser')
    ) loop
        -- Determine printer type ID based on korus_printer.PRINTER_TYPE
        if kp_rec.PRINTER_TYPE = 'Zebra' then
            v_printer_type := 1;
        elsif kp_rec.PRINTER_TYPE = 'Laser' then
            v_printer_type := 2;
        end if;
        
        -- Check if record exists in clinic_printer
        select count(*) into v_exists
        from clinic_printer cp
        where PRINTERNAME = kp_rec.PRINTER_NAME
        and CLINICID = kp_rec.clinicid;
        
        if v_exists > 0 then
            -- Record exists, update it
            update clinic_printer
            set PRINTERIP = kp_rec.IP_ADDRESS,
                PRINTERTYPEID = v_printer_type,
                STATUS = 1  -- Mark as active/processed
            where PRINTERNAME = kp_rec.PRINTER_NAME
            and CLINICID = kp_rec.clinicid;
            
            v_update_count := v_update_count + 1;
            
            if v_rec_count <= v_rec_limit then
                dbms_output.put_line('Updated: ' || kp_rec.PRINTER_NAME || 
                                    ' (' || kp_rec.PRINTER_TYPE || ') at clinic ID ' || 
                                    kp_rec.clinicid);
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
            
            if v_rec_count <= v_rec_limit then
                dbms_output.put_line('Inserted: ' || kp_rec.PRINTER_NAME || 
                                    ' (' || kp_rec.PRINTER_TYPE || ') at clinic ID ' || 
                                    kp_rec.clinicid);
            end if;
        end if;
        
        v_rec_count := v_rec_count + 1;
        
        -- Commit every 100 records to avoid large transactions
        if mod(v_rec_count, 100) = 0 then
            commit;
            dbms_output.put_line('Processed ' || v_rec_count || ' records so far');
        end if;
    end loop;
    
    -- Delete records that weren't updated (still have STATUS = 0)
    delete from clinic_printer where STATUS = 0 and PRINTERTYPEID IN (1,2);
    v_delete_count := SQL%ROWCOUNT;
    
    -- Final commit for any remaining records
    commit;
    
    -- Print summary
    dbms_output.put_line('Total records processed: ' || v_rec_count);
    dbms_output.put_line('Records inserted: ' || v_insert_count);
    dbms_output.put_line('Records updated: ' || v_update_count);
    dbms_output.put_line('Records deleted: ' || v_delete_count);
end;
/

-- Verify results
select count(*) from clinic_printer where PRINTERTYPEID IN (1,2);

/
declare 
    v_rec_limit number := 100;
    v_rec_count number := 0;
    v_insert_count number := 0;
    v_printer_type number;
begin
    -- Process each record from korus_printer with Laser or Zebra printer types
    for kp_rec in (
        select kp.ID, kp.HLAB_NUM, kp.FMC_NUMBER, kp.INTERNAL_EXTERNAL_FLAG, 
               kp.PRINTER_NAME, kp.IP_ADDRESS, kp.PRINTER_TYPE,
               c.id as clinicid
        from korus_printer kp
        join clinic c ON c.hlabnumber = kp.HLAB_NUM
        where kp.PRINTER_NAME IS NOT NULL
        and kp.HLAB_NUM IS NOT NULL
        and kp.PRINTER_TYPE IN ('Zebra', 'Laser')
    ) loop
        -- Determine printer type ID based on korus_printer.PRINTER_TYPE
        if kp_rec.PRINTER_TYPE = 'Zebra' then
            v_printer_type := 1;
        elsif kp_rec.PRINTER_TYPE = 'Laser' then
            v_printer_type := 2;
        end if;
        
        -- Insert record into clinic_printer
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
        v_rec_count := v_rec_count + 1;
        
        -- Optional: Display progress for first few records
        if v_rec_count <= v_rec_limit then
            dbms_output.put_line('Inserted: ' || kp_rec.PRINTER_NAME || 
                                ' (' || kp_rec.PRINTER_TYPE || ') at clinic ID ' || 
                                kp_rec.clinicid);
        end if;
        
        -- Commit every 100 records to avoid large transactions
        if mod(v_rec_count, 100) = 0 then
            commit;
            dbms_output.put_line('Committed ' || v_rec_count || ' records so far');
        end if;
    end loop;
    
    -- Final commit for any remaining records
    commit;
    
    -- Print summary
    dbms_output.put_line('Total records processed: ' || v_rec_count);
    dbms_output.put_line('Records inserted: ' || v_insert_count);
end;
/

select * from clinic_printer
where printertypeid IN (1,2);

delete korus_printer
where hlab_num IN
(select hlabnumber from clinic
where id in (542764,542765));

-- Verify results
select count(*) from clinic_printer where PRINTERTYPEID IN (1,2);

/

delete clinic_printer 
where printertypeid in (1,2);

select * from clinic_printer
where printertypeid IN (1,2);