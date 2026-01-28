select tab
    ,decode(servicelabid,1,'SPECTRA-EAST',3,'SPECTRA-SOUTH','SPECTRA-WEST') servicelab,op,c.hlabnumber,clinicname,ts,old_value,new_value from clinic_detail cd 
join clinic c ON c.id = cd.clinic_id
join 
(select a.*,os.value old_value,ns.value new_value from gen_audit a
left outer join clinic_status os ON os.statusid = to_number(a.old_v)
left outer join clinic_status ns ON ns.statusid = to_number(a.new_v)
where tab = 'CLINIC_DETAIL'
and col = 'STATUSID'
--and ts > sysdate -45
and pk = 613393) t1 ON t1.pk = cd.clinicdetailid
order by ts ;

select a.*,os.value old_value,ns.value new_value from gen_audit a
left outer join clinic_status os ON os.statusid = to_number(a.old_v)
join clinic_status ns ON ns.statusid = to_number(a.new_v)
where tab = 'CLINIC_DETAIL'
and col = 'STATUSID'
--and ts > '30-APR-25 11.59.48.448653000 PM'
and pk = 613393; 

select * from clinic_detail
where clinic_id IN
(select id from clinic where hlabnumber = 'A116661');

