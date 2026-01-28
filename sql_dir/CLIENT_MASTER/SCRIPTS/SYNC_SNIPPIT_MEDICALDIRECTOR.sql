 select v_clinicdetail.clinicdetailid,v_clinicdetail.hlabnumber,lc.tableflag,lc.MEDICALDIR l_medicaldir,v_clinicdetail.medicaldirector cm_medicaldir from legacy_clinic lc
  join (select c.hlabnumber,decode(servicelabid,1,'E',2,'W',3,'S') tableflag,p.* from P_VW_CLINICDETAIL p
  join p_vw_clinic c ON c.id = p.clinicid where statusid = 1) v_clinicdetail ON v_clinicdetail.hlabnumber = lc.hlabnumber
  and lc.tableflag = v_clinicdetail.tableflag
  where upper(lc.MEDICALDIR) not like upper(v_clinicdetail.medicaldirector); 
  
  select * from p_vw_clinicdetail;
  
  /
  
  declare v_email varchar2(255) := 'tsmithers@spectraeastnj.com';
    v_componentid NUMBER := 3;
   v_changetypeid NUMBER := 4;
  
  begin
  
  for rec IN (select v_clinicdetail.clinicdetailid,v_clinicdetail.hlabnumber,lc.tableflag,lc.MEDICALDIR l_medicaldir,v_clinicdetail.medicaldirector cm_medicaldir from legacy_clinic lc
    join (select c.hlabnumber,decode(servicelabid,1,'E',2,'W',3,'S') tableflag,p.* from P_VW_CLINICDETAIL p
    join p_vw_clinic c ON c.id = p.clinicid where statusid = 1) v_clinicdetail ON v_clinicdetail.hlabnumber = lc.hlabnumber
      and lc.tableflag = v_clinicdetail.tableflag
      where upper(lc.MEDICALDIR) not like upper(v_clinicdetail.medicaldirector))
    loop
    
  
  update	CLINIC_DETAIL
        set medicaldirector = rec.cm_midicaldir
   where
      clinicdetailid = rec.clinicdetailid;

        -- clinic_change_history
        insert into clinic_change_history values (cm_change_queue_seq.nextval,v_email,rec.clinicdetailid,GEN_AUDIT$SEQ.currval,systimestamp);

        -- cm_change_queue - clinicinfo
        insert into cm_change_queue values (cm_change_seq.nextval,v_componentid,rec.clinicdetailid,v_changetypeid,sysdate,'ADMIN',null);
    
    end loop;
    
end;

/

select * from vw_upd_supply;