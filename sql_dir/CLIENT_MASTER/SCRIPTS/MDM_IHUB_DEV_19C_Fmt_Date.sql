select * from cm_change_queue
where changetypeid = 7
order by cmpostdate desc;

update cm_change_queue
set legacyupdate = null
where changeid = 181768;

where cmpostdate > '19-SEP-24 09.58.33.000000000 AM'
and changetypeid = 7;

select * from CM_OWNER.HOURS_TYPE;

select * from vw_upd_hoursofoperation
where clinicid = 550163;

select CLINICHOURSID
,CLINICID
,HOURTYPEID,DAYID
,coalesce(TO_CHAR(hourofday,'YYYY-MM-DD HH24:MI:SS'),'1900-01-01 00:00:00') hourofday
,hlab.hlabnumber,servicelab 
from clinic_hours h
join vw_upd_cliniccontactinfo hlab ON hlab.id = h.clinicid
where clinicid = 550163;
where dayid in (1,2,3,7)