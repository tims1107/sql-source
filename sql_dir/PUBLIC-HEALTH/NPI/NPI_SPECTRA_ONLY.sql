select * from npi_registry_lookup
where npi = '1861471591';

update npi_registry_lookup
set lname = 'BARON',fname='JOHN'
where npi = '1861471591';


select * from npi_spectra_only
where npi = '1861471591';

insert into npi_spectra_only (NPI,lastname,firstname,credentials)  values ( '1861471591','BARON','JOHN','DR');