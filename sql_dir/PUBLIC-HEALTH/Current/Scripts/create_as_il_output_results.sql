
drop table IL_Results_20250609;

create table IL_Results_20250605
as 
select * from IL_OUTPUT_RESULTS;

select requisition_id,last_updated_date,state from all_Results_20250628
--where regexp_like(order_test_code,'^(301|303|304|308|310|311|312|315|317L|322|323|327|332|336|319N)$')
order by last_updated_date desc;
;

CREATE TABLE all_Results_20250628 AS
WITH recent_activity_requisitions AS (
    SELECT requisition_id
    FROM ih_dw.dw_ods_activity
    WHERE last_updated_date > TO_TIMESTAMP('28-JUN-25 12.00.00.000000000 AM', 'DD-MON-RR HH.MI.SS.FF9 PM')
    GROUP BY requisition_id -- Achieves the same as DISTINCT requisition_id
)
-- ... rest of the query remains the same
SELECT
    r.requisition_id,
    r.order_test_code,
    r.result_test_code,
    r.performing_lab,
    r.textual_result_full,
    dp.last_name lname,
    dp.state,
    r.last_updated_date
   
FROM
    ih_dw.results r
INNER JOIN
    ih_dw.dim_lab_order lo ON lo.requisition_id = r.requisition_id
--INNER JOIN

    -- patientmaster pm ON pm.eid = lo.initiate_id AND r.lab_fk = pm.lab_fk
INNER JOIN
    IH_DW.SPECTRA_MRN_ASSOCIATIONS asso ON  asso.SPECTRA_MRN_ASSC_pk = lo.SPECTRA_MRN_ASSC_FK 
    
INNER JOIN
    IH_DW.DIM_PATIENT dp ON dp.spectra_mrn_fk = asso.spectra_mrn_fk   

INNER JOIN
    recent_activity_requisitions rar ON r.requisition_id = rar.requisition_id -- Joining with the CTE
WHERE
--dp.state = 'IL'  -- Filter for patient state
     EXISTS (
        -- This subquery checks if the requisition_id from 'r'
        -- exists in recent activities.
        SELECT 1
        FROM ih_dw.dw_ods_activity doa
        WHERE doa.requisition_id = r.requisition_id -- Correlation with the outer query
          AND doa.last_updated_date > TO_TIMESTAMP('28-JUN-25 12.00.00.000000000 AM', 'DD-MON-RR HH.MI.SS.FF9 PM')
          AND r.last_updated_date > TO_TIMESTAMP('28-JUN-25 12.00.00.000000000 AM', 'DD-MON-RR HH.MI.SS.FF9 PM')
    )
    AND r.result_status = 'F'
    and external_id_type = 'INITIATE_ID'
    and regexp_like(external_id,'^8');
    and regexp_like(r.result_test_code,'^(3|11)'); 
    
/

select * from asr_inbound_extract
where batchseq = 'LOAD_20250608';

select * from IH_DW.SPECTRA_MRN_ASSOCIATIONS asso
where rownum < 10;

select * from
(select p.* from ih_dw.dim_patient p
join IH_DW.SPECTRA_MRN_ASSOCIATIONS asso ON asso.spectra_mrn_fk = p.spectra_mrn_fk
where rownum < 10
and p.last_updated_date >  TO_TIMESTAMP('07-JUN-25 12.00.00.000000000 AM', 'DD-MON-RR HH.MI.SS.FF9 PM')
and external_id_type = 'INITIATE_ID');
    
    SELECT
    TO_TIMESTAMP('05-JUN-25 12.00.00.000000000 AM', 'DD-MON-RR HH.MI.SS.FF9 PM') AS original_tsdate,
    systimestamp - INTERVAL '611' MINUTE AS tsdate_minus_1_minute
FROM
    dual;

    
   -- r.requisition_id = '3391WH8'
   -- pm.state = 'IL' -- Filter for patient state
    --AND rownum < 10   -- Oracle-specific way to limit to the first 9 rows that satisfy other conditions.
                      -- Note: Without an ORDER BY clause, the 9 rows selected are non-deterministic
                      -- if multiple sets of 9 rows could satisfy the conditions. This behavior
                      -- is consistent with your original query.
;

/

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
                    select
                      r.*
                    from
                      IH_DW.RESULTS r,
                      (
                        select
                          distinct(requisition_id)
                        from
                          IH_DW.DW_ODS_ACTIVITY
                        where
                        
                          --requisition_id = '5569BW3'

                          --LAST_UPDATED_DATE >= v_start_time
                          LAST_UPDATED_DATE >= TO_TIMESTAMP('02-JUN-25 11.59.33.719092000 PM', 'DD-MON-RR HH.MI.SS.FF9 PM')
                          and requisition_id = '3391WH8'
                          


                      ) a
                    where
                      r.requisition_id = a.requisition_id
                    and
                      r.order_test_code = '311'
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
                        and dp.FACILITY_FK = asso.FACILITY_fK
--                        and lod.TEST_CATEGORY in ('IMMUNO','IMMUN','PCR','ARUP','CHEM','MICRO')
                        and 
                            re.result_status = 'F';
--                        and 
--                            re.order_test_code IN ('301', '111', '318', '319C', '312','319N', '329M', '311', '9239', '308',  '303',  '304', '310'
--                        , '322', '323', '315', '317L', '9142', '332', '336')
--                        and lod.TEST_CATEGORY in ('IMMUNO','IMMUN','PCR','ARUP','CHEM');
--                        

                        --and lod.TEST_CATEGORY in ('IMMUNO','IMMUN','PCR','ARUP','CHEM','MICRO');
                        --and lod.TEST_CATEGORY in ('IMMUNO','IMMUN','PCR','ARUP','HEMA');
                        --and p.state = p_state;
                        --and p.state in (p_state);
                        --and p.state in ('TX','AZ','CA','PA','OR','FL','WA');
                        --and p.state = 'CA';
                        
/

select loinc_code,loinc_name,order_test_code,result_test_code,textual_result_full from results_sent_log 
where loinc_code = '42595-9';