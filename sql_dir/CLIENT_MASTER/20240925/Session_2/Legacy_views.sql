select * from plac_printers
where plac_reportable = 'Y';
where hlab_num = 'A111660';

select hlab_num hlabnumber,facility_num accountnumber,alert_printer alertprinter
,alert_fax alertfax 
from plac_printers
where plac_reportable = 'Y';

select * from eastadd_info
where hlab_num = 'A124516';

select * from vw_plac;
select * from vw_ensemblenew;