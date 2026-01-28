-- Remove clinics completely from oracle database
declare 
  v_drawweekid number;
  v_commentid number;
  ddl_qry varchar2(4000) := '';
  v_count number := 0;
  
  v_deleted varchar2(32) := 'CM2_0828'; -- delete series tables

begin

      -- clinic_draw_days
      begin
      
        ddl_qry := 'create table clinic_draw_days_' || v_deleted || ' as select * from clinic_draw_days where rownum < ' || 2;
        dbms_output.put_line(ddl_qry);
        
        execute immediate ddl_qry;
                       
        exception
        when others then dbms_output.put_line(sqlerrm);
        
      end;

    
    -- clinic_draw_week 
    begin
        ddl_qry := 'create table clinic_draw_week_' || v_deleted || ' as select * from clinic_draw_week where rownum < ' || 2;
        dbms_output.put_line(ddl_qry);
        
        execute immediate ddl_qry;
        
                
        exception
        when others then dbms_output.put_line(sqlerrm);
    end;
    
    -- clinic_supply 
    begin
        ddl_qry := 'create table clinic_supply_' || v_deleted || ' as select * from clinic_supply where rownum < ' || 2;
        dbms_output.put_line(ddl_qry);
        
        execute immediate ddl_qry;
        
                
        exception
        when others then dbms_output.put_line(sqlerrm);
    end;
    
    -- clinic_modality
    begin
        ddl_qry := 'create table clinic_modality_' || v_deleted || ' as select * from clinic_modality where rownum < ' || 2;
        dbms_output.put_line(ddl_qry);
        
        execute immediate ddl_qry;
        
                
        exception
        when others then dbms_output.put_line(sqlerrm);
    end;
    
    -- clinic_printer 
    begin
        ddl_qry := 'create table clinic_printer_' || v_deleted || ' as select * from clinic_printer where rownum < ' || 2;
        dbms_output.put_line(ddl_qry);
        
        execute immediate ddl_qry;
        
                
        exception
        when others then dbms_output.put_line(sqlerrm);
    end;
    
    -- clinic_hcsuppress where clinicid = ' || rec.id
    begin
        ddl_qry := 'create table clinic_hcsuppress_' || v_deleted || ' as select * from clinic_hcsuppress where rownum < ' || 2;
        dbms_output.put_line(ddl_qry);
        
        execute immediate ddl_qry;
        
        
        
        exception
        when others then dbms_output.put_line(sqlerrm);
    end;
    
    -- clinic_prioritylist
    begin
        ddl_qry := 'create table clinic_prioritylist_' || v_deleted || ' as select * from clinic_prioritylist where rownum < ' || 2;
        dbms_output.put_line(ddl_qry);
        
        execute immediate ddl_qry;
        
                
        exception
        when others then dbms_output.put_line(sqlerrm);
    end;
    -- clinic_facility_manager
    begin
        ddl_qry := 'create table clinic_fac_mgr_' || v_deleted || ' as select * from clinic_facility_manager where rownum < ' || 2;
        dbms_output.put_line(ddl_qry);
        
        execute immediate ddl_qry;
        
                
        exception
        when others then dbms_output.put_line(sqlerrm);
    end;

    
    -- delete clinic_page_notes where comment_id = ' || com.comment_id;
     begin
        ddl_qry := 'create table clinic_page_notes_' || v_deleted || ' as select * from clinic_page_notes where rownum < ' || 2;
        dbms_output.put_line(ddl_qry);
        
        execute immediate ddl_qry;
        
                
        exception
        when others then dbms_output.put_line(sqlerrm);
    end;

    
    -- delete clinic_comments where clinic_id = ' || rec.id;
    begin
        ddl_qry := 'create table clinic_comments_' || v_deleted || ' as select * from clinic_comments where rownum < ' || 2;
        dbms_output.put_line(ddl_qry);
        
        execute immediate ddl_qry;
        
        
        
        exception
        when others then dbms_output.put_line(sqlerrm);
    end;
    
    -- delete clinic_comment_line where clinic_id = ' || rec.id;
    begin
        ddl_qry := 'create table clinic_comment_line_' || v_deleted || ' as select * from clinic_comment_line where rownum < ' || 2;
        dbms_output.put_line(ddl_qry);
        
        execute immediate ddl_qry;
        
        
        
        exception
        when others then dbms_output.put_line(sqlerrm);
    end;
    
    -- clinic_add_info 
     begin
        ddl_qry := 'create table clinic_add_info_' || v_deleted || ' as select * from clinic_add_info where rownum < ' || 2;
        dbms_output.put_line(ddl_qry);
        
        execute immediate ddl_qry;
        
        
        
        exception
        when others then dbms_output.put_line(sqlerrm);
    end;
    
    
    -- clinic_courier
     begin
        ddl_qry := 'create table clinic_courier_' || v_deleted || ' as select * from clinic_courier where rownum < ' || 2;
        dbms_output.put_line(ddl_qry);
        
        execute immediate ddl_qry;
        
               
        exception
        when others then dbms_output.put_line(sqlerrm);
    end;
    
    -- clinic_cohort
     begin
        ddl_qry := 'create table clinic_cohort_' || v_deleted || ' as select * from clinic_cohort where rownum < ' || 2;
        dbms_output.put_line(ddl_qry);
        
        execute immediate ddl_qry;
            
        
        exception
        when others then dbms_output.put_line(sqlerrm);
    end;
    
    -- clinic_ah_seqno
     begin
        ddl_qry := 'create table clinic_ah_seqno_' || v_deleted || ' as select * from clinic_ah_seqno where rownum < ' || 2;
        dbms_output.put_line(ddl_qry);
        
        execute immediate ddl_qry;
        
        
        
        exception
        when others then dbms_output.put_line(sqlerrm);
    end;
    
    -- clinic_after_hours
     begin
        ddl_qry := 'create table clinic_after_hours_' || v_deleted || ' as select * from clinic_after_hours where rownum < ' || 2;
        dbms_output.put_line(ddl_qry);
        
        execute immediate ddl_qry;
        
        
        
        
        
        exception
        when others then dbms_output.put_line(sqlerrm);
    end;
    
    -- clinic_detail
     begin
        ddl_qry := 'create table clinic_detail_' || v_deleted || ' as select * from clinic_detail where rownum < ' || 2;
        dbms_output.put_line(ddl_qry);
        
        execute immediate ddl_qry;
      
        exception
        when others then dbms_output.put_line(sqlerrm);
    end;
    
    -- clinic
    begin
        ddl_qry := 'create table clinic_' || v_deleted || ' as select * from clinic where rownum < ' || 4;
        dbms_output.put_line(ddl_qry);
        
        execute immediate ddl_qry;
        
       
        
        exception
        when others then dbms_output.put_line(sqlerrm);
    end;
    
    v_count := 0;
    for tab IN (select object_name from user_objects where object_type = 'TABLE'
      and regexp_like (object_name,v_deleted))

      loop
        ddl_qry := 'delete from ' || tab.object_name;
        
        dbms_output.put_line(ddl_qry);
        EXECUTE IMMEDIATE ddl_qry;
        --ddl_qry := 'select count(1) ' from ' || tab.object_name;
        --EXECUTE IMMEDIATE ddl_qry;
        
        v_count := sql%rowcount;
        
        dbms_output.put_line(v_count);

    end loop;
    
    commit;

 

end;

/

set serveroutput on;

select * from clinic_20240320_01;

select object_name from user_objects where object_type = 'TABLE'
      and regexp_like (object_name,'CM2');

drop table clinic_draw_days_20240304;

select * from clinic_draw_days where clinicdrawweekid = 93390;

select * from clinic_draw_days_20240304  where clinicdrawweekid = 93390;