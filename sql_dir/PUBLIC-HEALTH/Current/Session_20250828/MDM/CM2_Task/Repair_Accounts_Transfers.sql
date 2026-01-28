select * from cm_change_queue
where legacyupdate is null
and changetypeid = 1
order by cmpostdate desc;

select * from cm_change_types;

select * from vw_new_clinic_upd
where id = 550285;

select * from vw_upd_transfer;

update cm_change_queue
set legacyupdate = null
where changeid IN (192444
,192452
,192451);


select c.hlabnumber,c.accountnumber,cd.primaryaccount from clinic c
join clinic_detail cd ON cd.clinic_id = c.id
where id = 550285;

select * from clinic
where id = 542509;

select * from gen_audit
where pk IN (542509,364836);

delete clinic
where id = 542509;

delete clinic_detail
where clinic_id = 542509;

delete from clinic_draw_days
where clinicdrawweekid IN (select clinicdrawweekid from clinic_draw_week where clinicid = 542509);  

select * from clinic_draw_days where clinicdrawweekid IN (select clinicdrawweekid from clinic_draw_week where clinicid = 542509);

delete from clinic_draw_week  where clinicid = 542509;  

delete from clinic_supply  where clinicid = 542509; 

delete from clinic_prioritylist  where clinicid = 542509; 

delete from clinic_printer  where clinicid = 542509; 

delete from clinic_modality  where clinicid = 542509; 

delete from clinic_hcsuppress  where clinicid = 542509; 

delete from clinic_comments  where clinic_id = 542509; 

update clinic 
set hlabnumber = 'A126323',accountnumber = 'A126323'
where id = 550285;

update clinic_detail 
set primaryaccount = 'A126323'
where clinic_id = 550285;

select * from clinic c
join clinic

select * from clinic_A126


