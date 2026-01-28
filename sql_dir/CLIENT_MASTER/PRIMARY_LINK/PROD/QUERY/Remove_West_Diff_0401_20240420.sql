-- clinic_remove_west_lab table insert 
-- primary analysis
declare 
  v_statusid number;
  v_reason varchar2(64) := 'West Clinics';

begin

for rec IN (select primaryaccount,statusid,servicelabid
from clinic c 
join clinic_detail cd ON cd.clinic_id = c.id
where c.hlabnumber = cd.primaryaccount
and servicelabid = 2
)
loop
    
  for assoc IN (
  select id,clinicdetailid,primaryaccount,hlabnumber,servicelabid,statusid,typeofserviceid,modalityid
from clinic c 
join clinic_detail cd ON cd.clinic_id = c.id
where primaryaccount = rec.primaryaccount)
loop 
    if(assoc.servicelabid = 2) then
    begin
        insert into clinic_remove_west_lab (id,clinicdetailid,primaryaccount,hlabnumber,servicelabid,statusid,typeofserviceid,modalityid,removedate,reason)
          values
            (assoc.id
            ,assoc.clinicdetailid
            ,assoc.primaryaccount
            ,assoc.hlabnumber
            ,assoc.servicelabid
            ,assoc.statusid
            ,assoc.typeofserviceid
            ,assoc.modalityid
            ,null
            ,v_reason);
            
            exception
            when others then dbms_output.put_line(sqlerrm);
       end;
       
        --dbms_output.put_line(assoc.primaryaccount || ' ' || assoc.hlabnumber || ' ' || assoc.servicelabid || ' ' || assoc.statusid || ' ' || assoc.typeofserviceid );
    end if;
end loop;

end loop;


end;

/

select * from clinic_remove_west_lab
where primaryaccount IN ('A112032');

select id,primaryaccount,hlabnumber,servicelabid,statusid,modalityid from clinic c
join clinic_detail cd ON cd.clinic_id = c.id
where primaryaccount IN
(select primaryaccount from clinic_remove_west_lab)
and statusid = 1
and servicelabid in (1,3)
order by primaryaccount,modalityid;

select * from clinic_status;

select * from clinic_modality_type;

select primaryaccountid from
(select 
   clinicid
  ,primaryaccountid
  ,row_number() over (partition by m.primaryaccountid order by primaryaccountid,modalitytypeid) modtype
  ,m.modalitytypeid
  ,cd.servicelabid
  ,cd.statusid
from clinic c
join clinic_detail cd ON cd.clinic_id = c.id
join clinic_modality m ON m.primaryaccountid = c.id)
where modtype > 5
--and statusid = 1
group by primaryaccountid;

--where primaryaccountid = 206235
order by primaryaccountid;

select hlabnumber,m.* from clinic c
join clinic_modality m ON m.clinicid = c.id
where primaryaccountid = 200839;

select * from
(select 'DIFF_0401' tablename,primary_account,d.primaryaccount,f.hlabnumber,f.clinicname,e_w_flag,account_status,account_category,int_ext_study intextstudy,l.TYPE_OF_SERVICE from clinic_diff_0401 f
join clinic_detail_diff_0401 d ON d.clinic_id = f.id
join facility l ON l.hlab_num = f.hlabnumber
union all
select 'WEST_0402' tablename,primary_account legacy_primary,d.primaryaccount,f.hlabnumber,f.clinicname,e_w_flag,account_status,account_category,int_ext_study intextstudy,l.TYPE_OF_SERVICE from clinic_west_0402 f
join clinic_detail_west_0402 d ON d.clinic_id = f.id
join facility l ON l.hlab_num = f.hlabnumber) t1
where tablename = 'DIFF_0401'
--and intextstudy = 'I'
and e_w_flag IN ('S','E')
and account_status IN ('Active','In progress')
order by clinicname;

select * from clinic where hlabnumber = 'A101767';

select statusid,tos.value typeservice,count(1) from clinic_detail cd
left join clinic_type_of_service tos ON tos.typeofserviceid = cd.typeofserviceid
 where statusid IN (1,4)
 and cd.servicelabid = 1
 group by statusid,tos.value
 order by tos.VALUE;
 
 select t.*,
  case modality 
    when 'HEMO_COUNT' then 1 
    when 'HH_COUNT' then 2
    when 'PD_COUNT' then 3 
    else 0 END modalitytypeid
  from
 (select hlab_num,e_w_flag,int_ext_study,account_category,type_of_service,column_name modality,column_value patient_count from (
 select * 
 from facility)
 unpivot (column_value for column_name IN (hemo_count,hh_count,pd_count))) t
 where type_of_service is not null
 order by type_of_service;
 
 select * from facility;
 

 

select * from clinic_status;

select * from clinic_type_of_service;

select tos.value,statusid,count(1) from clinic c
join clinic_detail cd ON cd.clinic_id = c.id
join clinic_type_of_service tos ON tos.typeofserviceid = cd.typeofserviceid
where servicelabid IN (1,3)
and statusid IN (1)
and id < 225100
group by tos.value,statusid
order by value;

select * from clinic_detail
where statusid is null;

select * from clinic_type_of_service;

select * from clinic
where id  =225099;

select cd.clinicdetailid from clinic c
join clinic_detail cd ON cd.clinic_id = c.id
where hlabnumber IN
('A100052'
);



select * from gen_audit
where tab = 'CLINIC_DETAIL'
and col = 'SUPPORTID'
and OP = 'U'
--and pk = 603098
and ts > '17-APR-24 03.06.34.746050000 AM'
order by ts desc;

select * from clinic_support;

insert into clinic_support values ((select max(supportid) + 1 from clinic_support),'Josephine DeLisi');

select c.hlabnumber,cs.*,cd.SERVICELABID from clinic c
join clinic_detail cd ON cd.clinic_id = c.id
join clinic_support cs ON cs.SUPPORTID = cd.supportid
where cd.clinicdetailid = 626981;

delete clinic_printer;

commit;

select count(1) from clinic_printer;


