select * from npi_registry_lookup
where npi IN ('1114903762',
'1467912709');

update npi_registry_lookup
set countrycode = 'US',countryname = 'United States'
where npi IN ('1174974398',
'1467912709');


select countrycode,countryname from npi_registry_lookup
group by countrycode,countryname;

select log_npi from
(select l.npi log_npi,r.npi reg_npi from results_sent_log l
full outer join npi_registry_lookup r ON r.npi = l.npi
where l.npi is null
and l.last_update_time > sysdate -30) res
group by log_npi;

select * from npi_registry_lookup r
order by createdat desc;

select * from results_sent_log
where last_update_time > sysdate - 60
and npi is null;

select * from results_sent_log
where npi is null
and last_update_time > sysdate -30;

select * from asr_process_run
where order_number = '2441RN4';

create table npi_registry_lookup_20250710
as
select * from npi_registry_lookup;

select * from npi_registry_lookup
where npi = '1114903762';

update npi_registry_lookup
set lname = 'Testing update',addr2= null
where npi = '1114903762';


delete npi_registry_lookup
where npi = '8888888888';