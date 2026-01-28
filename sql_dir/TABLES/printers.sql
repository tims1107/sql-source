delete clinic_printer;

commit;

select count(1) from clinic_printer;

select * from plac_printer_load
where (alertprinter is not null
or alertfax is not null); and length(regexp_replace(alertfax, '[\(\)-]','')) <> 10;

select * from clinic_printer
where createdby = 'PLAC';


--delete clinic_printer 

delete clinic_printer
where clinicprinterid IN
(select clinicprinterid from
(select clinicprinterid,row_number() over (partition by clinicid,createdby order by clinicid,createdby) as rn,clinicid,alertfax,createdby from clinic_printer
where printertypeid = 4
and alertfax is not null
and createdby = 'PLAC')
where rn > 1);

select * from clinic_printer
where rowid = 'AAAm62AAAAAAU+jAB3';

with cte AS (select * from (select row_number() over (partition by clinicid,createdby order by clinicid,createdby) as rn,clinicid,alertfax,createdby from clinic_printer
where printertypeid = 4
and alertfax is not null
and createdby = 'PLAC')
)
delete from cte
where rn > 1;

create table plac_printer_bak
as 
select * from clinic_printer
where printertypeid = 4;


/

declare type cm_printer_type IS RECORD (
  id number,
  hlabnumber varchar2(20),
  alertfax varchar2(20)
  );

v_updated number := 0;

type cm_printer_tab IS table of cm_printer_type;
cm_printer_rec cm_printer_tab;

CURSOR cm_printer_cur IS
  SELECT c.id,p.hlabnumber,regexp_replace(alertfax,'[-]','') alertfax
  FROM plac_printer_load p
  join clinic c ON c.hlabnumber = p.hlabnumber
  where ALERTFAX is not null;
  
begin 
  
  OPEN cm_printer_cur;
  
    FETCH cm_printer_cur BULK COLLECT INTO cm_printer_rec;
    FOR i IN 1..cm_printer_rec.count
     LOOP
    
    
    --dbms_output.put_line(cm_printer_rec(i).id || chr(9) || cm_printer_rec(i).hlabnumber || chr(9) || regexp_replace(cm_printer_rec(i).alertfax,'[-]',''));
    
    update clinic_printer cp
    set alertfax = cm_printer_rec(i).alertfax,createdby = 'PLAC'
    where clinicid = cm_printer_rec(i).id
    and printertypeid = 4;
    
    v_updated := sql%rowcount;
    if(v_updated > 1) then
      dbms_output.put_line(cm_printer_rec(i).id || chr(9) || cm_printer_rec(i).hlabnumber || chr(9) || regexp_replace(cm_printer_rec(i).alertfax,'[-]','') || chr(9) || v_updated);
    end if;
    
    
  end loop;
  close cm_printer_cur;
  

end;


/

select count(1) from CM_OWNER.CLINIC_OPEN_CLOSE;

delete clinic_open_close;

select * from clinic_printer p
join printer_type pt ON pt.printertypeid = p.printertypeid
where p.printertypeid = 4 
and ;

select * from ds_facility;

GRANT SELECT ON CM_OWNER.CLINIC_AH_SEQNO TO CM$READ;


