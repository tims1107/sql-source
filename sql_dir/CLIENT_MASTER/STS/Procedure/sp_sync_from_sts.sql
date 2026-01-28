select * from cm_change_queue
order by cmpostdate desc;

select * from cm_change_types
where changetypeid IN (6,9);


    insert into cm_change_queue values (cm_change_seq.nextval,v_componentid,p_clinicsupplyid,v_changetypeid,sysdate,'SYNCDATA',null);

v_componentid NUMBER := 8;
   v_changetypeid NUMBER := 9;
   
/

create or replace procedure sp_sync_from_sts
(
  p_hlabnumber IN clinic.hlabnumber%type,
  p_accountnumber IN clinic_supply.accountnumber%type
  
)
as

  v_componentid NUMBER := 8;
   v_changetypeid NUMBER := 9;
   p_clinicsupplyid number;
   v_id number;
   
begin
  
  select cs.clinicsupplyid,c.id into p_clinicsupplyid,v_id from clinic c
  join clinic_supply cs ON cs.clinicid = c.id
  where hlabnumber = p_hlabnumber;
  
  update clinic_supply
  set ACCOUNTNUMBER = p_accountnumber
  where clinicsupplyid = p_clinicsupplyid;
  
  commit;
  
  insert into cm_change_queue values (cm_change_seq.nextval,v_componentid,p_clinicsupplyid,v_changetypeid,sysdate,'SYNCDATA',null);
  
  commit;


end;