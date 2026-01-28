-- Insert that will be removed from table entities to delete log tables for recovery
declare 
  v_drawweekid number;
  v_commentid number;
  ddl_qry varchar2(4000) := '';
  
  v_deleted varchar2(32) := 'CM2_0828'; -- delete series tables

begin

  for rec IN (select * from clinic c
    where id IN (
    select id from CM2_CLEAN_0828))
  loop
  
  
    -- clinic_draw_week
    for draw IN (select * from clinic_draw_week
      where clinicid = rec.id)
    loop
    
      
      --dbms_output.put_line(rec.hlabnumber || chr(9) || rec.id );
      --dbms_output.put_line('insert into clinic_draw_days_' || v_deleted || ' select * from clinic_draw_days where clinicdrawweekid = ' || draw.clinicdrawweekid);
      execute immediate 'insert into clinic_draw_days_' || v_deleted || ' select * from clinic_draw_days where clinicdrawweekid = ' || draw.clinicdrawweekid;
      --dbms_output.put_line('Records inserted: ' || sql%rowcount);
      
      
    end loop;
    
    -- clinic_draw_week where clinicid = ' || rec.id
        
    --dbms_output.put_line('insert into clinic_draw_week_' || v_deleted || ' select * from clinic_draw_week where clinicid = ' || rec.id);
    execute immediate 'insert into clinic_draw_week_' || v_deleted || ' select * from clinic_draw_week where clinicid = ' || rec.id;
    --dbms_output.put_line('Records inserted: ' || sql%rowcount);  

    -- clinic_supply where clinicid = ' || rec.id 
    --dbms_output.put_line('insert into clinic_supply_' || v_deleted || ' select * from clinic_supply where clinicid = ' || rec.id);
    execute immediate 'insert into clinic_supply_' || v_deleted || ' select * from clinic_supply where clinicid = ' || rec.id;
    --dbms_output.put_line('Records inserted: ' || sql%rowcount);
    
    -- clinic_prioritylist
    --dbms_output.put_line('insert into clinic_prioritylist_' || v_deleted || ' select * from clinic_prioritylist where clinicid = ' || rec.id);
    execute immediate 'insert into clinic_prioritylist_' || v_deleted || ' select * from clinic_prioritylist where clinicid = ' || rec.id;
    --dbms_output.put_line('Records inserted: ' || sql%rowcount);
    
    -- clinic_printer where clinicid = ' || rec.id
    --dbms_output.put_line('insert into clinic_printer_' || v_deleted || ' select * from clinic_printer where clinicid = ' || rec.id);
    execute immediate'insert into clinic_printer_' || v_deleted || ' select * from clinic_printer where clinicid = ' || rec.id;
    --dbms_output.put_line('Records inserted: ' || sql%rowcount);
    
    -- clinic_modality where clinicid = ' || rec.id
    --dbms_output.put_line('insert into clinic_modality_' || v_deleted || ' select * from clinic_modality where clinicid = ' || rec.id);
    execute immediate 'insert into clinic_modality_' || v_deleted || ' select * from clinic_modality where clinicid = ' || rec.id;
    --dbms_output.put_line('Records inserted: ' || sql%rowcount);
    
    
    -- clinic_hcsuppress where clinicid = ' || rec.id
    --dbms_output.put_line('insert into clinic_hcsuppress_' || v_deleted || ' select * from clinic_hcsuppress where clinicid = ' || rec.id);
    execute immediate 'insert into clinic_hcsuppress_' || v_deleted || ' select * from clinic_hcsuppress where clinicid = ' || rec.id;
    --dbms_output.put_line('Records inserted: ' || sql%rowcount);
    
    -- clinic_facility_manager
    --dbms_output.put_line('insert into clinic_fac_mgr_' || v_deleted || ' select * from clinic_facility_manager where clinicid = ' || rec.id);
    execute immediate 'insert into clinic_fac_mgr_' || v_deleted || ' select * from clinic_facility_manager where clinicid = ' || rec.id;
    --dbms_output.put_line('Records inserted: ' || sql%rowcount);
   
    -- clinic_page_notes
    for com IN (select * from clinic_comments
      where clinic_id = rec.id)
    loop
        --dbms_output.put_line('insert into clinic_page_notes_' || v_deleted || ' select * from clinic_page_notes where comment_id = ' || com.comment_id);
        execute immediate 'insert into clinic_page_notes_' || v_deleted || ' select * from clinic_page_notes where comment_id = ' || com.comment_id;
        --dbms_output.put_line('Records inserted: ' || sql%rowcount);
        --dbms_output.put_line('insert into clinic_page_notes_' || v_deleted || ' select * from clinic_page_notes where comment_id = ' || com.comment_id);
        execute immediate 'insert into clinic_comment_line_' || v_deleted || ' select * from clinic_comment_line where cliniccommentid = ' || com.comment_id;
    end loop;

    -- clinic_comments
    --dbms_output.put_line('insert into clinic_comments_' || v_deleted || ' select * from clinic_comments where clinic_id = ' || rec.id);
    execute immediate 'insert into clinic_comments_' || v_deleted || ' select * from clinic_comments where clinic_id = ' || rec.id;
    --dbms_output.put_line('Records inserted: ' || sql%rowcount);
    
    -- clinic_comments
    --dbms_output.put_line('insert into clinic_comments_' || v_deleted || ' select * from clinic_comments where clinic_id = ' || rec.id);
    execute immediate 'insert into clinic_comments_' || v_deleted || ' select * from clinic_comments where clinic_id = ' || rec.id;
    --dbms_output.put_line('Records inserted: ' || sql%rowcount);
    
    -- clinic_add_info
    --dbms_output.put_line('insert into clinic_add_info_' || v_deleted || ' select * from clinic_add_info where clinicid = ' || rec.id);
    execute immediate 'insert into clinic_add_info_' || v_deleted || ' select * from clinic_add_info where clinicid = ' || rec.id;
    --dbms_output.put_line('Records inserted: ' || sql%rowcount);
    
    -- clinic_courier
    --dbms_output.put_line('insert into clinic_courier_' || v_deleted || ' select * from clinic_courier where clinicid = ' || rec.id);
    execute immediate 'insert into clinic_courier_' || v_deleted || ' select * from clinic_courier where clinicid = ' || rec.id;
    --dbms_output.put_line('Records inserted: ' || sql%rowcount);
    
    -- clinic_cohort
    --dbms_output.put_line('insert into clinic_cohort_' || v_deleted || ' select * from clinic_cohort where clinicid = ' || rec.id);
    execute immediate 'insert into clinic_cohort_' || v_deleted || ' select * from clinic_cohort where clinicid = ' || rec.id;
    --dbms_output.put_line('Records inserted: ' || sql%rowcount);
    
    -- clinic_ah_seqno
    --dbms_output.put_line('insert into clinic_ah_seqno_' || v_deleted || ' select * from clinic_ah_seqno where clinicid = ' || rec.id);
    execute immediate 'insert into clinic_ah_seqno_' || v_deleted || ' select * from clinic_ah_seqno where clinicid = ' || rec.id;
    --dbms_output.put_line('Records inserted: ' || sql%rowcount);
    
    -- clinic_after_hours
    --dbms_output.put_line('insert into clinic_after_hours_' || v_deleted || ' select * from clinic_after_hours where clinicid = ' || rec.id);
    execute immediate 'insert into clinic_after_hours_' || v_deleted || ' select * from clinic_after_hours where clinicid = ' || rec.id;
    --dbms_output.put_line('Records inserted: ' || sql%rowcount);
    
    -- clinic_detail
    --dbms_output.put_line('insert into clinic_detail_' || v_deleted || ' select * from clinic_detail where clinic_id = ' || rec.id);
    execute immediate 'insert into clinic_detail_' || v_deleted || ' select * from clinic_detail where clinic_id = ' || rec.id;
    --dbms_output.put_line('Records inserted: ' || sql%rowcount);
    
    -- clinic
    --dbms_output.put_line('insert into clinic_' || v_deleted || ' select * from clinic where id = ' || rec.id);
    execute immediate 'insert into clinic_' || v_deleted || ' select * from clinic where id = ' || rec.id;
    --dbms_output.put_line('Records inserted: ' || sql%rowcount);


  
  end loop;
  
  exception
  when others then dbms_output.put_line(sqlerrm); 

