

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
 select * from
 (select v_clinicdetail.clinicdetailid,v_clinicdetail.hlabnumber,lc.tableflag,lc.clinicalmgr lc_mgr,v_clinicdetail.CLINICALMANAGER cm_mgr from legacy_clinic lc
  join (select c.hlabnumber,decode(servicelabid,1,'E',2,'W',3,'S') tableflag,p.* from P_VW_CLINICDETAIL p
  join p_vw_clinic c ON c.id = p.clinicid where statusid in (1,4)) v_clinicdetail ON v_clinicdetail.hlabnumber = lc.hlabnumber
  
  and lc.tableflag = v_clinicdetail.tableflag)
  --where lc.hlabnumber = 'A117927';
--  where hlabnumber in
--  ('A200232'
--  ,'A200565'
--  ,'A200672'
--  ,'A200724'
--  ,'A200731');
  where upper(rtrim(nvl(lc_mgr,'_'))) not like upper(rtrim(nvl(cm_mgr,'_')));
  
    
  select * from p_vw_clinicdetail d
  join p_vw_clinic c ON c.id = d.clinicid 
  where hlabnumber IN
  ('A200232'
  ,'A200565'
  ,'A200672'
  ,'A200724'
  ,'A200731');
  
  A117927
  A113800
  A102566
  A121762
  A126054
  A107951
  A118890
  A101420
  A200612
  A123327
  A123673
  A200232
  A200565
  A200672
  A200724
  A200731
  
  select * from legacy_clinic
  where hlabnumber = 'A117927';

/
declare v_cnt number := 0;

begin

for rec IN (select * from
 (select v_clinicdetail.clinicdetailid,v_clinicdetail.hlabnumber,lc.tableflag,lc.clinicalmgr l_clinicalmgr,v_clinicdetail.CLINICALMANAGER cm_clinicalmgr from legacy_clinic lc
  join (select c.hlabnumber,decode(servicelabid,1,'E',2,'W',3,'S') tableflag,p.* from P_VW_CLINICDETAIL p
  join p_vw_clinic c ON c.id = p.clinicid where statusid in (1,4)) v_clinicdetail ON v_clinicdetail.hlabnumber = lc.hlabnumber
  
  and lc.tableflag = v_clinicdetail.tableflag)
 
  where upper(rtrim(nvl(l_clinicalmgr,'_'))) not like upper(rtrim(nvl(cm_clinicalmgr,'_'))))
  --where hlabnumber = 'A117927')
  loop
   
   dbms_output.put_line(rec.clinicdetailid || chr(9) || rec.hlabnumber || chr(9) || rec.l_clinicalmgr || chr(9) || rec.cm_clinicalmgr);
   
   update clinic_detail
   set clinicalmanager = rec.l_clinicalmgr
   where clinicdetailid = rec.clinicdetailid;
   
   commit;
  
  v_cnt := v_cnt + 1;
  
  end loop;
  
  dbms_output.put_line('Count ' || v_cnt);
  
 
end;

/

select * from cm_change_queue
order by cmpostdate desc;

select * from cm_change_types;


select * from legacy_clinic l
where accountstatus = 'Active';

select * from clinic_change_history
order by effdate desc;