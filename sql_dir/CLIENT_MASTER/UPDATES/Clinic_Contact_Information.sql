insert into cm_change_queue
    (changeid,componentid,tableid,changetypeid,cmpostdate,cmuser,legacyupdate)
with tmp_clinic as (
  select 601348 as clinicid from dual union all
  select 603869 as clinicid from dual union all
  select 606969 as clinicid from dual union all
  select 607340 as clinicid from dual union all
  select 607432 as clinicid from dual union all
  select 609755 as clinicid from dual union all
  select 612763 as clinicid from dual
)
select cm_change_seq.nextval as changeid, 
    compo.componentid,
    tc.clinicid,
    chtype.changetypeid,
    systimestamp as cmpostdate,
    'ADMIN' as cmuser,
    cast(null as date) as legacyupdate
from tmp_clinic tc
  cross join cm_owner.CM_CHANGE_COMPONENTS compo
  cross join cm_owner.CM_CHANGE_TYPES chtype
where compo.componentdesc='Clinic Contact Info'
    and chtype.CHANGETYPEDESC='Clinic Contact Information';
    
select * from cm_change_types
where changetypeid = 5;

select * from
(select new_time(ts ,'UTC', 'America/New_York') as newtime,module,tab,pk,col,op,old_v,new_v from gen_audit
where ts > '08-OCT-24 11.05.44.570426000'
)
where module = 'SQL Developer'
order by newtime desc;

select * from cm_change_queue
--where changetypeid = 5
order by cmpostdate desc;