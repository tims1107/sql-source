
declare
  v_archive varchar2(16) := 'DIFF_0401';
  v_inserting varchar2(32) := 'clinic';
  v_message varchar2(4000) := 'Clinic restored ';

begin

  for rec IN (select * from clinic_remove_diff where hlabnumber IN
  (
'A101176',
'A127236',
'A101401',
'A100442',
'A101110',
'A101107',
'A100898'
) and removedate is not null)
  loop
  
  v_message := v_message || rec.id || ' from archive ' || v_archive;
  
  -- clinic
   v_inserting := 'clinic';
    dbms_output.put_line('insert into clinic select * from clinic_' || v_archive || ' where id = ' || rec.id);
    execute immediate 'insert into clinic select * from clinic_' || v_archive || ' where id = ' || rec.id;
   dbms_output.put_line('Inserting ' || v_inserting || ' ' || sql%rowcount);
   
   
   -- clinic_detail
   v_inserting := 'clinic_detail';
    dbms_output.put_line('insert into clinic_detail select * from clinic_detail_' || v_archive || ' where clinic_id = ' || rec.id);
    execute immediate 'insert into clinic_detail select * from clinic_detail_' || v_archive || ' where clinic_id = ' || rec.id;
   dbms_output.put_line('Inserting ' || v_inserting || ' ' || sql%rowcount);
   
   -- clinic_after_hours
   v_inserting := 'clinic_after_hours';
    dbms_output.put_line('insert into clinic_after_hours select * from clinic_after_hours_' || v_archive || ' where clinicid = ' || rec.id);
    execute immediate 'insert into clinic_after_hours select * from clinic_after_hours_' || v_archive || ' where clinicid = ' || rec.id;
   dbms_output.put_line('Inserting ' || v_inserting || ' ' || sql%rowcount);
   
   -- clinic_ah_seqno
      v_inserting := 'clinic_ah_seqno';
    dbms_output.put_line('insert into clinic_ah_seqno select * from clinic_ah_seqno_' || v_archive || ' where clinicid = ' || rec.id);
    execute immediate 'insert into clinic_ah_seqno select * from clinic_ah_seqno_' || v_archive || ' where clinicid = ' || rec.id;
   dbms_output.put_line('Inserting ' || v_inserting || ' ' || sql%rowcount);
   
   -- clinic_cohort
    v_inserting := 'clinic_cohort';
    dbms_output.put_line('insert into clinic_cohort select * from clinic_cohort_' || v_archive || ' where clinicid = ' || rec.id);
    execute immediate 'insert into clinic_cohort select * from clinic_cohort_' || v_archive || ' where clinicid = ' || rec.id;
   dbms_output.put_line('Inserting ' || v_inserting || ' ' || sql%rowcount);
   
   -- clinic_courier
   v_inserting := 'clinic_courier';
    dbms_output.put_line('insert into clinic_courier select * from clinic_courier_' || v_archive || ' where clinicid = ' || rec.id);
    execute immediate 'insert into clinic_courier select * from clinic_courier_' || v_archive || ' where clinicid = ' || rec.id;
   dbms_output.put_line('Inserting ' || v_inserting || ' ' || sql%rowcount);
   
   -- clinic_add_info
   v_inserting := 'clinic_add_info';
    dbms_output.put_line('insert into clinic_add_info select * from clinic_add_info_' || v_archive || ' where clinicid = ' || rec.id);
    execute immediate 'insert into clinic_add_info select * from clinic_add_info_' || v_archive || ' where clinicid = ' || rec.id;
   dbms_output.put_line('Inserting ' || v_inserting || ' ' || sql%rowcount);
   
   -- clinic_comments
   v_inserting := 'clinic_comments';
    dbms_output.put_line('insert into clinic_comments select * from clinic_comments_' || v_archive || ' where clinic_id = ' || rec.id);
    execute immediate 'insert into clinic_comments select * from clinic_comments_' || v_archive || ' where clinic_id = ' || rec.id;
   dbms_output.put_line('Inserting ' || v_inserting || ' ' || sql%rowcount);
   
   -- clinic_page_notes
   v_inserting := 'clinic_page_notes';
    dbms_output.put_line('insert into clinic_page_notes select * from clinic_page_notes_' || v_archive || ' where comment_id IN ( select comment_id from clinic_comments where clinic_id = ' || rec.id || ')');
    execute immediate 'insert into clinic_page_notes select * from clinic_page_notes_' || v_archive || ' where comment_id IN ( select comment_id from clinic_comments where clinic_id = ' || rec.id || ')';
    dbms_output.put_line('Inserting ' || v_inserting || ' ' || sql%rowcount);
    
    -- clinic_facility_manager - archive name clinic_fac_mgr_
    v_inserting := 'clinic_facility_manager';
    dbms_output.put_line('insert into clinic_facility_manager select * from clinic_fac_mgr_' || v_archive || ' where clinicid = ' || rec.id);
    execute immediate 'insert into clinic_facility_manager select * from clinic_fac_mgr_' || v_archive || ' where clinicid = ' || rec.id;
   dbms_output.put_line('Inserting ' || v_inserting || ' ' || sql%rowcount);
   
   -- clinic_hcsuppress
    v_inserting := 'clinic_hcsuppress';
    dbms_output.put_line('insert into clinic_hcsuppress select * from clinic_hcsuppress_' || v_archive || ' where clinicid = ' || rec.id);
    execute immediate 'insert into clinic_hcsuppress select * from clinic_hcsuppress_' || v_archive || ' where clinicid = ' || rec.id;
   dbms_output.put_line('Inserting ' || v_inserting || ' ' || sql%rowcount);
   
   
   -- clinic_modality 
   v_inserting := 'clinic_modality';
    dbms_output.put_line('insert into clinic_modality select * from clinic_modality_' || v_archive || ' where clinicid = ' || rec.id);
    execute immediate 'insert into clinic_modality select * from clinic_modality_' || v_archive || ' where clinicid = ' || rec.id;
   dbms_output.put_line('Inserting ' || v_inserting || ' ' || sql%rowcount);
   
   -- clinic_printer
   v_inserting := 'clinic_printer';
    dbms_output.put_line('insert into clinic_printer select * from clinic_printer_' || v_archive || ' where clinicid = ' || rec.id);
    execute immediate 'insert into clinic_printer select * from clinic_printer_' || v_archive || ' where clinicid = ' || rec.id;
   dbms_output.put_line('Inserting ' || v_inserting || ' ' || sql%rowcount);
   
   -- clinic_prioritylist
   v_inserting := 'clinic_prioritylist';
    dbms_output.put_line('insert into clinic_prioritylist select * from clinic_prioritylist_' || v_archive || ' where clinicid = ' || rec.id);
    execute immediate 'insert into clinic_prioritylist select * from clinic_prioritylist_' || v_archive || ' where clinicid = ' || rec.id;
   dbms_output.put_line('Inserting ' || v_inserting || ' ' || sql%rowcount);
   
   -- clinic_supply 
   v_inserting := 'clinic_supply';
    dbms_output.put_line('insert into clinic_supply select * from clinic_supply_' || v_archive || ' where clinicid = ' || rec.id);
    execute immediate 'insert into clinic_supply select * from clinic_supply_' || v_archive || ' where clinicid = ' || rec.id;
   dbms_output.put_line('Inserting ' || v_inserting || ' ' || sql%rowcount);
   
   -- clinic_draw_week 
   v_inserting := 'clinic_draw_week';
    dbms_output.put_line('insert into clinic_draw_week select * from clinic_draw_week_' || v_archive || ' where clinicid = ' || rec.id);
    execute immediate 'insert into clinic_draw_week select * from clinic_draw_week_' || v_archive || ' where clinicid = ' || rec.id;
   dbms_output.put_line('Inserting ' || v_inserting || ' ' || sql%rowcount);
   
   -- clinic_draw_days
   v_inserting := 'clinic_draw_days';
    dbms_output.put_line('insert into clinic_draw_days select * from clinic_draw_days_' || v_archive || ' where clinicdrawweekid IN (select clinicdrawweekid from ' || 'clinic_draw_week ' || ' where clinicid = ' || rec.id || ')');
    execute immediate 'insert into clinic_draw_days select * from clinic_draw_days_' || v_archive || ' where clinicdrawweekid IN (select clinicdrawweekid from ' || 'clinic_draw_week ' || ' where clinicid = ' || rec.id || ')';
   dbms_output.put_line('Inserting ' || v_inserting || ' ' || sql%rowcount);
   
    insert into migration_log values (migrate_log$seq.nextval,5,v_message,systimestamp);
 
  end loop;
  
  exception
  when others then dbms_output.put_line('Error inserting ' || v_inserting || chr(10) || sqlerrm);
  rollback;
  --insert into migration_log values (migrate_log$seq.nextval,6,sqlerrm,systimestamp);
  
