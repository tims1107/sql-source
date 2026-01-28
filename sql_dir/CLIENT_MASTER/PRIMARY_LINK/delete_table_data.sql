-- Insert that will be removed from table entities to delete log tables for recovery
declare 
  v_drawweekid number;
  v_commentid number;
  ddl_qry varchar2(4000) := '';
  
  v_deleted varchar2(32) := 'DIFF_0401'; -- delete series tables

begin

  for rec IN (select * from clinic_remove_diff where primaryaccount = 'A118608'
  and removedate is null)
    
  loop
    
    -- clinic_draw_days
    dbms_output.put_line('delete from clinic_draw_days ' || ' where clinicdrawweekid IN (select clinicdrawweekid from ' || 'clinic_draw_week ' || ' where clinicid = ' || rec.id || ')');
    execute immediate 'delete from clinic_draw_days ' || ' where clinicdrawweekid IN (select clinicdrawweekid from ' || 'clinic_draw_week where clinicid = ' || rec.id || ')';
--    for draw IN (select * from clinic_draw_week
--      where clinicid = rec.id)
--    loop
--    
--      
--      --dbms_output.put_line(rec.hlabnumber || chr(9) || rec.id );
--      --dbms_output.put_line('insert into clinic_draw_days_' || v_deleted || ' select * from clinic_draw_days where clinicdrawweekid = ' || draw.clinicdrawweekid);
--      execute immediate 'delete from clinic_draw_days where clinicdrawweekid IN ' || draw.clinicdrawweekid;
--      --dbms_output.put_line('Records inserted: ' || sql%rowcount);
--      
--      
--    end loop;
    
    -- clinic_draw_week where clinicid = ' || rec.id
    dbms_output.put_line('delete from clinic_draw_week ' || ' where clinicid = ' || rec.id);
    execute immediate 'delete from clinic_draw_week ' || ' where clinicid = ' || rec.id;    
    --dbms_output.put_line('insert into clinic_draw_week_' || v_deleted || ' select * from clinic_draw_week where clinicid = ' || rec.id);
    --execute immediate 'insert into clinic_draw_week_' || v_deleted || ' select * from clinic_draw_week where clinicid = ' || rec.id;
    --dbms_output.put_line('Records inserted: ' || sql%rowcount);  

    -- clinic_supply where clinicid = ' || rec.id 
    
    dbms_output.put_line('delete from clinic_supply ' || ' where clinicid = ' || rec.id);
    execute immediate 'delete from clinic_supply ' || ' where clinicid = ' || rec.id;  
    --dbms_output.put_line('insert into clinic_supply_' || v_deleted || ' select * from clinic_supply where clinicid = ' || rec.id);
    --execute immediate 'insert into clinic_supply_' || v_deleted || ' select * from clinic_supply where clinicid = ' || rec.id;
    --dbms_output.put_line('Records inserted: ' || sql%rowcount);
    
    -- clinic_prioritylist
    dbms_output.put_line('delete from clinic_prioritylist ' || ' where clinicid = ' || rec.id);
    execute immediate 'delete from clinic_prioritylist ' || ' where clinicid = ' || rec.id; 
    --dbms_output.put_line('insert into clinic_prioritylist_' || v_deleted || ' select * from clinic_prioritylist where clinicid = ' || rec.id);
    --execute immediate 'insert into clinic_prioritylist_' || v_deleted || ' select * from clinic_prioritylist where clinicid = ' || rec.id;
    --dbms_output.put_line('Records inserted: ' || sql%rowcount);
    
    -- clinic_printer where clinicid = ' || rec.id
    dbms_output.put_line('delete from clinic_printer ' || ' where clinicid = ' || rec.id);
    execute immediate 'delete from clinic_printer ' || ' where clinicid = ' || rec.id; 
    --dbms_output.put_line('insert into clinic_printer_' || v_deleted || ' select * from clinic_printer where clinicid = ' || rec.id);
    --execute immediate'insert into clinic_printer_' || v_deleted || ' select * from clinic_printer where clinicid = ' || rec.id;
    --dbms_output.put_line('Records inserted: ' || sql%rowcount);
    
    -- clinic_modality where clinicid = ' || rec.id
    dbms_output.put_line('delete from clinic_modality ' || ' where clinicid = ' || rec.id);
    execute immediate 'delete from clinic_modality ' || ' where clinicid = ' || rec.id; 
    --dbms_output.put_line('insert into clinic_modality_' || v_deleted || ' select * from clinic_modality where clinicid = ' || rec.id);
    --execute immediate 'insert into clinic_modality_' || v_deleted || ' select * from clinic_modality where clinicid = ' || rec.id;
    --dbms_output.put_line('Records inserted: ' || sql%rowcount);
    
    
    -- clinic_hcsuppress where clinicid = ' || rec.id
    dbms_output.put_line('delete from clinic_hcsuppress ' || ' where clinicid = ' || rec.id);
    execute immediate 'delete from clinic_hcsuppress ' || ' where clinicid = ' || rec.id;
    --dbms_output.put_line('insert into clinic_hcsuppress_' || v_deleted || ' select * from clinic_hcsuppress where clinicid = ' || rec.id);
    --execute immediate 'insert into clinic_hcsuppress_' || v_deleted || ' select * from clinic_hcsuppress where clinicid = ' || rec.id;
    --dbms_output.put_line('Records inserted: ' || sql%rowcount);
    
    -- clinic_facility_manager
    dbms_output.put_line('delete from clinic_facility_manager ' || ' where clinicid = ' || rec.id);
    execute immediate 'delete from clinic_facility_manager ' || ' where clinicid = ' || rec.id;
    --dbms_output.put_line('insert into clinic_fac_mgr_' || v_deleted || ' select * from clinic_facility_manager where clinicid = ' || rec.id);
    --execute immediate 'insert into clinic_fac_mgr_' || v_deleted || ' select * from clinic_facility_manager where clinicid = ' || rec.id;
    --dbms_output.put_line('Records inserted: ' || sql%rowcount);
   
    -- clinic_page_notes
    dbms_output.put_line('delete from clinic_page_notes where comment_id IN ( select comment_id from clinic_comments where clinic_id = ' || rec.id || ')');
    execute immediate 'delete from clinic_page_notes where comment_id IN ( select comment_id from clinic_comments where clinic_id = ' || rec.id || ')';
    
