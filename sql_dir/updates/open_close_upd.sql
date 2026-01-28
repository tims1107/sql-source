select clinicsupplyid, cs.clinicid,om.ordermethodid,om.VALUE ordermethod,cs.accountnumber,kt.kittypeid,kt.VALUE kittype,
cs.monthly monthlyfreq,cs.midmonth midmonthfreq

from clinic_supply cs
left outer join CLINIC_COMMENTS cc ON cc.CLINIC_ID = cs.clinicid and cc.commenttype_id = 5
left outer join clinic_kit_type kt on kt.KITTYPEID = cs.KITTYPEID  
left outer join CLINIC_ORDER_METHOD om ON om.ORDERMETHODID = cs.ORDERMETHODID;
where clinicid = 217243
;

select * from clinic
where id not in
(select clinicid from clinic_supply);




select * from cm_change_types;

select * from vw_upd_supply
where kittype IN ('CUSTOM','GENERIC','NONE')
--and monthlyfreq > 0 OR midmonthfreq > 0
and clinicid = 200542;

delete clinic_open_close;

delete CM_OWNER.PLAC_PRINTER_LOAD;

select * from clinic_open_close;

select * from cm_change_types;

select * from clinic c
join 
(select * from vw_upd_hoursofoperation
where hourofday is not null;


select id,hlabnumber,decode(servicelabid,1,'E',2,'W',3,'S') from clinic c
join clinic_detail cd ON cd.clinic_id = c.id;

/
-- 
insert into cm_change_queue (changeid,componentid,tableid,changetypeid,cmpostdate,cmuser,legacyupdate) 
with tmp_hrs as (
    select ch.clinicid,c.HLABNUMBER, ht.hourtypename||'_TIME_'||
        case when d.dayabbrev in ('MON','WED','FRI')
            then 'MO_WE_FR'
        when d.dayabbrev in ('TUE','THU')
            then 'TU_TH_SA'
        when d.dayabbrev in ('SAT')
            then 'SA'
        else 'SUN'
        end as day_group,
        ch.hourofday
    from cm_owner.clinic_hours ch
      join cm_owner.hours_type ht
        on ht.hourstypeid=ch.hourtypeid
      join cm_owner.days d
        on d.dayid=ch.dayid
      join cm_owner.clinic c
        on c.id=ch.clinicid
    where ht.HOURTYPENAME in ('OPEN','CLOSE','PICKUP')
)
,tmp_majority as (
    select tch.*,
        count(1) over(partition by CLINICID, DAY_GROUP, HOUROFDAY) as majority
    from tmp_hrs tch
)
,tmp_ranking as (
    select tm.*,
        row_number() over (partition by CLINICID, day_group order by majority desc, hourofday) as rnk
    from tmp_majority tm
)
,tmp_set as (
    select CLINICID, hlabnumber, DAY_GROUP, HOUROFDAY
    from tmp_ranking
    where rnk=1
)
,tmp_clinic_hours as (
    select *
    from tmp_set
    pivot ( max(HOUROFDAY)
            for DAY_GROUP in ('OPEN_TIME_MO_WE_FR' as OPEN_TIME_MO_WE_FR,
                           'OPEN_TIME_TU_TH_SA' as OPEN_TIME_TU_TH_SA,
                           'OPEN_TIME_SA' as OPEN_TIME_SA,
                           'OPEN_TIME_SUN' as OPENSUN,
                           'CLOSE_TIME_MO_WE_FR' as CLOSE_TIME_MO_WE_FR,
                           'CLOSE_TIME_TU_TH_SA' as CLOSE_TIME_TU_TH_SA,
                           'CLOSE_TIME_SA' as CLOSE_TIME_SA,
                           'CLOSE_TIME_SUN' as CLOSESUN,
                           'PICKUP_TIME_MO_WE_FR' as PICKUP_TIME_MO_WE_FR,
                           'PICKUP_TIME_TU_TH_SA' as PICKUP_TIME_TU_TH_SA,
                           'PICKUP_TIME_SA' as PICKUP_TIME_SA
                        )
            )
)
--select c.*,decode(cd.servicelabid,1,'E',2,'W',3,'S') as e_w_flag
-- use to insert to queue only for cm1 updates
select cm_change_seq.nextval changeid,6 componentid,c.clinicid,7 changetypeid,systimestamp cmpostdate,'ADMIN' cmuser,cast(null as date) legacyupdate
from tmp_clinic_hours c
join clinic_detail cd ON cd.clinic_id = c.clinicid
join clinic_open_close oc ON oc.hlabnumber = c.hlabnumber and oc.tableflag = decode(cd.servicelabid,1,'E',2,'W',3,'S')
where cd.statusid IN (1,4)
and clinicid IN
(200111,200075,204633);
--and not (to_char(nvl(c.OPEN_TIME_MO_WE_FR,'01-JAN-24'),'hh:mi:ss PM') = to_char(nvl(oc.opentimemwf,'01-JAN-24'),'hh:mi:ss PM')
--      and to_char(nvl(c.OPEN_TIME_TU_TH_SA,'01-JAN-24'),'hh:mi:ss PM') = to_char(nvl(oc.opentimetths,'01-JAN-24'),'hh:mi:ss PM')
--      and to_char(nvl(c.OPEN_TIME_SA,'01-JAN-24'),'hh:mi:ss PM') = to_char(nvl(oc.opentimesat,'01-JAN-24'),'hh:mi:ss PM')
--);

select * from cm_change_queue
order by cmpostdate desc;

select * from clinic_open_close
where;

delete clinic_open_close;


select * from clinic_status;

join (select id,hlabnumber,decode(servicelabid,1,'E',2,'W',3,'S') from clinic c
join clinic_detail cd ON cd.clinic_id = c.id) sl ON sl.id = c

select * from cm_change_queue
order by cmpostdate desc;

select * from CM_OWNER.VW_CHANGE_QUEUE;


inse

select * from CM_OWNER.CM_CHANGE_COMPONENTS;

select * from cm_change_types;

select * from vw_upd_supply
where hlabnumber = 'A110174';

grant select ON vw_upd_supply to INTF_KORUS;

select clinic_id,count(*)
from cm_owner.CLINIC_COMMENTS
group by clinic_id
having count(*)<>5;

select *
from cm_owner.clinic_supply
where clinicid not in (select clinic_id from cm_owner.CLINIC_COMMENTS);

select * from clinic_supply
where clinicid NOT IN
(select id from p_vw_clinic);


create table fix_supply
as
select id,hlabnumber
from cm_owner.clinic
where id not in (select clinicid from cm_owner.clinic_supply);

select * from fix_supply
where id = 200324;

select *
from (
    SELECT clinicsupplyid,
           cs.clinicid,
           om.ordermethodid,
           om.VALUE        ordermethod,
           cs.accountnumber,
           kt.kittypeid,
           kt.VALUE        kittype,
           cs.monthly      monthlyfreq,
           cs.midmonth     midmonthfreq
      FROM cm_owner.clinic_supply  cs
           LEFT JOIN cm_owner.CLINIC_COMMENTS cc
               ON cc.CLINIC_ID = cs.clinicid AND cc.commenttype_id = 5
           LEFT JOIN cm_owner.clinic_kit_type kt ON kt.KITTYPEID = cs.KITTYPEID
           LEFT JOIN cm_owner.CLINIC_ORDER_METHOD om ON om.ORDERMETHODID = cs.ORDERMETHODID
)
where clinicid = (select id from cm_owner.clinic
                  where hlabnumber='A110174');

select * from clinic_supply
where clinicid = 210338;

select * from clinic_supply
where ordermethodid is null;

select * from CLINIC_ORDER_METHOD;

create unique index uidx_clinic_supply_clinicid ON clinic_supply(clinicid) online;

/

insert into cm_change_queue
    (changeid,componentid,tableid,changetypeid,cmpostdate,cmuser,legacyupdate)
with tmp_clinic as (
  select 200775 as clinicid from dual union all
  select 200781 as clinicid from dual union all
  select 200782 as clinicid from dual union all
  select 200784 as clinicid from dual union all
  select 201683 as clinicid from dual union all
  select 202634 as clinicid from dual union all
  select 203057 as clinicid from dual union all
  select 204097 as clinicid from dual union all
  select 204099 as clinicid from dual union all
  select 204129 as clinicid from dual union all
  select 204130 as clinicid from dual union all
  select 204305 as clinicid from dual union all
  select 205677 as clinicid from dual union all
  select 205683 as clinicid from dual union all
  select 205689 as clinicid from dual
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
where compo.componentdesc='Update Supply Information'
    and chtype.CHANGETYPEDESC='Clinic Supply Update';
    
select * from cm_change_queue
order by cmpostdate desc;

update cm_change_queue
set legacyupdate = systimestamp
where legacyupdate is null;

/
insert into cm_change_queue
    (changeid,componentid,tableid,changetypeid,cmpostdate,cmuser,legacyupdate)
with tmp_clinic as (
  select 200775 as clinicid from dual union all
  select 200781 as clinicid from dual union all
  select 200782 as clinicid from dual union all
  select 200784 as clinicid from dual union all
  select 201683 as clinicid from dual union all
  select 202634 as clinicid from dual union all
  select 203057 as clinicid from dual union all
  select 204097 as clinicid from dual union all
  select 204099 as clinicid from dual union all
  select 204129 as clinicid from dual union all
  select 204130 as clinicid from dual union all
  select 204305 as clinicid from dual union all
  select 205677 as clinicid from dual union all
  select 205683 as clinicid from dual union all
  select 205689 as clinicid from dual
)
select cm_change_seq.nextval as changeid, 
    compo.componentid,
    vs.CLINICSUPPLYID,
    chtype.changetypeid,
    systimestamp as cmpostdate,
    'ADMIN' as cmuser,
    cast(null as date) as legacyupdate
from tmp_clinic tc
  join cm_owner.p_vw_supply vs
    on vs.clinicid=tc.clinicid
  cross join cm_owner.CM_CHANGE_COMPONENTS compo
  cross join cm_owner.CM_CHANGE_TYPES chtype
where compo.componentdesc='Update Supply Information'
    and chtype.CHANGETYPEDESC='Clinic Supply Update';
    
    select * from clinic_change_history;
    
    select * from gen_audit
    where tab = 'CLINIC_SUPPLY'
    order by ts desc;


