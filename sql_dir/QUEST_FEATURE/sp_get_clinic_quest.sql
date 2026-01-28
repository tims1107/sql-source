create or replace procedure sp_get_clinic_quest
(
 p_clinicid IN NUMBER,
 p_clinic_quest out sys_refcursor
)
as
begin

  open p_clinic_quest for 
  select 
    *
  from
    clinic_quest
  where clinicid = p_clinicid;

end;