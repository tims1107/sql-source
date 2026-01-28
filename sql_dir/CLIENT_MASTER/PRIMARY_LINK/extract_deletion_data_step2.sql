declare 
  v_statusid number;
  v_reason varchar2(64) := 'Associate Primary';

begin

for rec IN (select hlabnumber,primaryaccount,statusid,servicelabid,typeofserviceid
from clinic c 
join clinic_detail cd ON cd.clinic_id = c.id
where c.hlabnumber = cd.primaryaccount and cd.typeofserviceid = 1
)
loop
    
  for assoc IN (
  select id,clinicdetailid,primaryaccount,hlabnumber,servicelabid,statusid,typeofserviceid,modalityid
from clinic c 
join clinic_detail cd ON cd.clinic_id = c.id
where primaryaccount = rec.primaryaccount)
loop 
    
        insert into clinic_remove_draw_0409 (id,clinicdetailid,primaryaccount,hlabnumber,servicelabid,statusid,typeofserviceid,modalityid,removedate,reason)
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
            
            
        dbms_output.put_line(assoc.primaryaccount || ' ' || assoc.hlabnumber || ' ' || assoc.servicelabid || ' ' || assoc.statusid || ' ' || assoc.typeofserviceid );
    
end loop;

end loop;


end;

/

select * from clinic_comment_line where cliniccommentid = 1063598;
select * from clinic_comments where comment_id = 1063598;

select * from CM_OWNER.CLINIC_REMOVE_WEST_LAB;

create table clinic_remove_overflow_0410
(
 id number
,clinicdetailid number
,primaryaccount varchar2(16)
,hlabnumber varchar2(16)
,servicelabid number
,statusid number
,typeofserviceid number
,modalityid number
,removedate timestamp(6)
,reason varchar2(64)
);

select a.ts,a.old_v,a.new_v,r.* from gen_audit a
join clinic_remove_diff r ON r.id = a.pk 
  
where tab IN ('CLINIC')
--and col IN ('STATUSID')
and op = 'U'
order by pk,ts;

update clinic_detail
set statusid = 8
where clinicdetailid = 604221;

select cd.* from clinic c
join clinic_detail cd ON cd.clinic_id = c.id
where hlabnumber = 'A103147';


select * from clinic_remove_diff
where statusid = 1;

delete clinic_remove_diff;

select hlabnumber,primaryaccount,servicelabid,statusid,typeofserviceid
from clinic c 
join clinic_detail cd ON cd.clinic_id = c.id
where primaryaccount IN ('A118608');