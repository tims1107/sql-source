select * from npi_registry_lookup
where npi = '1366856130';

select * from npi_spectra_only
where npi = '1366856130';


Insert into NPI_SPECTRA_ONLY (NPI,LASTNAME,FIRSTNAME,CREDENTIALS) values ('1366856130','KADHEM','SALAM','MD');

select * from asr_process_run
where activitydate = trunc(sysdate )
--order by source;
and order_test_code = '332';

select * from asr_process_run
where activitydate = trunc(sysdate - 1)
and source = 'IL'
and order_test_code = '318';
