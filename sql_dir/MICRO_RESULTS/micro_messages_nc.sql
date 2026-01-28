/
insert into micro_messages_nc
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
                        'ANAER/Drainage' specimen_source,
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
                               where requisition_id = '9998SR6'
                               and regexp_like(result_test_name,'isolate','i')
                              --and regexp_like(micro_organism_name,'^Enterobacter cloacae$','i')
                              --and result_sequence > 2
                              
                              -- where r.requisition_id = '2109VZ7'

                                
                               --and regexp_like(r.result_test_code,'310|310A','i')
                              --join ih_dw.results r ON r.requisition_id = act.requisition_id
                              --where act.requisition_id  = '2487UJ7'
                              --  ('11928A4','2487UJ7')
                              --and r.result_test_code = '525'


                        ) re,
                        IH_DW.DIM_LAB_ORDER lo,
                        IH_DW.DIM_LAB_ORDER_DETAILS lod,
                         patientmaster_nc p,
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
                        and lo.initiate_id = p.eid(+)
                        and p.lab_fk = re.lab_fk
                        and re.LAB_ORDER_DETAILS_FK = lod.LAB_ORDER_DETAILS_PK(+)
                        and lo.LAB_ORDER_PK = lod.LAB_ORDER_FK
                        and lo.account_fk = a.account_pk	
                        and a.facility_fk = f.facility_pk
                        --and lo.ORDERING_PHYSICIAN_NPI = dph.NPI
                        and re.lab_fk = dl.lab_pk
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

select * from micro_messages_nc
where order_number = '9998SR6';

update micro_messages_nc
set micro_organism_name = 'Candida auris'
where order_number = '9998SR6'; 

update snomed_master

select * from ih_dw.results r
join ih_dw.dim_lab_order lo ON lo.requisition_id r.requisition_id
join patientmaster_il p ON p.eid = lo.initiate_id
where r.requisition_id = ;

insert into patientmaster_nc
select * from patientmaster
where eid = '8003936132';

select * from patientmaster_nc
where eid = '8003936132';

update patientmaster_nc
set lname = 'LTEST',fname = 'SANTEST'
where eid = '8003936132';

select * from patientmaster
where state = 'IL'
and rownum < 2;

delete patientmaster_il;

Insert into PATIENTMASTER_IL (EID,MRN,LNAME,FNAME,MNAME,STLINE1,STLINE2,CITY,STATE,ZIPCODE,PHNUMBER,DOB,SSN,SEX,LAB_FK,TABLE_UPDATED) values ('8003986798','5001030402','SMITHTEST','TESTPAT',null,'1042 N MONTICELLO',null,'CHICAGO','IL','60651','7732783481','1947-07-10','349428122','M',5,to_date('08-MAR-19','DD-MON-RR'));


--8049246509

select * from patientmaster_il;

select * from micro_messages_nc
where order_test_code = '768';



select n.*,order_number,order_test_name,f.LOINCCODE,f.LOINCNAME,spm.snomedcode specimen_code,spm.PREFERREDNAME specimen_name
,org.snomedcode organism_code,org.PREFERREDNAME organism_name
from micro_messages_il n
join micro_organism_filter f ON f.organismname = n.MICRO_ORGANISM_NAME
join snomed_master spm ON spm.specimen_source_code = n.specimen_source
join snomed_master org ON org.localname = n.micro_organism_name;

select lo.initiate_id,r.MICRO_ORGANISM_NAME,r.ACCESSION_NUMBER,r.order_test_code,r.order_test_name,r.result_test_code,r.result_test_name,r.abnormal_flag,r.TEXTUAL_RESULT_FULL,lod.specimen_method_code
,lod.specimen_source_desc
,lod.SPECIMEN_SOURCE_CODE
,specimen_container_code,specimen_container_desc from ih_dw.results r
join ih_dw.dim_lab_order lo ON lo.requisition_id = r.requisition_id
join ih_dw.dim_lab_order_details lod ON lod.lab_order_fk = lo.LAB_ORDER_PK

where r.requisition_id = '9998SR6'
and regexp_like(r.result_test_name, 'isolate','i')
and lod.SPECIMEN_METHOD_CODE is not null;

select * from snomed_master;

update micro_messages_nc
set accession_number = '650524KGS'
where order_test_code = '768';

