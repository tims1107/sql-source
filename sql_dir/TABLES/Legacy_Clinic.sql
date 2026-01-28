drop table legacy_clinic;

drop table legacy_clinic;

create table legacy_clinic
(tableflag varchar2(1)
,hlabnumber varchar2(16)
,accountnumber varchar2(16)
,clinicalmgr varchar2(400)
,medicaldir varchar2(400)
,facilitymgr varchar2(40)
,salesrep varchar2(20)
,clinicalrep varchar2(20)
,corpacronym varchar2(20)
,corpgroupname varchar2(50)
,primaryaccount varchar2(7)
,primaryname varchar2(50)
,accountstatus varchar2(15)
,accounttype varchar2(15)
,accountcategory varchar2(30)
,typeofservice varchar2(15)
,intextstudy varchar2(1)
,hemocount number
,pdcount number
,hhcount number
,physadd1 varchar2(100)
,physadd2 varchar2(100)
,physcity varchar2(30)
,physstate varchar2(2)
,physzip varchar2(10)
);

/


-- clear tables
declare
  row_count NUMBER;

begin
  delete legacy_clinic;
  row_count := SQL%ROWCOUNT;
  
  dbms_output.put_line(row_count);
  
  if(row_count > 0) then
  commit;
  end if;
  
  delete plac_printer_load;
  
  row_count := SQL%ROWCOUNT;
  dbms_output.put_line(row_count);
  
  if(row_count > 0) then
  commit;
  end if;
  
   delete clinic_open_close;
  
  row_count := SQL%ROWCOUNT;
  dbms_output.put_line(row_count);
  
  if(row_count > 0) then
  commit;
  end if;
  
end;

/

select * from printer_type;

/
select * from
(select c.hlabnumber ,decode(servicelabid,1,'E',2,'W',3,'S') servicelab
,row_number() over (partition by clinicid ,printertypeid order by clinicid, printertypeid) as rn
,p.printername
,decode(printertypeid,7,'ROCKLEIGH',3,'SOUTHAVEN') printertype
,printerip
,printerfax
,alertfax from clinic_printer p
join clinic c ON c.id = p.clinicid
join clinic_detail cd ON cd.clinic_id = c.id
and printertypeid in (3,7)
) t1
where rn =3
order by hlabnumber;
/

delete clinic_printer

where clinicprinterid IN

(select clinicprinterid from
(select c.hlabnumber ,decode(servicelabid,1,'E',2,'W',3,'S') servicelab
,row_number() over (partition by clinicid ,printertypeid order by clinicid, printertypeid) as rn
,p.* from clinic_printer p
join clinic c ON c.id = p.clinicid
join clinic_detail cd ON cd.clinic_id = c.id
and printertypeid in (3,7)
) t1
where rn =2);

order by clinicid;
/

select * from legacy_clinic;

select * from CM_OWNER.PLAC_PRINTER_LOAD;

select * from CM_OWNER.CLINIC_OPEN_CLOSE;