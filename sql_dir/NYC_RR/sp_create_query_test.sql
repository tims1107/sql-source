select
                       *
                from
                       dl_all_patients
                where
                       state = 'NY'
                       and zip in (
                         select
                            *
                         from
                            WH_TRACK.DL_ZIP_CODE
                         where
                            state_abbrev = 'NY'
                            and county in ('New York','Bronx','Kings','Queens','Richmond') ; 
                            
select p.* from RESULT_REPUSER.fact_results r
join result_repuser.dim_patient p ON p.patient_pk = r.patient_fk
where requisition_id = '8421CB6'
and compound_test_code = '525';



select
                       *
                from
                       dl_all_patients
                       where eid = '8001785782';
                       
select * from nyc_re