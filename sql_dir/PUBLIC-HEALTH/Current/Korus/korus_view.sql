select count(*) from korus2xprod_own.KORUS_PRINTER_LIST_VIEW
where hlab_num is null;

select hlab_num,printer_name,ip_address,printer_type,count(1) from korus2xprod_own.KORUS_PRINTER_LIST_VIEW
group by hlab_num,printer_name,ip_address,printer_type;

select* from korus2xprod_own.KORUS_PRINTER_LIST_VIEW
where hlab_num = 'A100757';