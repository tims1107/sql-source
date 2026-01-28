-- Remove clinics completely from oracle database
declare 
  v_drawweekid number;
  v_commentid number;
  ddl_qry varchar2(4000) := '';
  
  v_deleted varchar2(32) := '20240320_01'; -- delete series tables

begin

  for rec IN (select * from clinic c
    where id IN (
    526923))
  loop
  
  
    -- clinic_draw_week
    for draw IN (select * from clinic_draw_week
      where clinicid = rec.id)
    loop
    
      
      dbms_output.put_line(rec.hlabnumber || chr(9) || rec.id );
      dbms_output.put_line('insert_into clinic_draw_days_' || v_deleted || ' select * from clinic_draw_days where clinicdrawweekid = ' || draw.clinicdrawweekid);
      --execute immediate 'insert into clinic_draw_days_' || v_deleted || ' select * from clinic_draw_days where clinicdrawweekid = ' || draw.clinicdrawweekid;
      
      
      
    end loop;
    
    -- clinic_draw_week where clinicid = ' || rec.id
        
    dbms_output.put_line('insert_into clinic_draw_week_' || v_deleted || ' select * from clinic_draw_week where clinicid = ' || rec.id);
    --execute immediate 'insert into clinic_draw_week_' || v_deleted || ' select * from clinic_draw_week where clinicid = ' || rec.id;
      

    -- clinic_supply where clinicid = ' || rec.id
    
    dbms_output.put_line(rec.hlabnumber || chr(9) || rec.id);
    dbms_output.put_line('delete clinic_supply where clinicid = ' || rec.id);
    --execute immediate 'delete clinic_supply where clinicid = ' || rec.id;
    
    dbms_output.put_line(rec.hlabnumber || chr(9) || rec.id);
    dbms_output.put_line('delete clinic_prioritylist where clinicid = ' || rec.id);
    --execute immediate 'delete clinic_prioritylist where clinicid = ' || rec.id;
    
    
    -- clinic_printer where clinicid = ' || rec.id
    dbms_output.put_line(rec.hlabnumber || chr(9) || rec.id);
    dbms_output.put_line('delete clinic_printer where clinicid = ' || rec.id);
    --execute immediate'delete clinic_printer where clinicid = ' || rec.id;
    
    
    -- clinic_modality where clinicid = ' || rec.id
    dbms_output.put_line(rec.hlabnumber || chr(9) || rec.id);
    dbms_output.put_line('delete clinic_modality where clinicid = ' || rec.id);
    --execute immediate 'delete clinic_modality where clinicid = ' || rec.id;
    
    
    -- clinic_hcsuppress where clinicid = ' || rec.id
    dbms_output.put_line(rec.hlabnumber || chr(9) || rec.id);
    dbms_output.put_line('delete clinic_hcsuppress where clinicid = ' || rec.id);
    --execute immediate 'delete clinic_hcsuppress where clinicid = ' || rec.id;
    
    
    dbms_output.put_line(rec.hlabnumber || chr(9) || rec.id);
    dbms_output.put_line('delete clinic_facility_manager where clinicid = ' || rec.id);
    --execute immediate 'delete clinic_facility_manager where clinicid = ' || rec.id;

    for com IN (select * from clinic_comments
      where clinic_id = rec.id)
    loop
    
        dbms_output.put_line(rec.hlabnumber || chr(9) || rec.id);
        dbms_output.put_line('delete clinic_page_notes where comment_id = ' || com.comment_id);
        --execute immediate 'delete clinic_page_notes where comment_id = ' || com.comment_id;
        
    end loop;


    dbms_output.put_line(rec.hlabnumber || chr(9) || rec.id);
    dbms_output.put_line('delete clinic_comments where clinic_id = ' || rec.id);
    --execute immediate 'delete clinic_comments where clinic_id = ' || rec.id;
    
    dbms_output.put_line(rec.hlabnumber || chr(9) || rec.id);
    dbms_output.put_line('delete clinic_add_info where clinicid = ' || rec.id);
    --execute immediate 'delete clinic_add_info where clinicid = ' || rec.id;
    
    dbms_output.put_line(rec.hlabnumber || chr(9) || rec.id);
    dbms_output.put_line('delete clinic_courier where clinicid = ' || rec.id);
    --execute immediate 'delete clinic_courier where clinicid = ' || rec.id;
    
    dbms_output.put_line(rec.hlabnumber || chr(9) || rec.id);
    dbms_output.put_line('delete clinic_cohort where clinicid = ' || rec.id);
    --execute immediate 'delete clinic_cohort where clinicid = ' || rec.id;
    
    dbms_output.put_line(rec.hlabnumber || chr(9) || rec.id);
    dbms_output.put_line('delete clinic_ah_seqno where clinicid = ' || rec.id);
    --execute immediate 'delete clinic_ah_seqno where clinicid = ' || rec.id;
    
    dbms_output.put_line(rec.hlabnumber || chr(9) || rec.id);
    dbms_output.put_line('delete clinic_after_hours where clinicid = ' || rec.id);
    --execute immediate 'delete clinic_after_hours where clinicid = ' || rec.id;
    
    dbms_output.put_line(rec.hlabnumber || chr(9) || rec.id);
    dbms_output.put_line('delete clinic_detail where clinic_id = ' || rec.id);
    --execute immediate 'delete clinic_detail where clinic_id = ' || rec.id;
    
    dbms_output.put_line(rec.hlabnumber || chr(9) || rec.id);
    dbms_output.put_line('delete clinic where id = ' || rec.id);
    --execute immediate 'delete clinic where id = ' || rec.id;



  end loop;
  
  for tab IN (select object_name from user_objects where object_type = 'TABLE'
    and regexp_like (object_name,v_deleted))

    loop
      ddl_qry := 'delete from ' || tab.object_name;
      
      dbms_output.put_line(ddl_qry);
      EXECUTE IMMEDIATE ddl_qry;
      v_count := sql%rowcount;
      
      dbms_output.put_line(v_count);
    
    end loop;

 

end;

/

drop table clinic_draw_days_20240304;

select * from clinic_draw_days where clinicdrawweekid = 93390;

select * from clinic_draw_days_20240304  where clinicdrawweekid = 93390;