--    for com IN (select * from clinic_comments
--      where clinic_id = rec.id)
--    loop
--        --dbms_output.put_line('insert into clinic_page_notes_' || v_deleted || ' select * from clinic_page_notes where comment_id = ' || com.comment_id);
--        execute immediate 'insert into clinic_page_notes_' || v_deleted || ' select * from clinic_page_notes where comment_id = ' || com.comment_id;
--        --dbms_output.put_line('Records inserted: ' || sql%rowcount); 
--    end loop;

    -- clinic_comments
    dbms_output.put_line('delete from clinic_comments ' || ' where clinic_id = ' || rec.id);
    execute immediate 'delete from clinic_comments ' || ' where clinic_id = ' || rec.id;
    --dbms_output.put_line('insert into clinic_comments_' || v_deleted || ' select * from clinic_comments where clinic_id = ' || rec.id);
    --execute immediate 'insert into clinic_comments_' || v_deleted || ' select * from clinic_comments where clinic_id = ' || rec.id;
    --dbms_output.put_line('Records inserted: ' || sql%rowcount);
    
    -- clinic_add_info
    dbms_output.put_line('delete from clinic_add_info ' || ' where clinicid = ' || rec.id);
    execute immediate 'delete from clinic_add_info ' || ' where clinicid = ' || rec.id;
    --dbms_output.put_line('insert into clinic_add_info_' || v_deleted || ' select * from clinic_add_info where clinicid = ' || rec.id);
    --execute immediate 'insert into clinic_add_info_' || v_deleted || ' select * from clinic_add_info where clinicid = ' || rec.id;
    --dbms_output.put_line('Records inserted: ' || sql%rowcount);
    
    -- clinic_courier
    dbms_output.put_line('delete from clinic_courier ' || ' where clinicid = ' || rec.id);
    execute immediate 'delete from clinic_courier ' || ' where clinicid = ' || rec.id;
    --dbms_output.put_line('insert into clinic_courier_' || v_deleted || ' select * from clinic_courier where clinicid = ' || rec.id);
    --execute immediate 'insert into clinic_courier_' || v_deleted || ' select * from clinic_courier where clinicid = ' || rec.id;
    --dbms_output.put_line('Records inserted: ' || sql%rowcount);
    
    -- clinic_cohort
    dbms_output.put_line('delete from clinic_cohort ' || ' where clinicid = ' || rec.id);
    execute immediate 'delete from clinic_cohort ' || ' where clinicid = ' || rec.id;
    --dbms_output.put_line('insert into clinic_cohort_' || v_deleted || ' select * from clinic_cohort where clinicid = ' || rec.id);
    --execute immediate 'insert into clinic_cohort_' || v_deleted || ' select * from clinic_cohort where clinicid = ' || rec.id;
    --dbms_output.put_line('Records inserted: ' || sql%rowcount);
    
    -- clinic_ah_seqno
    dbms_output.put_line('delete from clinic_ah_seqno ' || ' where clinicid = ' || rec.id);
    execute immediate 'delete from clinic_ah_seqno ' || ' where clinicid = ' || rec.id;
    --dbms_output.put_line('insert into clinic_ah_seqno_' || v_deleted || ' select * from clinic_ah_seqno where clinicid = ' || rec.id);
    --execute immediate 'insert into clinic_ah_seqno_' || v_deleted || ' select * from clinic_ah_seqno where clinicid = ' || rec.id;
    --dbms_output.put_line('Records inserted: ' || sql%rowcount);
    
    -- clinic_after_hours
    dbms_output.put_line('delete from clinic_after_hours ' || ' where clinicid = ' || rec.id);
    execute immediate 'delete from clinic_after_hours ' || ' where clinicid = ' || rec.id;
    --dbms_output.put_line('insert into clinic_after_hours_' || v_deleted || ' select * from clinic_after_hours where clinicid = ' || rec.id);
    --execute immediate 'insert into clinic_after_hours_' || v_deleted || ' select * from clinic_after_hours where clinicid = ' || rec.id;
    --dbms_output.put_line('Records inserted: ' || sql%rowcount);
    
    -- clinic_detail
    dbms_output.put_line('delete from clinic_detail ' || ' where clinic_id = ' || rec.id);
    execute immediate 'delete from clinic_detail ' || ' where clinic_id = ' || rec.id;
    --dbms_output.put_line('insert into clinic_detail_' || v_deleted || ' select * from clinic_detail where clinic_id = ' || rec.id);
    --execute immediate 'insert into clinic_detail_' || v_deleted || ' select * from clinic_detail where clinic_id = ' || rec.id;
    --dbms_output.put_line('Records inserted: ' || sql%rowcount);
    
    -- clinic
    dbms_output.put_line('delete from clinic ' || ' where id = ' || rec.id);
    execute immediate 'delete from clinic ' || ' where id = ' || rec.id;
    --dbms_output.put_line('insert into clinic_' || v_deleted || ' select * from clinic where id = ' || rec.id);
    --execute immediate 'insert into clinic_' || v_deleted || ' select * from clinic where id = ' || rec.id;
    --dbms_output.put_line('Records inserted: ' || sql%rowcount);

    update clinic_remove_diff
    set removedate = systimestamp
    where id = rec.id;
  
  end loop;
  
  exception
  when others then dbms_output.put_line(sqlerrm); 

