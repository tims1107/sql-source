-- Insert that will be removed from table entities to delete log tables for recovery
declare 
  v_drawweekid number;
  v_commentid number;
  ddl_qry varchar2(4000) := '';
  v_removed number := 0;
  
  v_deleted varchar2(32) := 'CM2_0828'; -- delete series tables

begin

  for rec IN (select * from cm2_clean_0828 where removedate is null )
    
  loop
    
    -- clinic_draw_days
    --dbms_output.put_line('delete from clinic_draw_days ' || ' where clinicdrawweekid IN (select clinicdrawweekid from ' || 'clinic_draw_week ' || ' where clinicid = ' || rec.id || ')');
    execute immediate 'delete from clinic_draw_days ' || ' where clinicdrawweekid IN (select clinicdrawweekid from ' || 'clinic_draw_week where clinicid = ' || rec.id || ')';
  

    
    -- clinic_draw_week where clinicid = ' || rec.id
    --dbms_output.put_line('delete from clinic_draw_week ' || ' where clinicid = ' || rec.id);
    execute immediate 'delete from clinic_draw_week ' || ' where clinicid = ' || rec.id;    
  
    -- clinic_supply
    --dbms_output.put_line('delete from clinic_supply ' || ' where clinicid = ' || rec.id);
    execute immediate 'delete from clinic_supply ' || ' where clinicid = ' || rec.id;  
    
    -- clinic_prioritylist
    --dbms_output.put_line('delete from clinic_prioritylist ' || ' where clinicid = ' || rec.id);
    execute immediate 'delete from clinic_prioritylist ' || ' where clinicid = ' || rec.id; 
    
    -- clinic_printer where clinicid = ' || rec.id
    --dbms_output.put_line('delete from clinic_printer ' || ' where clinicid = ' || rec.id);
    execute immediate 'delete from clinic_printer ' || ' where clinicid = ' || rec.id; 
    
    -- clinic_modality where clinicid = ' || rec.id
    --dbms_output.put_line('delete from clinic_modality ' || ' where clinicid = ' || rec.id);
    execute immediate 'delete from clinic_modality ' || ' where clinicid = ' || rec.id; 
    
    
    -- clinic_hcsuppress where clinicid = ' || rec.id
    --dbms_output.put_line('delete from clinic_hcsuppress ' || ' where clinicid = ' || rec.id);
    execute immediate 'delete from clinic_hcsuppress ' || ' where clinicid = ' || rec.id;
    
    -- clinic_facility_manager
    --dbms_output.put_line('delete from clinic_facility_manager ' || ' where clinicid = ' || rec.id);
    execute immediate 'delete from clinic_facility_manager ' || ' where clinicid = ' || rec.id;
    
    -- clinic_page_notes
    --dbms_output.put_line('delete from clinic_page_notes where comment_id IN ( select comment_id from clinic_comments where clinic_id = ' || rec.id || ')');
    execute immediate 'delete from clinic_page_notes where comment_id IN ( select comment_id from clinic_comments where clinic_id = ' || rec.id || ')';
    

    -- clinic_comments
    --dbms_output.put_line('delete from clinic_comments ' || ' where clinic_id = ' || rec.id);
    execute immediate 'delete from clinic_comments ' || ' where clinic_id = ' || rec.id;
    
    -- clinic_comments
    --dbms_output.put_line('delete from clinic_comments ' || ' where clinic_id = ' || rec.id);
    execute immediate 'delete from clinic_comment_line ' || ' where cliniccommentid IN (select comment_id from clinic_comments where clinic_id = ' || rec.id || ')';
    
    -- clinic_add_info
    --dbms_output.put_line('delete from clinic_add_info ' || ' where clinicid = ' || rec.id);
    execute immediate 'delete from clinic_add_info ' || ' where clinicid = ' || rec.id;
    
    -- clinic_courier
    --dbms_output.put_line('delete from clinic_courier ' || ' where clinicid = ' || rec.id);
    execute immediate 'delete from clinic_courier ' || ' where clinicid = ' || rec.id;
    
    -- clinic_cohort
    --dbms_output.put_line('delete from clinic_cohort ' || ' where clinicid = ' || rec.id);
    execute immediate 'delete from clinic_cohort ' || ' where clinicid = ' || rec.id;
    
    -- clinic_ah_seqno
    --dbms_output.put_line('delete from clinic_ah_seqno ' || ' where clinicid = ' || rec.id);
    execute immediate 'delete from clinic_ah_seqno ' || ' where clinicid = ' || rec.id;
    
    -- clinic_after_hours
    --dbms_output.put_line('delete from clinic_after_hours ' || ' where clinicid = ' || rec.id);
    execute immediate 'delete from clinic_after_hours ' || ' where clinicid = ' || rec.id;
    
    -- clinic_alert_exception
    --dbms_output.put_line('delete from clinic_alert_exception ' || ' where clinicid = ' || rec.id);
    execute immediate 'delete from clinic_alert_exception ' || ' where clinicid = ' || rec.id;
    --dbms_output.put_line('Records inserted: ' || sql%rowcount);
    
    -- clinic_detail
    --dbms_output.put_line('delete from clinic_detail ' || ' where clinic_id = ' || rec.id);
    execute immediate 'delete from clinic_detail ' || ' where clinic_id = ' || rec.id;
    
    -- clinic
    --dbms_output.put_line('delete from clinic ' || ' where id = ' || rec.id);
    execute immediate 'delete from clinic ' || ' where id = ' || rec.id;
    --dbms_output.put_line('insert into clinic_' || v_deleted || ' select * from clinic where id = ' || rec.id);
    --execute immediate 'insert into clinic_' || v_deleted || ' select * from clinic where id = ' || rec.id;
    v_removed := v_removed + sql%rowcount;
    if (sql%rowcount = 0) then
      dbms_output.put_line(rec.hlabnumber);
    end if;
    

    update cm2_clean_0828
    set removedate = systimestamp
    where id = rec.id;
  
  end loop;
  
  dbms_output.put_line('Clinics removed: ' || v_removed);
  
  exception
  when others then dbms_output.put_line(sqlerrm); 

end;

/

select * from clinic;

select c.id,c.hlabnumber,w.primaryaccount,c.clinicname,s.value account_status,t.value tos,m.value modality from clinic c 
join clinic_remove_west_lab w ON w.id = c.id
join clinic_status s ON s.statusid = w.statusid
join clinic_type_of_service t ON t.TYPEOFSERVICEID = w.typeofserviceid
join clinic_modality_type m ON m.MODALITYID = w.modalityid
where w.statusid <> 1
order by w.primaryaccount;

select * from clinic_remove_west_lab
where removedate is not null;

select * from clinic_west_0402
where id NOT IN
(select rd.id from CM_OWNER.CLINIC_REMOVE_DIFF rd
join clinic_remove_west_lab wl ON wl.id = rd.id
and wl.servicelabid = 2);

select * from ds_customer_num;
select * from clinic_facility;

select f.clinicid,c.hlabnumber from clinic c
join clinic_detail cd ON cd.clinic_id = c.id
join clinic_facility f ON f.CLINICID = cd.clinic_id
where f.clinicid is not null;

select * from CM_OWNER.CLINIC_DIFF_0401;

select hlab_num,account_status from facility
where hlab_num = 'A112614';

where removedate is  null;

select * from clinic_remove_west_lab
where hlabnumber IN
(select hlabnumber from clinic_diff_0401)
and removedate is null;

select * from clinic_remove_west_lab
where removedate is  not null
and statusid = 1;

select * from clinic where id = 219338;

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