create or replace view audit_primary_assoc
as
with pri as (select c.id,c.clinicname,c.accountnumber facility_num,c.hlabnumber,cd.servicelabid,cd.statusid,cd.typeofserviceid,cd.primaryaccount,cd.modalityid from clinic c 
  join clinic_detail cd ON cd.clinic_id = c.id),
lab as (select id clinicid,regexp_substr(sl.label,'(E)|(S)|(W)',1,1) location,tos.value typeofservice,status.value status , mt.value modality, pri.* from pri
join clinic_servicelab sl ON sl.servicelabid = pri.servicelabid
join clinic_type_of_service tos ON tos.typeofserviceid = pri.typeofserviceid
join clinic_status status ON status.statusid = pri.statusid
join clinic_modality_type mt ON mt.modalityid = pri.modalityid),
  lfacility as (select lf.location,lab.clinicid,lab.clinicname,lab.facility_num,lf.hlabnumber ,lf.primaryaccount,lab.primaryaccount cm_primaryaccount,lf.primaryname,lf.typeofservice,
  lab.typeofservice cm_typeofservice,lab.status cm_status,
  lf.status,lab.modality from lab 
  left outer join legacy_facility lf ON lf.hlabnumber = lab.hlabnumber and lab.location = lf.location),
mods as (select primaryaccountid from clinic_modality
group by primaryaccountid
having count(1) > 5)
select *  from lfacility
where hlabnumber NOT IN 
('B134931','B134941','B134951','A200008','A200009','A200010','A200011','A200012','B134961','A200006','B134861','B134871','B134881','B134891','B134901',
'B134911','B134921');

/
with cm_clinics as (select * from audit_primary_assoc),
fac_table as (select e_w_flag,cm_primaryaccount,c.clinicid,c.clinicname,hlab_num,f.facility_num,int_ext_study,FACILITY_NAME,TYPE_OF_SERVICE,ACCOUNT_CATEGORY,ACCOUNT_STATUS,PRIMARY_ACCOUNT,HEMO_COUNT,PD_COUNT,HH_COUNT 
from facility f
join cm_clinics c ON c.hlabnumber = f.hlab_num and c.location = f.e_w_flag) 
select * from fac_table
where primary_account = 'A106905'
--where regexp_like(facility_name,'bay ridge sunset park dc','i')
--and account_status IN ('Active','In progress')
order by type_of_service desc
;

select * from facility;

select * from customer_num
where customer_num = 'C060662';

select * from facility
where primary_account = 'A117765';

select hlab_num,FACILITY_NAME,TYPE_OF_SERVICE,ACCOUNT_CATEGORY,ACCOUNT_STATUS,PRIMARY_ACCOUNT,HEMO_COUNT,PD_COUNT,HH_COUNT from facility
--where primary_account IN ('A102688','');
where hlab_num IN ('A102773','');

select c.HLABNUMBER,c.clinicname,m.MODALITYTYPEID,m.primaryaccountid,m.MODALITYCOUNT from clinic_modality m
join clinic c ON c.id = m.clinicid
where m.primaryaccountid = 209340;