end;

/

select id,clinicname,primaryaccount,hlabnumber,accountnumber,servicelabid,statusid,typeofserviceid from clinic c
join clinic_detail cd ON cd.clinic_id = c.id
where primaryaccount IN
(select * from clinic_remove_diff
where primaryaccount = 'A118608')
order by primaryaccount,statusid;

select * from clinic_remove_diff
where regexp_like(primaryaccount,'A118608');

select c.clinicname,cd.primaryaccount,c.hlabnumber,cd.servicelabid,cd.statusid,cd.typeofserviceid,s.value account_status from clinic_diff_0401 c
join clinic_detail_diff_0401 cd ON cd.clinic_id = c.id
join clinic_status s ON s.statusid = cd.statusid
where primaryaccount = 'A118608'
and hlabnumber NOT IN  (
'A101176'
,'A125505'
,'A125506'
,'A125507'
,'A121778');

select * from clinic_modality
where primaryaccountid = 211054;

select * from clinic_draw_days  where clinicdrawweekid IN (select clinicdrawweekid from clinic_draw_week_DIFF_0401 where clinicid = 210339);

delete from clinic_draw_days  where clinicdrawweekid IN (select clinicdrawweekid from clinic_draw_week_DIFF_0401 where clinicid = 210339);

select clinicdrawweekid from clinic_draw_week where clinicid = 210339;

select * from clinic_draw_days where clinicdrawweekid = 127532;

select * from clinic_supply  where clinicid = 210339;
select * from clinic_prioritylist  where clinicid = 210339;
select * from clinic_printer  where clinicid = 210339;
select * from clinic_modality  where clinicid = 210339;

select * from clinic_hcsuppress  where clinicid = 210339;
select * from clinic_facility_manager  where clinicid = 210339;
select * from clinic_page_notes where comment_id IN ( select comment_id from clinic_comments where clinic_id = 210339);
select * from clinic_comments  where clinic_id = 210339;

select * from clinic_add_info  where clinicid = 210339;
select * from clinic_courier  where clinicid = 210339;
select * from clinic_cohort  where clinicid = 210339;
select * from clinic_ah_seqno  where clinicid = 210339;
select * from clinic_after_hours  where clinicid = 210339;
select * from clinic_detail  where clinic_id = 210339;
select * from clinic  where id = 210339;

select * from clinic_remove_diff
where removedate is not null;

select * from gen_audit
where op = 'D'
and ts > '02-APR-24 03.06.01.382254000 PM'
order by tab;

select hlabnumber,clinic_id,servicelabid,s.statusid,s.value from clinic c
join clinic_detail cd ON cd.clinic_id = c.id
join clinic_status s ON s.STATUSID = cd.statusid
where primaryaccount = 'A118608';

/
begin
execute immediate 'delete from clinic_draw_days  where clinicdrawweekid IN (select clinicdrawweekid from clinic_draw_week_DIFF_0401 where clinicid = ' || 210339 || ')';
end;


/

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

-- clinic_remove_diff table
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