create table test_table
as
select ' ' testfield from dual;
/
create table patientmaster_nc
as
select * from patientmaster_test
where state = 'IL';

select * from patientmaster_il;
--insert into asr_process_run
--select order_number,order_test_code,result_test_code,performing_lab_id,textual_result_full,patient_last_name,'IL' source,to_char(sysdate,'dd-MON-rr') activitydate,'N' complete from 
--(
drop table micro_test_case;

create table micro_messages_nc
as select * from micro_test_messages;

delete micro_test_messages;
delete micro_messages_nc;

select * from asr_process_run
where order_test_code = '750B';

select * from micro_messages_nc
where order_test_code = '775';

select * from patientmaster_nc;

/
insert into micro_messages_nc
/
select * from
(select
                        distinct(re.ACCESSION_NUMBER) accession_no,
                        f.FACILITY_ID,
                        a.CID,
                        dp.ethnicity ethnic_group,
                        dp.RACE patient_race,
                        lo.EXTERNAL_MRN mrn,
                       
                        nvl(p.lname, '') PATIENT_LAST_NAME,
                        nvl(p.fname, '') PATIENT_FIRST_NAME,
                        --p.mname PATIENT_MIDDLE_NAME,
                        (
                          CASE
                            WHEN p.mname is null THEN null
                            WHEN upper(p.mname) = 'NULL' THEN null
                            ELSE p.mname
                          END
                        ) PATIENT_MIDDLE_NAME,          
                        --to_date(p.DOB, 'YYYY-MM-DD') date_of_birth,
                        (
                          CASE
                            WHEN p.DOB is null THEN null
                            WHEN test_date(p.DOB) = 'Valid' THEN
                              (
                                CASE 
                                  WHEN (EXTRACT(YEAR FROM sysdate) - to_number(SUBSTR(replace(p.DOB, '-'), 1, 4))) <= 0 THEN NULL 
                                  ELSE to_date(p.DOB, 'YYYY-MM-DD')
                                END
                              )
                            ELSE NULL	
                          END
                        ) date_of_birth,          
                        p.sex gender,
                        p.ssn patient_ssn,
                        --dph.NPI,
                        --dph.PHYSICIAN_NAME ordering_physician_name,
                        lo.ordering_physician_npi NPI,
                        lo.ordering_physician_name ordering_physician_name,          
                        lod.REPORT_NOTES,
                        lod.SPECIMEN_RECEIVED_DATE_TIME specimen_receive_date,
                        lod.COLLECTION_DATE collection_date,
                        lod.COLLECTION_TIME collection_time,
                        lod.COLLECTION_DATE_TIME,
                        lod.DRAW_FREQUENCY draw_freq,
                        lod.RESULT_RPT_CHNG_DATE_TIME res_rprt_status_chng_dt_time,
                        lod.ORDER_DETAIL_STATUS,
                        re.ORDER_TEST_CODE,
                        re.ORDER_TEST_NAME,
                        re.RESULT_TEST_CODE,
                        re.RESULT_TEST_NAME,
                        re.RESULT_STATUS,
                        re.TEXTUAL_RESULT,
                        re.TEXTUAL_RESULT_FULL,
                        re.NUMERIC_RESULT,
                        re.UNIT_OF_MEASURE units,
                        re.REFERENCE_RANGE,
                        re.ABNORMAL_FLAG,
                        re.RELEASE_DATE_TIME,
                        trim(dbms_lob.substr( re.RESULT_COMMENT, 4000, 1 )) as RESULT_COMMENTS,
                        re.PERFORMING_LAB performing_lab_id,
                        --'SE' performing_lab_id,
                        lod.TEST_CATEGORY order_method,
                        lod.specimen_source_code specimen_source,
                        re.REQUISITION_ID order_number,
                        dl.LAB_ID logging_site,
                        (
                          CASE
                            WHEN p.DOB is null THEN 0
                            WHEN test_date(p.DOB) = 'Valid' THEN
                              (
                                CASE 
                                  WHEN (EXTRACT(YEAR FROM sysdate) - to_number(SUBSTR(replace(p.DOB, '-'), 1, 4))) <= 0 THEN 0 
                                  ELSE trunc(months_between(sysdate, to_date(p.DOB, 'YYYY-MM-DD'))/12)
                                END
                              )
                            ELSE NULL	
                          END
                        ) age,
                        f.DISPLAY_NAME facility_name,
                        lod.specimen_method_code cond_code,
                        lo.PATIENT_TYPE,
                        lod.ORDER_OCCURRENCE_ID source_of_comment,
                        lo.INITIATE_ID	patient_id,
                        lo.ALTERNATE_PATIENT_ID,
                        lo.REQUISITION_STATUS,
                        f.ADDRESS_LINE1 facility_address1,
                        f.ADDRESS_LINE2 facility_address2,
                        f.CITY facility_city,
                        f.STATE facility_state,
                        f.ZIP facility_zip,
                        f.PHONE_NUMBER facility_phone,
                        p.stline1 patient_account_address1,
                        p.stline2 patient_account_address2,
                        p.CITY patient_account_city,
                        p.STATE patient_account_state,
                        p.zipcode patient_account_zip,
                        --p.phnumber patient_home_phone,
                    (
                       CASE
                         WHEN p.phnumber is null THEN null
                         WHEN length(p.phnumber) > 10 THEN substr(p.phnumber, ((length(p.phnumber) - 10) + 1))
                         ELSE p.phnumber
                       END
                     ) patient_home_phone, 
                     (case when re.loinc_code is null and re.order_test_code = '336' then '48345-3' 
                            when re.loinc_code is null and re.order_test_code = '332' then '94309-2' 
                            when re.loinc_code is null and re.order_test_code = '331' then '96119-3' else re.loinc_code end) 
                            loinc_code ,
                    ( case when re.loinc_name is null and re.order_test_code = '336' then 'HIV 1+O+2 Ab:PrThr:Pt:Ser/Plas:Ord' 
                            when re.loinc_name is null and re.order_test_code = '332' then 'SARS coronavirus 2 RNA:PrThr:Pt:XXX:Ord:Probe.amp.tar' 
                            when re.loinc_name is null and re.order_test_code = '331' then 'SARS coronavirus 2 Ag:PrThr:Pt:Respiratory.upper:Ord:IA'else re.loinc_name end
                    ) loinc_name,
                        re.VALUE_TYPE,
                        f.EAST_WEST_FLAG,
                        f.INTERNAL_EXTERNAL_FLAG,
                        re.LAST_UPDATED_DATE last_update_time,
                        re.RESULT_SEQUENCE sequence_no,
                        f.ACCOUNT_STATUS facility_account_status,
                        f.FACILITY_ACTIVE_FLAG,
                        re.MICRO_ISOLATE,
                        re.MICRO_ORGANISM_NAME,
                        re.lab_fk,
                        f.CLINICAL_MANAGER,
                        dl.MEDICAL_DIRECTOR,
                        f.FACILITY_ID acti_facility_id,
                        f.FMC_NUMBER,
                        null reportable_state,
                        'patient' source_state,
                        re.observation_method device_name             
                      from
                        (
--                          select
--                            r.*
--                          from
--                            IH_DW.RESULTS r,
--                            (
                            select
                            r.*
                          from
                           

                               --ih_dw.dw_ods_activity act
                               ih_dw.results r 
                               where requisition_id = '0535H47'
                              and regexp_like(micro_organism_name,'^Enterobacter cloacae$','i')
                              and result_sequence > 2
                              -- where r.requisition_id = '2109VZ7'

                                
                               --and regexp_like(r.result_test_code,'310|310A','i')
                              --join ih_dw.results r ON r.requisition_id = act.requisition_id
                              --where act.requisition_id  = '2487UJ7'
                              --  ('11928A4','2487UJ7')
                              --and r.result_test_code = '525'


                        ) re,
                        IH_DW.DIM_LAB_ORDER lo,
                        IH_DW.DIM_LAB_ORDER_DETAILS lod,
                        STATERPT_OWNER.patientmaster p,
                        --staterpt_owner.gtt_pm p,
                        IH_DW.DIM_ACCOUNT a,
                        IH_DW.DIM_FACILITY f,
                        --IH_DW.DIM_PHYSICIAN dph,
                        IH_DW.DIM_LAB dl,
                        IH_DW.DIM_PATIENT dp,
                        IH_DW.SPECTRA_MRN_ASSOCIATIONS asso	
                      where
                        lo.requisition_id = re.requisition_id
                        and re.LAB_ORDER_FK = lo.LAB_ORDER_PK
                        and lo.initiate_id = p.eid
                        and p.lab_fk = re.lab_fk
                        and re.LAB_ORDER_DETAILS_FK = lod.LAB_ORDER_DETAILS_PK(+)
                        and lo.LAB_ORDER_PK = lod.LAB_ORDER_FK
                        and lo.account_fk = a.account_pk	
                        and a.facility_fk = f.facility_pk
                        --and lo.ORDERING_PHYSICIAN_NPI = dph.NPI
                        and re.lab_fk = dl.lab_pk(+)
                        and lo.lab_fk = dl.lab_pk
                        and lo.SPECTRA_MRN_ASSC_FK = asso.SPECTRA_MRN_ASSC_pk(+)
                        and dp.SPECTRA_MRN_FK = asso.SPECTRA_MRN_fK 
                        -- comment to insert
                        --and dp.FACILITY_FK = asso.FACILITY_fK;
                        
                        -- uncomment to insert
                        and dp.FACILITY_FK = asso.FACILITY_fK);
                        --and regexp_like(result_test_name,'isolate','i'));
                        --and lod.TEST_CATEGORY in ('IMMUNO','IMMUN','PCR','ARUP','CHEM','MICRO');
                        --and lod.TEST_CATEGORY in ('IMMUNO','IMMUN','PCR','ARUP','HEMA');
                        --and p.state = p_state;
                        --and p.state in (p_state);
                        --and p.state in ('TX','AZ','CA','PA','OR','FL','WA');
                        --and p.state = 'CA';
                        
/

select order_number,order_test_name,f.LOINCCODE,f.LOINCNAME,spm.snomedcode specimen_code,spm.PREFERREDNAME specimen_name
,org.snomedcode organism_code,org.PREFERREDNAME organism_name
from micro_messages_nc n
join micro_organism_filter f ON f.organismname = n.MICRO_ORGANISM_NAME
join snomed_master spm ON spm.specimen_source_code = n.specimen_source
join snomed_master org ON org.localname = n.micro_organism_name
;

create table patientmaster_test
as
/
insert into patientmaster_nc
select * from patientmaster
where eid = '8001799981';

select * from patientmaster_test;
update patientmaster_test
set stline1 = '1042 N MONTICELLO',stline2='Ste 1',city = 'CHICAGO',state= 'IL',zipcode = '60651'
,phnumber = '7732783481',dob='1947-07-10',ssn= '334565454';

select r.lab_fk,lo.INITIATE_ID from ih_dw.results r
join ih_dw.dim_lab_order lo ON lo.requisition_id = r.requisition_id
where r.requisition_id = '11927B4'
and order_test_code = '757';

select * from micro_messages_nc;

select * from patientmaster
where state = 'NC';

select * from patientmaster_nc;

update patientmaster_nc
set stline1 ='7328 BARHAM',city='WAKE FOREST',state='NC',zipcode = '27587',phnumber='9195541757',dob='1974-12-06',sex='F'
where eid = '8001799981';


Insert into PATIENTMASTER_NC (EID,MRN,LNAME,FNAME,MNAME,STLINE1,STLINE2,CITY,STATE,ZIPCODE,PHNUMBER,DOB,SSN,SEX,LAB_FK,TABLE_UPDATED) 
values ('8003576326','5001049690','AACUTE','ATEST',null,'94 UNION ST.','APT. 213','JERSEY CITY','NJ','07304','2016688329','1954-08-15',null,'F',5,to_date('24-AUG-24','DD-MON-RR'));

select * from patientmaster_nc
where eid = '8003576326';

insert into patientmaster_test
select * from patientmaster
where eid = '8003576326';
where state = 'IL';

update micro_test_messages
set source_state = 'patient',reportable_state = null;

commit;

select * from asr_process_run
where order_number IN
(select order_number from STATERPT_OWNER.RESULTS_SENT_LOG
where patient_account_state = 'IL'
and regexp_like(result_test_name, 'isolate','i'));

select * from asr_process_run
where order_number = '07735X7';

select * from STATERPT_OWNER.RESULTS_SENT_LOG
where order_number = '07735X7';


Insert into ASR_PROCESS_RUN (
ORDER_NUMBER
,ORDER_TEST_CODE
,RESULT_TEST_CODE
,PERFORMING_LAB_ID
,TEXTUAL_RESULT_FULL
,PATIENT_LAST_NAME
,SOURCE
,ACTIVITYDATE
,COMPLETE) 
values ('07735X7','525',525,'SE','6.8','RODRIGUEZ','NY','24-AUG-21','N');


select * from state_master
where state_abbreviation = 'NY';

select * from condition_master
where state_fk = 3;

update condition_master
set status = 'active',order_test_code = '525',result_test_code = null
,value_type = 'NM'
where condition_master_pk = 63;

select * from patientmaster
where eid = '8003085082';


/

STATERPT_OWNER.GTT_RESULTS_EXTRACT
                      select
                        distinct(re.ACCESSION_NUMBER) accession_no,
                        f.FACILITY_ID,
                        a.CID,
                        dp.ethnicity ethnic_group,
                        dp.RACE patient_race,
                        lo.EXTERNAL_MRN mrn,
                       
                        nvl(p.lname, '') PATIENT_LAST_NAME,
                        nvl(p.fname, '') PATIENT_FIRST_NAME,
                        --p.mname PATIENT_MIDDLE_NAME,
                        (
                          CASE
                            WHEN p.mname is null THEN null
                            WHEN upper(p.mname) = 'NULL' THEN null
                            ELSE p.mname
                          END
                        ) PATIENT_MIDDLE_NAME,          
                        --to_date(p.DOB, 'YYYY-MM-DD') date_of_birth,
                        (
                          CASE
                            WHEN p.DOB is null THEN null
                            WHEN test_date(p.DOB) = 'Valid' THEN
                              (
                                CASE 
                                  WHEN (EXTRACT(YEAR FROM sysdate) - to_number(SUBSTR(replace(p.DOB, '-'), 1, 4))) <= 0 THEN NULL 
                                  ELSE to_date(p.DOB, 'YYYY-MM-DD')
                                END
                              )
                            ELSE NULL	
                          END
                        ) date_of_birth,          
                        p.sex gender,
                        p.ssn patient_ssn,
                        --dph.NPI,
                        --dph.PHYSICIAN_NAME ordering_physician_name,
                        lo.ordering_physician_npi NPI,
                        lo.ordering_physician_name ordering_physician_name,          
                        lod.REPORT_NOTES,
                        lod.SPECIMEN_RECEIVED_DATE_TIME specimen_receive_date,
                        lod.COLLECTION_DATE collection_date,
                        lod.COLLECTION_TIME collection_time,
                        lod.COLLECTION_DATE_TIME,
                        lod.DRAW_FREQUENCY draw_freq,
                        lod.RESULT_RPT_CHNG_DATE_TIME res_rprt_status_chng_dt_time,
                        lod.ORDER_DETAIL_STATUS,
                        re.ORDER_TEST_CODE,
                        re.ORDER_TEST_NAME,
                        re.RESULT_TEST_CODE,
                        re.RESULT_TEST_NAME,
                        re.RESULT_STATUS,
                        re.TEXTUAL_RESULT,
                        re.TEXTUAL_RESULT_FULL,
                        re.NUMERIC_RESULT,
                        re.UNIT_OF_MEASURE units,
                        re.REFERENCE_RANGE,
                        re.ABNORMAL_FLAG,
                        re.RELEASE_DATE_TIME,
                        trim(dbms_lob.substr( re.RESULT_COMMENT, 4000, 1 )) as RESULT_COMMENTS,
                        re.PERFORMING_LAB performing_lab_id,
                        --'SE' performing_lab_id,
                        lod.TEST_CATEGORY order_method,
                        lod.SPECIMEN_METHOD_DESC specimen_source,
                        re.REQUISITION_ID order_number,
                        dl.LAB_ID logging_site,
                        (
                          CASE
                            WHEN p.DOB is null THEN 0
                            WHEN test_date(p.DOB) = 'Valid' THEN
                              (
                                CASE 
                                  WHEN (EXTRACT(YEAR FROM sysdate) - to_number(SUBSTR(replace(p.DOB, '-'), 1, 4))) <= 0 THEN 0 
                                  ELSE trunc(months_between(sysdate, to_date(p.DOB, 'YYYY-MM-DD'))/12)
                                END
                              )
                            ELSE NULL	
                          END
                        ) age,
                        f.DISPLAY_NAME facility_name,
                        null cond_code,
                        lo.PATIENT_TYPE,
                        lod.ORDER_OCCURRENCE_ID source_of_comment,
                        lo.INITIATE_ID	patient_id,
                        lo.ALTERNATE_PATIENT_ID,
                        lo.REQUISITION_STATUS,
                        f.ADDRESS_LINE1 facility_address1,
                        f.ADDRESS_LINE2 facility_address2,
                        f.CITY facility_city,
                        f.STATE facility_state,
                        f.ZIP facility_zip,
                        f.PHONE_NUMBER facility_phone,
                        p.stline1 patient_account_address1,
                        p.stline2 patient_account_address2,
                        p.CITY patient_account_city,
                        p.STATE patient_account_state,
                        p.zipcode patient_account_zip,
                        --p.phnumber patient_home_phone,
                    (
                       CASE
                         WHEN p.phnumber is null THEN null
                         WHEN length(p.phnumber) > 10 THEN substr(p.phnumber, ((length(p.phnumber) - 10) + 1))
                         ELSE p.phnumber
                       END
                     ) patient_home_phone, 
                     (case when re.loinc_code is null and re.order_test_code = '336' then '48345-3' 
                            when re.loinc_code is null and re.order_test_code = '332' then '94309-2' 
                            when re.loinc_code is null and re.order_test_code = '331' then '96119-3' else re.loinc_code end) 
                            loinc_code ,
                    ( case when re.loinc_name is null and re.order_test_code = '336' then 'HIV 1+O+2 Ab:PrThr:Pt:Ser/Plas:Ord' 
                            when re.loinc_name is null and re.order_test_code = '332' then 'SARS coronavirus 2 RNA:PrThr:Pt:XXX:Ord:Probe.amp.tar' 
                            when re.loinc_name is null and re.order_test_code = '331' then 'SARS coronavirus 2 Ag:PrThr:Pt:Respiratory.upper:Ord:IA'else re.loinc_name end
                    ) loinc_name,
                        re.VALUE_TYPE,
                        f.EAST_WEST_FLAG,
                        f.INTERNAL_EXTERNAL_FLAG,
                        re.LAST_UPDATED_DATE last_update_time,
                        re.RESULT_SEQUENCE sequence_no,
                        f.ACCOUNT_STATUS facility_account_status,
                        f.FACILITY_ACTIVE_FLAG,
                        re.MICRO_ISOLATE,
                        re.MICRO_ORGANISM_NAME,
                        re.lab_fk,
                        f.CLINICAL_MANAGER,
                        dl.MEDICAL_DIRECTOR,
                        f.FACILITY_ID acti_facility_id,
                        f.FMC_NUMBER,
                        null reportable_state,
                        null source_state,
                        re.observation_method device_name
                        
                      from
                        (
--                          select
--                            r.*
--                          from
--                            IH_DW.RESULTS r,
--                            (
                            select
                            r.*
                          from
                            asr_process_run proc
                            join IH_DW.DW_ODS_ACTIVITY act on act.requisition_id = proc.order_number
                            JOIN IH_DW.RESULTS r ON r.requisition_id = act.requisition_id
                            where r.result_test_code = proc.result_test_code and r.order_test_code = proc.order_test_code
                            and complete = 'N'

--                               ih_dw.dw_ods_activity act
--                              join ih_dw.results r ON r.requisition_id = act.requisition_id
--                              where act.requisition_id  IN
--                                ('7560X56','7530MN6','7560XY6','7672WV6','78387N6','7516B26','76693N6',
--                                '0916T94','74136H6','76656W6','7516B36','7838A56','7690A26','7530MB6')
--                              and r.result_test_code IN
--                              (select result_test_code from asr_process_run
--                              where order_number = act.requisition_id)
--                            
--                              select
--                                distinct(order_number)
--                              from
--                                asr_process_run
--                              where
--                            
--                             --requisition_id IN (select order_number from asr_process_run ar where complete = 'N' )
--                              
--                               -- ****
--                               order_number in (select order_number from asr_process_run r
--                                  --where to_date(activitydate,'dd-MON-yy') > sysdate - 3
--                                      --and source in ('CA','NJ','NY','OR','TX','IL','MD','CT','FL','DC','PA','GA','IN','NV','NM','NC','TN','MS','MN','OH','VA','LA','OK')
--                                        where complete = 'N')
--                              
--                                              
--      
--                            ) a
--                          where
--                            r.requisition_id = a.order_number
                        ) re,
                        IH_DW.DIM_LAB_ORDER lo,
                        IH_DW.DIM_LAB_ORDER_DETAILS lod,
                        STATERPT_OWNER.PatientMaster p,
                        --staterpt_owner.gtt_pm p,
                        IH_DW.DIM_ACCOUNT a,
                        IH_DW.DIM_FACILITY f,
                        --IH_DW.DIM_PHYSICIAN dph,
                        IH_DW.DIM_LAB dl,
                        IH_DW.DIM_PATIENT dp,
                        IH_DW.SPECTRA_MRN_ASSOCIATIONS asso	
                      where
                        lo.requisition_id = re.requisition_id
                        and re.LAB_ORDER_FK = lo.LAB_ORDER_PK
                        and lo.initiate_id = p.eid
                        and p.lab_fk = re.lab_fk
                        and re.LAB_ORDER_DETAILS_FK = lod.LAB_ORDER_DETAILS_PK
                        and lo.LAB_ORDER_PK = lod.LAB_ORDER_FK
                        and lo.account_fk = a.account_pk	
                        and a.facility_fk = f.facility_pk
                        --and lo.ORDERING_PHYSICIAN_NPI = dph.NPI
                        and re.lab_fk = dl.lab_pk
                        and lo.lab_fk = dl.lab_pk
                        and lo.SPECTRA_MRN_ASSC_FK = asso.SPECTRA_MRN_ASSC_pk
                        and dp.SPECTRA_MRN_FK = asso.SPECTRA_MRN_fK 
                        and dp.FACILITY_FK = asso.FACILITY_fK;
                       

/

select order_test_code,order_number,cond_code,specimen_source from micro_messages_nc;

select * from dl_zip_code;

update micro_messages_nc
set cond_code = null,specimen_source = 'BFL/ABDOMINAL FLUID'
where order_number = '11928K4';

select 
        *	
			from 
				--STATERPT_OWNER.TEMP_RESULTS_EXTRACT rs
        STATERPT_OWNER.GTT_RESULTS_EXTRACT rs
			where 
				--PATIENT_ACCOUNT_STATE = 'NY' 
        --PATIENT_ACCOUNT_STATE in (NY)
        --and accession_number in ( 
        accession_number in ( 
					select 
						distinct(r.accession_number)
					from 
						--STATERPT_OWNER.TEMP_RESULTS_EXTRACT r,
            STATERPT_OWNER.GTT_RESULTS_EXTRACT r,
						( 
							select 
								distinct(accession_number)
							from 
								--STATERPT_OWNER.TEMP_RESULTS_EXTRACT
                STATERPT_OWNER.GTT_RESULTS_EXTRACT
							where 
								order_test_code = '525'  and (upper(textual_result_full) LIKE upper('%'))) p   
					where 
						r.accession_number = p.accession_number  and r.order_test_code = '525'  and ((r.value_type = 'ST')) )  and rs.order_test_code = '525'   and (((rs.lab_fk = 6) and (rs.performing_lab_id like 'SE%' or rs.performing_lab_id like 'HE%')) or ((rs.lab_fk = 5) and (rs.performing_lab_id like 'SE%' or rs.performing_lab_id like 'HE%')) or ((rs.lab_fk = 5) and (rs.performing_lab_id = 'OUTSEND')))