end;

/



select * from clinic c
join clinic_detail cd ON cd.clinic_id = c.id
where id IN
(select id from cm2_clean_0828);

select * from cm2_clean_0828;

grant select on clinic_cm2_0828 to CM$READ; -- clinic table removed
grant select on clinic_detail_cm2_0828 to CM$READ; -- clinic_detail removed
grant select on cm2_clean_0828 to CM$READ; -- clinic to move to holding tables [tablename]_cm2_0828 ex. clinic_cm2_0828. Table has a remove date.


grant select on clinic_cm2_0828 to INTF_KORUS; 
grant select on clinic_detail_cm2_0828 to INTF_KORUS; 
grant select on cm2_clean_0828 to INTF_KORUS;



-- all tables with ext _CM2_0828 are created and available to view data that has been removed.

select * from clinic_cm2_0828 c
join clinic_detail_cm2_0828 cd ON cd.clinic_id = c.id;


update cm2_clean_0828
set removedate = null;

select * from clinic_comments_CM2_0828;

delete from clinic_comment_line where cliniccommentid IN (select comment_id from clinic_comments where clinic_id = 225096);
select * from clinic_comment_line
where  IN
(select comment_id from cliniccm2_clean_0828);

select d.* from clinic_west_0402 c
left join clinic_detail_west_0402 cd ON cd.clinic_id = c.id
left join clinic_remove_diff d ON d.id = c.id
where d.id is not null;
;
and d.removedate is null;

