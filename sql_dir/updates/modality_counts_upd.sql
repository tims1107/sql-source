declare updated_rows smallint := 0;
primaryaccountid number := 0;

begin

for rec IN (select c.id,l.*,(select primaryaccountid from clinic_modality cm 
where cm.clinicid = c.id group by primaryaccountid) primaryaccountid from legacy_clinic l
join clinic c ON c.hlabnumber = l.hlabnumber
join clinic_detail cd ON cd.clinic_id = c.id 
and decode(l.tableflag,'E',1,'S',3) = cd.servicelabid
)
loop

  --dbms_output.put_line(rec.hlabnumber );
  
  for mo IN 1 .. 3
  loop
  
  --v_update := 0;
  
  if(mo = 1) then
  --dbms_output.put_line(mo.clinicid || chr(9) || mo.modalitytypeid || chr(9) || 'HEMOCOUNT' || chr(9) || rec.hemocount || chr(9) ||mo.modalitycount);
  
  update clinic_modality
  set modalitycount = rec.hemocount,CREATEDAT=systimestamp,CREATEDBY='UPDATE'
  where clinicid = rec.id and modalitytypeid = mo;
  
  
  updated_rows := sql%rowcount;
  
  if (rec.hemocount = 0 and updated_rows = 0) then
  updated_rows := 1;
  end if;
  
  elsif(mo = 2) then
  --dbms_output.put_line(mo.clinicid || chr(9) || mo.modalitytypeid || chr(9) || 'HHCOUNT ' || chr(9) || rec.hhcount || chr(9) ||mo.modalitycount);
  
  update clinic_modality
  set modalitycount = rec.hhcount,CREATEDAT=systimestamp,CREATEDBY='UPDATE'
  where clinicid = rec.id and modalitytypeid = mo;
  
  
  updated_rows := sql%rowcount;
  
  if (rec.hhcount = 0 and updated_rows = 0) then
  updated_rows := 1;
  end if;
  
  elsif(mo = 3) then
  --dbms_output.put_line(mo.clinicid || chr(9) || mo.modalitytypeid || chr(9) || 'PDCOUNT ' || chr(9) || rec.pdcount || chr(9) ||mo.modalitycount);
  
  update clinic_modality
  set modalitycount = rec.pdcount,CREATEDAT=systimestamp,CREATEDBY='UPDATE'
  where clinicid = rec.id and modalitytypeid = mo;
  
  updated_rows := sql%rowcount;
  
  if (rec.pdcount = 0 and updated_rows = 0) then
    updated_rows := 1;
  end if;
  
  end if;
  
  if (updated_rows = 0) then
  
  merge into missing_modality t
  Using (select rec.id clinicid,mo modalitytypeid,rec.primaryaccountid primaryaccountid from dual
    ) s
  ON (
    t.clinicid = s.clinicid and t.modalitytypeid = s.modalitytypeid)
  
  WHEN NOT MATCHED THEN
    insert (t.clinicid,t.modalitytypeid,t.primaryaccountid)
    values(s.clinicid,mo,rec.primaryaccountid);
  
  
  --insert into missing_modality values (rec.id,mo,rec.primaryaccountid);
  
  end if;
  
  end loop;
  
  
  
end loop;

end;

/

select * from legacy_clinic;

select * from clinic_modality;

select * from missing_modality;


drop table missing_modality;

create table missing_modality
(
clinicid number
,modalitytypeid smallint
,primaryaccountid number
);

select * from clinic_modality
where primaryaccountid IN
(select primaryaccountid from CM_OWNER.MISSING_MODALITY)
and modalitytypeid < 4;

select m.* from missing_modality m 
left outer join clinic_modality mm ON mm.clinicid = m.clinicid and m.MODALITYTYPEID = mm.MODALITYTYPEID;

select c.id,m.*,t1.primaryaccountid from missing_modality m
join clinic c ON c.id = m.clinicid
join clinic_detail cd ON cd.clinic_id = c.id
join clinic_modality cm ON cm.clinicid = m.clinicid
join (select primaryaccountid from missing_modality a
join clinic_modality b ON b.clinicid = a.clinicid) t1 ON t1.primaryaccountid = cm.PRIMARYACCOUNTID ;

select * from clinic_modality_type;

/

-- SAP fix

--select *
--from cm_owner.clinic_supply
update cm_owner.clinic_supply set ordermethodid=1
where accountnumber is not null
and ordermethodid=0;