select order_number, order_test_code,order_test_name,smo.snomedcode organsim_snomed,micro_organism_name,
sm.specimen_source_code,sm.snomedcode spec_snomed,smo.localname organism from micro_messages_nc m
join micro_organism_filter f ON f.organismname = m.micro_organism_name
join snomed_master sm ON sm.localname = substr(m.accession_number,1,2) and sm.specimen_source_code = m.specimen_source
join snomed_master smo ON smo.localname = f.organismname;

select * from micro_messages_nc;

update snomed_master
set snomedcode = '445421007',preferredname = 'Fungal isolate specimen (specimen)'
where snomedid = 32;

Insert into MICRO_MESSAGES_NC (ACCESSION_NUMBER,FACILITY_ID,CID,ETHNIC_GROUP,PATIENT_RACE,EXTERNAL_MRN,PATIENT_LAST_NAME,PATIENT_FIRST_NAME,PATIENT_MIDDLE_NAME,DATE_OF_BIRTH,GENDER,PATIENT_SSN,NPI,ORDERING_PHYSICIAN_NAME,REPORT_NOTES,SPECIMEN_RECEIVE_DATE,COLLECTION_DATE,COLLECTION_TIME,COLLECTION_DATE_TIME,DRAW_FREQ,RES_RPRT_STATUS_CHNG_DT_TIME,ORDER_DETAIL_STATUS,ORDER_TEST_CODE,ORDER_TEST_NAME,RESULT_TEST_CODE,RESULT_TEST_NAME,RESULT_STATUS,TEXTUAL_RESULT,TEXTUAL_RESULT_FULL,NUMERIC_RESULT,UNITS,REFERENCE_RANGE,ABNORMAL_FLAG,RELEASE_DATE_TIME,PERFORMING_LAB_ID,ORDER_METHOD,SPECIMEN_SOURCE,ORDER_NUMBER,LOGGING_SITE,AGE,FACILITY_NAME,COND_CODE,PATIENT_TYPE,SOURCE_OF_COMMENT,PATIENT_ID,ALTERNATE_PATIENT_ID,REQUISITION_STATUS,FACILITY_ADDRESS1,FACILITY_ADDRESS2,FACILITY_CITY,FACILITY_STATE,FACILITY_ZIP,FACILITY_PHONE,PATIENT_ACCOUNT_ADDRESS1,PATIENT_ACCOUNT_ADDRESS2,PATIENT_ACCOUNT_CITY,PATIENT_ACCOUNT_STATE,PATIENT_ACCOUNT_ZIP,PATIENT_HOME_PHONE,LOINC_CODE,LOINC_NAME,VALUE_TYPE,EAST_WEST_FLAG,INTERNAL_EXTERNAL_FLAG,LAST_UPDATE_TIME,SEQUENCE_NO,FACILITY_ACCOUNT_STATUS,FACILITY_ACTIVE_FLAG,MICRO_ISOLATE,MICRO_ORGANISM_NAME,LAB_FK,CLINICAL_MANAGER,MEDICAL_DIRECTOR,ACTI_FACILITY_ID,FMC_NUMBER,REPORTABLE_STATE,SOURCE_STATE,DEVICE_NAME) values ('659998SR6','A119765',null,null,null,'5001005505','LTEST','SANTEST',null,to_date('10-FEB-65','DD-MON-RR'),'M','689163967','1154308435','MERTEN, GREGORY'
,null,to_date('24-JUL-24','DD-MON-RR'),to_date('23-JUL-24','DD-MON-RR'),'00:00:00',to_date('23-JUL-24','DD-MON-RR'),'OTH',to_date('26-JUL-24','DD-MON-RR'),'F'
,'768','Culture, GC (Gonorrhea)','768C','Isolate #1','F','bap: No Growth','bap: No Growth
bru = No Growth',null,null,null,'N',to_date('25-JUL-24','DD-MON-RR'),'SH','MICRO','GENIT/Urethra','0524KGS','HE',59,'7325:INS Freedom Home Therapies','ANAER'
,'ES','C3320518171','8003936132','5001005505','F','3158 Freedom Drive','Suite 2102','Charlotte','NC','28208','(980)-341-1900','12324 SUMMER BREEZE COUR'
,null,'CHARLOTTE','NC','28277','7047086577',null,null,'ST','SS','I',to_timestamp('26-JUL-24 10.20.54.408214000 AM','DD-MON-RR HH.MI.SSXFF AM'),4,'Active','Y',null
,'Candida auris',7,null,'Alex Ryder M.D.','A119765','7325',null,'patient','E-GENIT');



