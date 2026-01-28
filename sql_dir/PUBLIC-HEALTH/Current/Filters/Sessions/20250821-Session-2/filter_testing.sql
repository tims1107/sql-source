-- Create comprehensive results view that includes patient and staff data
-- This view combines results with patient information, falling back to staff data when patient not found

CREATE OR REPLACE VIEW VW_RESULTS_PATIENT_STAFF AS
SELECT 
    re.result_test_code,
    lod.test_category,
    COALESCE(dp.patient_pk, ds.staff_pk) as patient_pk,
    COALESCE(dp.first_name, ds.first_name) as first_name,
    COALESCE(dp.last_name, ds.last_name) as last_name,
    COALESCE(dp.race, ds.race) as race,
    COALESCE(dp.ethnicity, ds.ethnicity) as ethnicity,
    COALESCE(dp.state, 'NA') as state,
    COALESCE(dp.dob, ds.dob) as dob,
    CASE WHEN dp.patient_pk IS NOT NULL THEN 'PATIENT' ELSE 'STAFF' END as source_type,
    lo.requisition_id,
    re.result_status,
    re.last_updated_date,
    re.performing_lab,
    re.textual_result_full,
    re.result_comment,
    re.order_test_code,
    lo.initiate_id
        
    
FROM ih_dw.results re 
JOIN ih_dw.dim_lab_order lo ON lo.requisition_id = re.requisition_id 
    AND re.LAB_ORDER_FK = lo.LAB_ORDER_PK
JOIN ih_dw.dim_lab_order_details lod ON lod.lab_order_fk = lo.lab_order_pk 
    AND re.LAB_ORDER_DETAILS_FK = lod.LAB_ORDER_DETAILS_PK
JOIN IH_DW.SPECTRA_MRN_ASSOCIATIONS asso ON lo.SPECTRA_MRN_ASSC_FK = asso.SPECTRA_MRN_ASSC_pk
LEFT JOIN ih_dw.dim_patient dp ON dp.SPECTRA_MRN_FK = asso.SPECTRA_MRN_fK 
    AND dp.FACILITY_FK = asso.FACILITY_fK
LEFT JOIN ih_dw.dim_staff ds ON ds.SPECTRA_MRN_FK = asso.SPECTRA_MRN_fK 
    AND ds.FACILITY_FK = asso.FACILITY_fK
    AND dp.patient_pk IS NULL;  -- Only join staff when patient not found

select * from VW_RESULTS_PATIENT_STAFF
where last_updated_date > trunc(sysdate)
and requisition_id = '6076CX8';

select * from ih_dw.dim_patient
where patient_pk = 67042194;


select * from
(select CASE 
        WHEN state IS NULL THEN 'NULL'
        WHEN TRIM(state) = '' THEN 'EMPTY_STRING'
        WHEN LENGTH(TRIM(state)) = 0 THEN 'WHITESPACE_ONLY'
        WHEN state = '""' then 'QUOTES'
        ELSE state
    END AS state_category,
    state,
    result_test_code,
    requisition_id
    from VW_RESULTS_PATIENT_STAFF ps
where last_updated_date > trunc(sysdate) -- this can be any timestamp
and order_test_code IN ('301')
and result_status = 'F')
--order by state_category
where state_category IN ('NULL','EMPTY STRING','WHITESPACE_ONLY','QUOTES')
;

/

select complete,count(1) from asr_process_run
group by complete
order by complete;

select * from asr_process_run
where complete = 'F';

delete asr_process_run
--delete asr_process_run_20250812
where complete IN ('F','L')
and activitydate = '12-AUG-25';

select * from VW_RESULTS_PATIENT_STAFF
where last_updated_date > trunc(sysdate);


create table asr_process_run_20250812_bak
as
select * from asr_process_run;



select * from asr_process_run_20250812_bak
where activitydate = '12-AUG-25';
select * from asr_process_run_20250812_2
where activitydate = '12-AUG-25'
and complete not in ('L','F');

delete asr_process_run
where activitydate = '12-AUG-25';

insert into asr_process_run
select * from asr_process_run_20250812_2
where activitydate = '12-AUG-25';

select a.*,substr(r.result_comment,1,50) comments from asr_process_run a
join ih_dw.results r ON r.requisition_id = a.order_number and r.result_test_code = a.result_test_code
where activitydate = '12-AUG-25'
--and a.complete  in ('L')
and a.order_number IN ('6118HZ8',
'61493B8')
and a.result_test_code IN ('310','310A')
and source  in ('IL');