end;

/

create table migration_log
(logid number,
messagetypeid number,
message varchar2(4000),
messagedate timestamp(6)
);

insert into migration_log (logid,messagetypeid,message,messagedate) values (MIGRATE_LOG$SEQ.nextval,1,'',systimestamp);

create table migration_message_type
(messagetypeid number,
messagetype varchar2(128),
createdate timestamp(6)
);

insert into migration_message_type (messagetypeid,messagetype,createdate) values (1,'CREATE ARCHIVE TABLE',systimestamp);
insert into migration_message_type (messagetypeid,messagetype,createdate) values (2,'EXTRACT TO BE REMOVED TABLE',systimestamp);
insert into migration_message_type (messagetypeid,messagetype,createdate) values (3,'INSERT EXTRACT TO ARCHIVE TABLE',systimestamp);
insert into migration_message_type (messagetypeid,messagetype,createdate) values (4,'DELETE TABLE ROW EXISTS IN EXTRACT TO REMOVE',systimestamp);
insert into migration_message_type (messagetypeid,messagetype,createdate) values (5,'MIGRATE FROM ARCHIVE TABLE TO DB',systimestamp);
insert into migration_message_type (messagetypeid,messagetype,createdate) values (6,'ERROR RAISED',systimestamp);

select * from clinic where hlabnumber = 'A101176'; 

