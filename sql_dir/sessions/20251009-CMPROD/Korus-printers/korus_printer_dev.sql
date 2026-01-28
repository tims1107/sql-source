select * from korus_printer
where hlab_num = 'A116804';

select printer_type,count(1) from korus_printer
group by printer_type;

select * from clinic_printer
where clinicid = 536586;

select * from clinic
where hlabnumber = 'A116804';

delete korus_printer;