update asr_process_run
set complete='L'
where activitydate='12-AUG-25'
and complete IN ('F');



select * from asr_process_run_20250812;
select * from asr_process_run
where complete = 'L'
--and order_test_code = '310'
and activitydate = '12-AUG-25'
and result_test_code IN ('110','111','113')
and source NOT IN ('NY','IL')
--and source  in ('""','NA')
--and textual_result_full = 'Nonreactive'
order by order_test_code,order_number;

select a.*,substr(result_comment,1,50) comments from asr_process_run a
join ih_dw.results r ON r.requisition_id = a.order_number
    and r.result_test_code = a.result_test_code
    
where activitydate='12-AUG-25'
and complete IN ('L')
and a.order_test_code IN ('310','301')
and  regexp_like(source,'^(TX)$')
order by a.order_number,a.order_test_code;

select a.*,substr(result_comment,1,50) comments from asr_process_run a
join ih_dw.results r ON r.requisition_id = a.order_number
    and r.result_test_code = a.result_test_code
    
where activitydate='12-AUG-25'
and complete IN ('L')
and a.order_test_code IN ('111')
and  regexp_like(source,'^(NY)$')
order by a.order_number,a.order_test_code;

select * from asr_process_run
where order_number IN
(select order_number from asr_process_run_20250812_bak
where activitydate = '12-AUG-25'
and complete='D')
and result_test_code = '111'
and complete = 'F';

create table asr_process_run_20250813
as 
select * from asr_process_run;

create table asr_process_run_20250812_bak
as
select * from asr_process_run;

select * from asr_process_run_20250812_bak
where activitydate='12-AUG-25';

select source,result_test_code,complete,count(1) from asr_process_run
where activitydate='14-AUG-25'
and complete IN ('L','F')
and source like 'NY'
group by source,result_test_code,complete
order by source,result_test_code;

select source,a.result_test_code,a.textual_result_full,complete,substr(result_comment,1,50) comments from asr_process_run a
join ih_dw.results r ON r.requisition_id = a.order_number and r.result_test_code = a.result_test_code
--where source = 'NY'
where activitydate = '14-AUG-25'
and source = 'NY'
and complete = 'L';
--and r.result_test_code IN ('310','311R');
--and regexp_like(r.textual_result_full,'Positive','i');

delete asr_process_run;

insert into asr_process_run
select * from asr_process_run_20250812_bak;

select order_number from asr_process_run_20250812_bak
where activitydate = '12-AUG-25'
and complete = 'R';



select * from asr_process_run_20250812_bak
where source = 'CA'
and order_test_code IN ('310')
and activitydate='12-AUG-25'
and complete IN ('R','S');

create table asr_process_run_20250812_2
as 
select * from asr_process_run;

--delete asr_process_run
--where activitydate= '12-AUG-25';

select * from asr_process_run
where activitydate= '12-AUG-25';

select a.source,a.order_number,a.complete,p.complete,a.result_test_code,a.textual_result_full from asr_process_run_20250812_2 a
join asr_process_run p ON p.order_number = a.order_number
    and p.result_test_code = a.result_test_code
where a.activitydate = '12-AUG-25'
and a.complete = 'L'
order by a.source,a.result_test_code;


select * from patientmaster 
where eid IN
(select initiate_id from ih_dw.dim_lab_order
where requisition_id IN ('26512Z4','6146YF8','6404ZF8'));

select * from dl_zip_code
where zip = '33160';

select * from asr_process_run
where activitydate = '12-AUG-25'
and order_test_code = '310'
order by order_test_code,order_number;

delete asr_process_run
where complete = 'L';

insert into asr_process_run
select * from asr_process_run_20250812;

drop table asr_compare_run;

create table asr_compare_run
as
select * from asr_process_run
where complete IN ('L')
order by source,order_number;

select * from asr_compare_run
where order_number IN
(select order_number from asr_process_run
where activitydate = '12-AUG-25')
and result_test_code NOT IN ('110','113')
--and source = 'NY'
and complete = 'L'
order by source;

select * from asr_process_run
where activitydate='11-AUG-25'
and source='NY'
order by source;



delete asr_process_run
where source not IN ('NY')
and result_test_code IN ('111','110','113')
and complete = 'L';

delete asr_process_run
where textual_result_full IN ('Negative','Nonreactive')
and activitydate = '12-AUG-25'
and complete IN ('L');







