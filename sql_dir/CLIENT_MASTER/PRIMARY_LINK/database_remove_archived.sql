-- Remove
declare 
  v_drawweekid number;
  v_commentid number;
  ddl_qry varchar2(4000) := '';
  
  v_deleted varchar2(32) := 'X1'; -- delete series tables

begin

  
      execute immediate 'delete clinic_draw_days where clinicdrawweekid = ' || draw.clinicdrawweekid;
      dbms_output.put_line('Records inserted: ' || sql%rowcount);
      
      
    end loop;
    
    -- clinic_draw_week where clinicid = ' || rec.id
        
    dbms_output.put_line('insert into clinic_draw_week_' || v_deleted || ' select * from clinic_draw_week where clinicid = ' || rec.id);
    execute immediate 'insert into clinic_draw_week_' || v_deleted || ' select * from clinic_draw_week where clinicid = ' || rec.id;
    dbms_output.put_line('Records inserted: ' || sql%rowcount);  

    -- clinic_supply where clinicid = ' || rec.id 
    dbms_output.put_line('insert into clinic_supply_' || v_deleted || ' select * from clinic_supply where clinicid = ' || rec.id);
    execute immediate 'insert into clinic_supply_' || v_deleted || ' select * from clinic_supply where clinicid = ' || rec.id;
    dbms_output.put_line('Records inserted: ' || sql%rowcount);
    
    -- clinic_prioritylist
    dbms_output.put_line('insert into clinic_prioritylist_' || v_deleted || ' select * from clinic_prioritylist where clinicid = ' || rec.id);
    execute immediate 'insert into clinic_prioritylist_' || v_deleted || ' select * from clinic_prioritylist where clinicid = ' || rec.id;
    dbms_output.put_line('Records inserted: ' || sql%rowcount);
    
    -- clinic_printer where clinicid = ' || rec.id
    dbms_output.put_line('insert into clinic_printer_' || v_deleted || ' select * from clinic_printer where clinicid = ' || rec.id);
    execute immediate'insert into clinic_printer_' || v_deleted || ' select * from clinic_printer where clinicid = ' || rec.id;
    dbms_output.put_line('Records inserted: ' || sql%rowcount);
    
    -- clinic_modality where clinicid = ' || rec.id
    dbms_output.put_line('insert into clinic_modality_' || v_deleted || ' select * from clinic_modality where clinicid = ' || rec.id);
    execute immediate 'insert into clinic_modality_' || v_deleted || ' select * from clinic_modality where clinicid = ' || rec.id;
    dbms_output.put_line('Records inserted: ' || sql%rowcount);
    
    
    -- clinic_hcsuppress where clinicid = ' || rec.id
    dbms_output.put_line('insert into clinic_hcsuppress_' || v_deleted || ' select * from clinic_hcsuppress where clinicid = ' || rec.id);
    execute immediate 'insert into clinic_hcsuppress_' || v_deleted || ' select * from clinic_hcsuppress where clinicid = ' || rec.id;
    dbms_output.put_line('Records inserted: ' || sql%rowcount);
    
    -- clinic_facility_manager
    dbms_output.put_line('insert into clinic_facility_manager_' || v_deleted || ' select * from clinic_facility_manager where clinicid = ' || rec.id);
    execute immediate 'insert into clinic_facility_manager_' || v_deleted || ' select * from clinic_facility_manager where clinicid = ' || rec.id;
    dbms_output.put_line('Records inserted: ' || sql%rowcount);
   
    -- clinic_page_notes
    for com IN (select * from clinic_comments
      where clinic_id = rec.id)
    loop
        dbms_output.put_line('insert into clinic_page_notes_' || v_deleted || ' select * from clinic_page_notes where comment_id = ' || com.comment_id);
        execute immediate 'insert into clinic_page_notes_' || v_deleted || ' select * from clinic_page_notes where comment_id = ' || com.comment_id;
        dbms_output.put_line('Records inserted: ' || sql%rowcount); 
    end loop;

    -- clinic_comments
    dbms_output.put_line('insert into clinic_comments_' || v_deleted || ' select * from clinic_comments where clinic_id = ' || rec.id);
    execute immediate 'insert into clinic_comments_' || v_deleted || ' select * from clinic_comments where clinic_id = ' || rec.id;
    dbms_output.put_line('Records inserted: ' || sql%rowcount);
    
    -- clinic_add_info
    dbms_output.put_line('insert into clinic_add_info_' || v_deleted || ' select * from clinic_add_info where clinicid = ' || rec.id);
    execute immediate 'insert into clinic_add_info_' || v_deleted || ' select * from clinic_add_info where clinicid = ' || rec.id;
    dbms_output.put_line('Records inserted: ' || sql%rowcount);
    
    -- clinic_courier
    dbms_output.put_line('insert into clinic_courier_' || v_deleted || ' select * from clinic_courier where clinicid = ' || rec.id);
    execute immediate 'insert into clinic_courier_' || v_deleted || ' select * from clinic_courier where clinicid = ' || rec.id;
    dbms_output.put_line('Records inserted: ' || sql%rowcount);
    
    -- clinic_cohort
    dbms_output.put_line('insert into clinic_cohort_' || v_deleted || ' select * from clinic_cohort where clinicid = ' || rec.id);
    execute immediate 'insert into clinic_cohort_' || v_deleted || ' select * from clinic_cohort where clinicid = ' || rec.id;
    dbms_output.put_line('Records inserted: ' || sql%rowcount);
    
    -- clinic_ah_seqno
    dbms_output.put_line('insert into clinic_ah_seqno_' || v_deleted || ' select * from clinic_ah_seqno where clinicid = ' || rec.id);
    execute immediate 'insert into clinic_ah_seqno_' || v_deleted || ' select * from clinic_ah_seqno where clinicid = ' || rec.id;
    dbms_output.put_line('Records inserted: ' || sql%rowcount);
    
    -- clinic_after_hours
    dbms_output.put_line('insert into clinic_after_hours_' || v_deleted || ' select * from clinic_after_hours where clinicid = ' || rec.id);
    execute immediate 'insert into clinic_after_hours_' || v_deleted || ' select * from clinic_after_hours where clinicid = ' || rec.id;
    dbms_output.put_line('Records inserted: ' || sql%rowcount);
    
    -- clinic_detail
    dbms_output.put_line('insert into clinic_detail_' || v_deleted || ' select * from clinic_detail where clinic_id = ' || rec.id);
    execute immediate 'insert into clinic_detail_' || v_deleted || ' select * from clinic_detail where clinic_id = ' || rec.id;
    dbms_output.put_line('Records inserted: ' || sql%rowcount);
    
    -- clinic
    dbms_output.put_line('insert into clinic_' || v_deleted || ' select * from clinic where id = ' || rec.id);
    execute immediate 'insert into clinic_' || v_deleted || ' select * from clinic where id = ' || rec.id;
    dbms_output.put_line('Records inserted: ' || sql%rowcount);


  
  end loop;
  
  exception
  when others then dbms_output.put_line(sqlerrm); 