delete clinic_west_0402
where hlabnumber IN
(select hlabnumber from clinic_remove_diff);
where statusid = 1;

select * from clinic_remove_diff
where removedate is null
--and servicelabid = 2
and statusid IN (4);

select hlabnumber,accountnumber,clinicname,statusid,typeofserviceid,servicelabid from clinic_diff_0401 c
join clinic_detail_diff_0401 cd ON cd.clinic_id = c.id
where hlabnumber = 'A108908';

select hlabnumber,accountnumber,clinicname,statusid,typeofserviceid,servicelabid from clinic c
join clinic_detail cd ON cd.clinic_id = c.id
where hlabnumber = 'A108908';

select hlabnumber,accountnumber,clinicname,statusid,typeofserviceid,servicelabid from clinic_west_0402 c
join clinic_detail_west_0402 cd ON cd.clinic_id = c.id
where hlabnumber = 'A108908';



select * from clinic_status;

update clinic_detail_diff_0401
set primaryaccount = 'A101176'
where clinic_id = 200456;

update clinic_modality_diff_0401
set primaryaccountid = 200456
where clinicid = 200456;

select id,c.hlabnumber,cd.primaryaccount,cm.primaryaccountid,statusid from clinic_diff_0401 c
join clinic_detail_diff_0401 cd ON cd.clinic_id = c.id
join clinic_modality_diff_0401 cm ON cm.CLINICID = cd.clinic_id
where hlabnumber IN
(
'A127164',
'A126706'
);

select id,c.hlabnumber,cd.primaryaccount,cm.primaryaccountid from clinic c
join clinic_detail cd ON cd.clinic_id = c.id
join clinic_modality cm ON cm.CLINICID = cd.clinic_id
where hlabnumber IN
(
'A127164',
'A126706'
);


select hlab_num,e_w_flag,primary_account,type_of_service,account_status,account_category from facility
where hlab_num IN
(
'A127164',
'A126706'
)
;

select hlab_num,e_w_flag,primary_account,type_of_service,account_status,account_category from facility
where primary_account IN
(select hlab_num from facility
where hlab_num IN
(
'A101176',
'A127236',
'A101401',
'A100442',
'A101110',
'A101107',
'A100898'
))
;

select mt.messagetype,l.* from CM_OWNER.MIGRATION_LOG l
join CM_OWNER.MIGRATION_MESSAGE_TYPE mt ON mt.messagetypeid = l.MESSAGETYPEID;

select * from gen_audit
where op = 'I'
and tab = 'CLINIC'
and ts > '01-APR-24 09.46.57.310879000 PM'
and pk <> 224868
order by ts desc;