select * from CM_OWNER.AUDIT_PRIMARY_ASSOC
where hlabnumber IN (

/
declare is_primary number;
v_modcnt number := 0;
v_assoc number := 0;

begin

for pri IN (select * from audit_primary_assoc where primaryaccount is null
  and LOCATION IN ('S','E') and  typeofservice IN ('ASSOCIATE') )
loop

 v_modcnt := 0;
 for mods IN (select * from clinic_modality where primaryaccountid = pri.clinicid)
 loop
 
   
  v_modcnt := v_modcnt + 1;
  
 end loop;
 
 if(v_modcnt > 0) then
  dbms_output.put_line(pri.clinicid || chr(9) || pri.hlabnumber || chr(9) || v_modcnt); 
 end if;


end loop;

end;

/

select mt.value modality,m.clinicid,cd.primaryaccount,m.* from clinic c
join clinic_detail cd ON cd.clinic_id = c.id
join clinic_modality m ON m.primaryaccountid = c.id
join clinic_modality_type mt ON mt.modalityid = m.modalitytypeid
where primaryaccountid IN (201442,201443,202210,202644,201441)
order by modality;

select mt.value modality,m.clinicid,c.hlabnumber,cd.primaryaccount,m.primaryaccountid from clinic c
join clinic_detail cd ON cd.clinic_id = c.id
join clinic_modality m ON m.primaryaccountid = c.id
join clinic_modality_type mt ON mt.modalityid = m.modalitytypeid
where primaryaccountid IN (219823,219824,219825,217568)
order by modality;

select a.* from audit_primary_assoc a
order by clinic_name

select * from facility
where primary_account = 'A108493';

select * from facility
where primary_account is null
and hlab_num = 'A108493';

select * from legacy_primary_clinic;
/

begin

for pri IN (select a.* from audit_primary_assoc a
join legacy_primary_clinic l ON l.primary_hlab_num = a.hlabnumber
--where regexp_like(clinicname, 'broadway','i')
order by clinicname)
loop

dbms_output.put_line('Primary:  ' || chr(9) || pri.clinicid || chr(9) || '      ' || chr(9) || pri.hlabnumber || chr(9) || pri.cm_primaryaccount || chr(9) ||  pri.clinicname
  || chr(9) || pri.location || chr(9) || pri.typeofservice || chr(9) || pri.modality);

for assoc IN (select * from audit_primary_assoc where primaryaccount = pri.hlabnumber
)
loop
  begin
  
  dbms_output.put_line('Associate: ' || chr(9) || pri.clinicid || chr(9) || assoc.clinicid || chr(9) || assoc.hlabnumber ||  chr(9) || assoc.primaryaccount || chr(9) || assoc.clinicname
  || chr(9) || pri.location || chr(9) || assoc.typeofservice || chr(9) || assoc.modality);
  --dbms_output.put_line(pri.clinicname);
  
  exception
  when others then
  dbms_output.put_line(sqlerrm);

  end;
  
end loop;

end loop;



end;

/

create index nuidx_primaryaccount ON facility(primary_account);

/

select * from clinic_detail
where primaryaccount IN ( 'A117765');

update clinic_detail
set primaryaccount = 'A115635'
where clinic_id IN (201442,201443,202210,202644,201441);


select clinic_id,primaryaccount from clinic_detail
where clinic_id IN (203232,203248,203249,203250);


select * from clinic_modality
where primaryaccountid IN (215508,215854,215855);

delete clinic_modality
where primaryaccountid IN (201442,201443,202210,202644,201441);

-- Insert Primary
insert into clinic_modality (CLINICMODALITYID,CLINICID,MODALITYTYPEID,PRIMARYACCOUNTID,MODALITYCOUNT,CREATEDAT,CREATEDBY)
VALUES
(CLINIC_MODALITY_SEQ.nextval,201441,1,201441,157,systimestamp,'ASSOC20231116');

-- Insert Associates
insert into clinic_modality (CLINICMODALITYID,CLINICID,MODALITYTYPEID,PRIMARYACCOUNTID,MODALITYCOUNT,CREATEDAT,CREATEDBY)
VALUES
(CLINIC_MODALITY_SEQ.nextval,201442,2,201441,1,systimestamp,'ASSOC20231120');

insert into clinic_modality (CLINICMODALITYID,CLINICID,MODALITYTYPEID,PRIMARYACCOUNTID,MODALITYCOUNT,CREATEDAT,CREATEDBY)
VALUES
(CLINIC_MODALITY_SEQ.nextval,202644,3,201441,1,systimestamp,'ASSOC20231120');

insert into clinic_modality (CLINICMODALITYID,CLINICID,MODALITYTYPEID,PRIMARYACCOUNTID,MODALITYCOUNT,CREATEDAT,CREATEDBY)
VALUES
(CLINIC_MODALITY_SEQ.nextval,202210,4,201441,0,systimestamp,'ASSOC20231120');

insert into clinic_modality (CLINICMODALITYID,CLINICID,MODALITYTYPEID,PRIMARYACCOUNTID,MODALITYCOUNT,CREATEDAT,CREATEDBY)
VALUES
(CLINIC_MODALITY_SEQ.nextval,201443,5,201441,0,systimestamp,'ASSOC20231120');

-- WATER - 4
-- STAFF - 5
select * from clinic_modality_type;

--203232	A106905	75411	Bay Ridge Sunset Park DC
--Associate: 	203232	203248	A106907	A106905	Bay Ridge Sunset Park DC PD
--Associate: 	203232	203249	A106909	A106905	Bay Ridge Sunset Park DC Staff
--Associate: 	203232	203250	A106910	A106905	Bay Ridge Sunset Park DC Env






