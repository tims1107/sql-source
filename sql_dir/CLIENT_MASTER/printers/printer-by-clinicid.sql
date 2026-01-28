select  p.printername,p.printerip,t.label,t.value printertype from clinic_printer p
join printer_type t ON t.printertypeid = p.printertypeid
where clinicid IN
(select id from clinic where hlabnumber = 'A116944');