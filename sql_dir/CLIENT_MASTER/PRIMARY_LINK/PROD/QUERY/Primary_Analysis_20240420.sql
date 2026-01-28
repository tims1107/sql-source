select * from 
(select id,hlabnumber,primaryaccount,typeofserviceid,
  row_number() 
  over (partition by primaryaccount
        order by primaryaccount) r
from clinic c
join clinic_detail cd ON cd.clinic_id = c.id) t1
where hlabnumber = primaryaccount
and typeofserviceid = 1;

select * from clinic_type_of_service;

select * from clinic_affiliation;

select e_w_flag,hlab_num,primary_account,int_ext_study,type_of_service,account_status from facility
where hlab_num IN
(select primaryaccount from 
(select id,hlabnumber,primaryaccount,typeofserviceid,
  row_number() 
  over (partition by primaryaccount
        order by primaryaccount) r
from clinic c
join clinic_detail cd ON cd.clinic_id = c.id) t1
where hlabnumber = primaryaccount
and typeofserviceid = 1)
and primary_account is not null
or primary_account = hlab_num
order by primary_account;

select * from 
(select id,hlabnumber,primaryaccount,typeofserviceid,
row_number() over (partition by primaryaccount order by primaryaccount) r
  
from clinic c
join clinic_detail cd ON cd.clinic_id = c.id
where primaryaccount IN
(select primaryaccount from 
(select id,hlabnumber,primaryaccount,typeofserviceid
from clinic c
join clinic_detail cd ON cd.clinic_id = c.id) t1))
where r > 5;

with modality_grp as (select primaryaccountid,count(1) from clinic_modality m
group by primaryaccountid
having count(1)= 4),
pri as (select * from clinic_modality)
select pri.primaryaccountid,pri.clinicid,t.value from pri 
join modality_grp g ON g.primaryaccountid = pri.primaryaccountid
join clinic_modality_type t ON t.modalityid = pri.modalitytypeid
where pri.primaryaccountid = clinicid
order by pri.primaryaccountid,t.modalityid;





order by primaryaccount;
where hlabnumber = primaryaccount
and typeofserviceid = 1);

select c.hlabnumber,cd.AFFILIATIONID from clinic c
join clinic_detail cd ON cd.clinic_id = c.id
where affiliationid not in (10)
and typeofserviceid = 1 
and hlabnumber = primaryaccount;


select * from cm_change_queue
where legacyupdate is null
--and tableid > 549900
order by tableid ;

create table cm_change_dev
as
select * from cm_change_queue
where legacyupdate is null;

update cm_change_queue
set legacyupdate = systimestamp
where changeid IN
(select changeid from cm_change_dev);

update cm_change_queue
set legacyupdate = null
where changeid IN
(select changeid from cm_change_dev
where changetypeid IN (1,2,3));

select * from cm_change_types;

select * from vw_new_assoc_upd
where id = 550008;

select * from clinic_detail
where clinic_id = 550008;

select id,hlabnumber,servicelabid,primaryaccount from clinic c
join clinic_detail cd ON cd.clinic_id = c.id
where hlabnumber IN
(
'B149761','B149811','B153311','B153311','B153716','B153716','B153716','B153677','B153677','B153683','B153683','B144171',
'B144171','B144171','B144791','B144791','B151591','B151591','B151591','B142611','B142611',
'B142611','B142611','B152931','B152931','B153281','B153281','B143621','B143621','B149511','B149511','B149511','B149511'
);

update clinic_detail
set servicelabid = 1
where servicelabid is null;

select * from clinic_comments
where clinic_id = 550008;