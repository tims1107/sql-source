insert into cm_change_queue
    (changeid,componentid,tableid,changetypeid,cmpostdate,cmuser,legacyupdate)
with tmp_clinic as (
  select 201708 as clinicid from dual union all
  select 201710 as clinicid from dual union all
  select 201711 as clinicid from dual union all
  select 202043 as clinicid from dual union all
  select 202216 as clinicid from dual union all
  select 202345 as clinicid from dual union all
  select 202557 as clinicid from dual union all
  select 202594 as clinicid from dual union all
  select 202596 as clinicid from dual union all
  select 202689 as clinicid from dual union all
  select 202729 as clinicid from dual union all
  select 202731 as clinicid from dual union all
  select 202733 as clinicid from dual union all
  select 202847 as clinicid from dual union all
  select 202848 as clinicid from dual union all
  select 202895 as clinicid from dual union all
  select 202899 as clinicid from dual union all
  select 202927 as clinicid from dual union all
  select 202928 as clinicid from dual union all
  select 202929 as clinicid from dual union all
  select 207023 as clinicid from dual union all
  select 207195 as clinicid from dual union all
  select 208009 as clinicid from dual union all
  select 208959 as clinicid from dual union all
  select 209088 as clinicid from dual union all
  select 209470 as clinicid from dual union all
  select 209774 as clinicid from dual union all
  select 209826 as clinicid from dual union all
  select 209827 as clinicid from dual union all
  select 210129 as clinicid from dual union all
  select 210436 as clinicid from dual union all
  select 210480 as clinicid from dual union all
  select 210565 as clinicid from dual union all
  select 210566 as clinicid from dual union all
  select 210602 as clinicid from dual union all
  select 210640 as clinicid from dual union all
  select 210641 as clinicid from dual union all
  select 210642 as clinicid from dual union all
  select 210648 as clinicid from dual union all
  select 210649 as clinicid from dual union all
  select 210655 as clinicid from dual
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
where compo.componentdesc='Hours of operation'
    and chtype.CHANGETYPEDESC='Clinic Hours of operation';
    
    select * from cm_change_types
where changetypeid = 7;

select * from cm_change_queue
where changetypeid = 7
order by cmpostdate desc;