Insert into MICRO_MESSAGES_NC (ACCESSION_NO,FACILITY_ID,CID,ETHNIC_GROUP,PATIENT_RACE,MRN,PATIENT_LAST_NAME,PATIENT_FIRST_NAME
,PATIENT_MIDDLE_NAME,DATE_OF_BIRTH,GENDER,PATIENT_SSN,NPI,ORDERING_PHYSICIAN_NAME,REPORT_NOTES,SPECIMEN_RECEIVE_DATE,COLLECTION_DATE,COLLECTION_TIME
,COLLECTION_DATE_TIME,DRAW_FREQ,RES_RPRT_STATUS_CHNG_DT_TIME,ORDER_DETAIL_STATUS,ORDER_TEST_CODE,ORDER_TEST_NAME,RESULT_TEST_CODE,RESULT_TEST_NAME
,RESULT_STATUS,TEXTUAL_RESULT,TEXTUAL_RESULT_FULL,NUMERIC_RESULT,UNITS,REFERENCE_RANGE,ABNORMAL_FLAG,RELEASE_DATE_TIME,RESULT_COMMENTS,PERFORMING_LAB_ID,ORDER_METHOD
,SPECIMEN_SOURCE,ORDER_NUMBER,LOGGING_SITE,AGE,FACILITY_NAME,COND_CODE,PATIENT_TYPE,SOURCE_OF_COMMENT,PATIENT_ID,ALTERNATE_PATIENT_ID,REQUISITION_STATUS,FACILITY_ADDRESS1
,FACILITY_ADDRESS2,FACILITY_CITY,FACILITY_STATE,FACILITY_ZIP,FACILITY_PHONE,PATIENT_ACCOUNT_ADDRESS1,PATIENT_ACCOUNT_ADDRESS2,PATIENT_ACCOUNT_CITY,PATIENT_ACCOUNT_STATE
,PATIENT_ACCOUNT_ZIP,PATIENT_HOME_PHONE,LOINC_CODE,LOINC_NAME,VALUE_TYPE,EAST_WEST_FLAG,INTERNAL_EXTERNAL_FLAG,LAST_UPDATE_TIME,SEQUENCE_NO,FACILITY_ACCOUNT_STATUS
,FACILITY_ACTIVE_FLAG,MICRO_ISOLATE,MICRO_ORGANISM_NAME,LAB_FK,CLINICAL_MANAGER,MEDICAL_DIRECTOR,ACTI_FACILITY_ID,FMC_NUMBER,REPORTABLE_STATE,SOURCE_STATE,DEVICE_NAME) values ('650524KGS','A114882','9WN','Unknown','Choose not to disclose','7001444139','COILEYTEST','INGERTEST',null,to_date('24-FEB-33','DD-MON-RR'),'M',null,null,'ORDER, AUTH',null,to_date('11-SEP-24','DD-MON-RR'),to_date('10-SEP-24','DD-MON-RR'),'11:10:00',to_date('10-SEP-24','DD-MON-RR'),null,to_date('11-SEP-24','DD-MON-RR'),'F','768','Culture, GC (Gonorrhea)','768C','Isolate #1','F','Gram Negative Diplococci Isolated','Light Growth
Gram Negative Diplococci Isolated
Beta-Lactamase Negative',null,null,null,'AA',to_date('11-SEP-24','DD-MON-RR'),null,'SE','MICRO','GENIT/Urethra','0524KGS','HE',91,'Korus Test Hemo','GENIT','ES',null,'8000402159','7001444139','F','8 King Road','Test','Rockleigh','NJ','07647','(800)-522-4662','1 TESTING ST.',null,'MORRISVILLE','NC','27560','2017677070',null,null,'ST','SE','E',to_timestamp('11-SEP-24 11.25.01.968269000 AM','DD-MON-RR HH.MI.SSXFF AM'),4,'In progress','Y','Isolate #1','Gram Negative Diplococci Isolated',5,null,'Suresh Gupta, MD','A114882',null,null,'patient','E-GENIT');


Insert into MICRO_MESSAGES_NC (ACCESSION_NUMBER,FACILITY_ID,CID,ETHNIC_GROUP,PATIENT_RACE,EXTERNAL_MRN,PATIENT_LAST_NAME,PATIENT_FIRST_NAME,PATIENT_MIDDLE_NAME
,DATE_OF_BIRTH,GENDER,PATIENT_SSN,NPI,ORDERING_PHYSICIAN_NAME,REPORT_NOTES,SPECIMEN_RECEIVE_DATE,COLLECTION_DATE
,COLLECTION_TIME,COLLECTION_DATE_TIME,DRAW_FREQ,RES_RPRT_STATUS_CHNG_DT_TIME,ORDER_DETAIL_STATUS
,ORDER_TEST_CODE,ORDER_TEST_NAME,RESULT_TEST_CODE,RESULT_TEST_NAME
,RESULT_STATUS,TEXTUAL_RESULT,TEXTUAL_RESULT_FULL,NUMERIC_RESULT,UNITS,REFERENCE_RANGE,ABNORMAL_FLAG,RELEASE_DATE_TIME,PERFORMING_LAB_ID,ORDER_METHOD
,SPECIMEN_SOURCE,ORDER_NUMBER
,LOGGING_SITE,AGE,FACILITY_NAME,COND_CODE
,PATIENT_TYPE,SOURCE_OF_COMMENT,PATIENT_ID,ALTERNATE_PATIENT_ID
,REQUISITION_STATUS,FACILITY_ADDRESS1,FACILITY_ADDRESS2,FACILITY_CITY,FACILITY_STATE,FACILITY_ZIP,FACILITY_PHONE
,PATIENT_ACCOUNT_ADDRESS1,PATIENT_ACCOUNT_ADDRESS2,PATIENT_ACCOUNT_CITY,PATIENT_ACCOUNT_STATE
,PATIENT_ACCOUNT_ZIP,PATIENT_HOME_PHONE,LOINC_CODE,LOINC_NAME,VALUE_TYPE,EAST_WEST_FLAG,INTERNAL_EXTERNAL_FLAG
,LAST_UPDATE_TIME,SEQUENCE_NO,FACILITY_ACCOUNT_STATUS,FACILITY_ACTIVE_FLAG
,MICRO_ISOLATE,MICRO_ORGANISM_NAME,LAB_FK,CLINICAL_MANAGER,MEDICAL_DIRECTOR,ACTI_FACILITY_ID,FMC_NUMBER,REPORTABLE_STATE,SOURCE_STATE,DEVICE_NAME) 
values ('650524KGS'
,'A114882'
,'9WN'
,'Unknown'
,'Choose not to disclose'
,'7001444139'
,'COILEYTEST'
,'INGERTEST'
,null
,to_date('24-FEB-33','DD-MON-RR')
,'M'
,null
,null
,'ORDER, AUTH'
,null
,to_date('11-SEP-24','DD-MON-RR')
,to_date('10-SEP-24','DD-MON-RR')
,'11:10:00'
,to_date('10-SEP-24','DD-MON-RR')
,null,to_date('11-SEP-24','DD-MON-RR')
,'F'
,'768','Culture, GC (Gonorrhea)','768C','Isolate #1','F'
,'Gram Negative Diplococci Isolated','Light Growth
Gram Negative Diplococci Isolated
Beta-Lactamase Negative'
,null
,null
,null
,'AA'
,to_date('11-SEP-24','DD-MON-RR')
,null,'SE','MICRO'
,'GENIT/Urethra','0524KGS','HE'
,91,'Korus Test Hemo','GENIT','ES'
,null,'8000402159','7001444139','F'
,'8 King Road','Test','Rockleigh','NJ','07647','(800)-522-4662'
,'1 TESTING ST.',null,'MORRISVILLE','NC'
,'27560','2017677070'
,null,null,'ST','SE','E'
,to_timestamp('11-SEP-24 11.25.01.968269000 AM','DD-MON-RR HH.MI.SSXFF AM')
,4,'In progress','Y','Isolate #1','Gram Negative Diplococci Isolated',5,null,'Suresh Gupta, MD','A114882',null,null,'patient','E-GENIT');