end;

/


    
begin
  
    
  
  for dd IN (select * from clinic_draw_days_X1)
  loop
    dbms_output.put_line(dd.clinicdrawdayid);
    execute IMMEDIATE 'delete clinic_draw_days where clinicdrawdayid = ' || dd.clinicdrawdayid;
    dbms_output.put_line(dd.clinicdrawdayid || ' ' || sql%rowcount);
  end loop;
  
  for dd IN (select * from clinic_draw_days_X1)
  loop
    dbms_output.put_line(dd.clinicdrawdayid);
    execute IMMEDIATE 'insert into clinic_draw_days select * from clinic_draw_days_X1 where clinicdrawdayid = ' || dd.clinicdrawdayid;
    dbms_output.put_line(dd.clinicdrawdayid || ' ' || sql%rowcount);
  end loop;
  


end;

/
select * from clinic_draw_days where clinicdrawdayid 
IN (select clinicdrawdayid from clinic_draw_days_X1);

delete clinic_draw_days where clinicdrawdayid 
IN (select clinicdrawdayid from clinic_draw_days_X1);

/

begin


end;

select * from clinic_prioritylist where clinicid = 526923;

select * from clinic_after_hours where clinicid = 526923;

select * from clinic_supply;

select * from clinic_draw_days where clinicdrawweekid = 93390;

select * from clinic_comments where clinic_id = 526923;

select * from clinic_page_notes where comment_id = 505102;

drop table clinic_draw_days_20240304;

select * from clinic_draw_days where clinicdrawweekid = 93390;

select * from clinic_draw_days_20240304  where clinicdrawweekid = 93390;