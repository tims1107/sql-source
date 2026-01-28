

select * from legacy_clinic
where accountstatus in ('Active','In progress');

select * from clinic_status;

select decode(servicelabid,1,'East',2,'West',3,'South') servicelab
,decode(statusid,10,'Validation',1,'Active',4,'In progress',6, 'Under Constr',7,'Lost',8,'Inactive #') status
,cnt from 
(select servicelabid, statusid,count(1) cnt from clinic c
join clinic_detail cd ON cd.clinic_id = c.id
group by servicelabid,cd.statusid)
order by servicelab;
/
create or replace function normalize_value(p_value varchar2,p_cl

/

select * from legacy_clinic;

select * from p_vw_clinicdetail;

 select v_clinicdetail.clinicdetailid,v_clinicdetail.hlabnumber,lc.tableflag,lc.medicaldir l_meddir,v_clinicdetail.medicaldirector cm_meddir from legacy_clinic lc
  join (select c.hlabnumber,decode(servicelabid,1,'E',2,'W',3,'S') tableflag,p.* from P_VW_CLINICDETAIL p
  join p_vw_clinic c ON c.id = p.clinicid where statusid = 1) v_clinicdetail ON v_clinicdetail.hlabnumber = lc.hlabnumber
  and lc.tableflag = v_clinicdetail.tableflag
  where upper(lc.medicaldir) not like upper(v_clinicdetail.medicaldirector); 

/
declare v_cnt number := 0;

begin

for rec IN (select v_clinicdetail.clinicdetailid,v_clinicdetail.hlabnumber,lc.tableflag,lc.medicaldir l_meddir,v_clinicdetail.medicaldirector cm_meddir from legacy_clinic lc
  join (select c.hlabnumber,decode(servicelabid,1,'E',2,'W',3,'S') tableflag,p.* from P_VW_CLINICDETAIL p
  join p_vw_clinic c ON c.id = p.clinicid where statusid = 1) v_clinicdetail ON v_clinicdetail.hlabnumber = lc.hlabnumber
  and lc.tableflag = v_clinicdetail.tableflag
  where upper(lc.medicaldir) not like upper(v_clinicdetail.medicaldirector))
  loop
   
   dbms_output.put_line(rec.clinicdetailid || chr(9) || rec.hlabnumber || chr(9) || rec.l_meddir || chr(9) || rec.cm_meddir);
   
   update clinic_detail
   set medicaldirector = rec.l_meddir
   where clinicdetailid = rec.clinicdetailid;
   
   commit;
  
  v_cnt := v_cnt + 1;
  
  end loop;
  
  dbms_output.put_line('Count ' || v_cnt);
  
 
end;

/

select * from cm_change_types;


select * from legacy_clinic l
where accountstatus = 'Active';

select * from clinic_change_history
order by effdate desc;