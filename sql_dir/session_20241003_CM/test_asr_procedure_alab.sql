insert into asr_process_run;
select r.requisition_id,r.order_test_code,r.result_test_code,r.PERFORMING_LAB,textual_result_full,'lastname' patient_last_name
,'NA' source,to_char(r.last_updated_date,'dd-MON-yy') activitydate,'N' complete
from ih_dw.results r
where r.LAST_UPDATED_DATE > sysdate - 15
--and regexp_like(order_test_code,'^332|^310|^311|^308|^301')
order by order_test_code;

select * from asr_process_run;

select eid,lab_fk from patientmaster
where table_updated > sysdate - 1
and lab_fk = 5
--group by eid,lab_fk;
--order by table_updated desc;
and eid IN ('8000561430'
,'8000561437');


/

select facility_id,order_number,order_test_code,result_test_code,PERFORMING_LAB_id,textual_result_full, patient_last_name
,patient_account_state,last_update_time from 

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
                             (
                              select pm.eid pm_id,r.lab_fk,lo.initiate_id,r.requisition_id order_number,r.order_test_code,r.result_test_code,r.PERFORMING_LAB,textual_result_full,'lastname' patient_last_name
                              ,'NA' source,to_char(r.last_updated_date,'dd-MON-yy') activitydate,'N' complete
                              from ih_dw.results r
                              join ih_dw.dim_lab_order lo ON lo.requisition_id = r.requisition_id
                              left outer join patientmaster pm ON pm.eid = lo.initiate_id
                              where r.LAST_UPDATED_DATE > sysdate - 2
                              --and regexp_like(result_test_code,'^332|^30|^31')
                              and regexp_like(performing_lab,'^SE|^SH')
                              and r.requisition_id IN ('QSTATE1','QSTATE2')
                              
                            
                             ) proc
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
                        and dp.FACILITY_FK = asso.FACILITY_fK);
                        --and f.facility_id IN ('A102257','B153619','B153620','B153621'));

/

with asr (order_number,activitydate ,result_test_code,complete,source)
  as (select order_number,activitydate ,result_test_code,complete,source
      from asr_process_run),
pat as (select  v.* from vw_pat_results v
union all 
select  v.* from VW_STAFF_RESULTS v )

select 
REQUISITION_ID,
EID,
COUNTY,
FACILITY_ID,
CID,
PATIENT_LAST_NAME,
PATIENT_FIRST_NAME,
PATIENT_MIDDLE_NAME,
DATE_OF_BIRTH,
GENDER,
PATIENT_SSN,
AGE,
PATIENT_ACCOUNT_ADDRESS1,
PATIENT_ACCOUNT_ADDRESS2,
PATIENT_ACCOUNT_CITY,
PATIENT_ACCOUNT_STATE,
PATIENT_ACCOUNT_ZIP,
PATIENT_HOME_PHONE,
FACILITY_ADDRESS1,
FACILITY_ADDRESS2,
FACILITY_CITY,
FACILITY_STATE,
FACILITY_ZIP,
FACILITY_PHONE,
EAST_WEST_FLAG,
INTERNAL_EXTERNAL_FLAG,
FACILITY_ACCOUNT_STATUS,
FACILITY_ACTIVE_FLAG,
CLINICAL_MANAGER,
MEDICAL_DIRECTOR,
ACTI_FACILITY_ID,
FMC_NUMBER,
PATIENT_RACE,
ETHNIC_GROUP,
FACILITY_NAME,
GENDER_IDENTITY,
SEX_ORIENT
from asr 
join pat ON pat.requisition_id = asr.order_number
--left join vw_staff_results sr ON sr.requisition_id = asr.order_number

where complete IN ('R','S') and activitydate = to_char(sysdate - 1 ,'dd-MON-yy')
and pat.result_test_code = asr.result_test_code;