select w.id,w.servicelabid,d.servicelabid from clinic_remove_diff d
join clinic_remove_west_lab w ON w.id = d.id
where d.removedate is null
and w.servicelabid = d.servicelabid;

select * from clinic_prioritylist where clinicid = 526923;

select c.hlabnumber,cd.statusid from clinic c
join clinic_detail cd ON cd.clinic_id = c.id
where primaryaccount IN
(select primaryaccount
from clinic_detail_A103147);

select * from clinic_after_hours where clinicid = 526923;

select * from clinic_supply;

select * from clinic_draw_days where clinicdrawweekid = 93390;

select * from clinic_comments where clinic_id = 526923;

select * from clinic_page_notes where comment_id = 505102;

drop table clinic_draw_days_20240304;

select * from clinic_draw_days where clinicdrawweekid = 93390;

select * from clinic_draw_days_20240304  where clinicdrawweekid = 93390;

/
  select * from clinic_type_of_service;
/

declare v_deleted varchar2(32) := 'WEST_0402';

begin

  for rec IN (select * from CLINIC_REMOVE_WEST_LAB)
  loop
    --dbms_output.put_line('insert into clinic_alert_excep_' || v_deleted || ' select * from clinic_alert_exception where clinicid = ' || rec.id);
    execute immediate 'insert into clinic_alert_excep_' || v_deleted || ' select * from clinic_alert_exception where clinicid = ' || rec.id;
    --dbms_output.put_line('Records inserted: ' || sql%rowcount);
  end loop;
end;

/
select * from clinic_alert_excep_WEST_0402;
/

declare v_statusid number;

begin

for rec IN (select primaryaccount,statusid,servicelabid
from clinic c 
join clinic_detail cd ON cd.clinic_id = c.id
where c.hlabnumber = cd.primaryaccount
)
loop
    
  for assoc IN (
  select hlabnumber,primaryaccount,servicelabid,statusid,typeofserviceid
from clinic c 
join clinic_detail cd ON cd.clinic_id = c.id
where primaryaccount = rec.primaryaccount)
loop 
    if(assoc.statusid != rec.statusid or
    assoc.servicelabid != rec.servicelabid) then
      dbms_output.put_line(assoc.primaryaccount || ' ' || assoc.hlabnumber || ' ' || assoc.servicelabid || ' ' || assoc.statusid || ' ' || assoc.typeofserviceid );
    end if;
end loop;

end loop;


end;

/

select * from clinic_diff_0401;

select hlabnumber,primaryaccount,servicelabid,statusid
from clinic c 
join clinic_detail cd ON cd.clinic_id = c.id
where primaryaccount = 'A108468';