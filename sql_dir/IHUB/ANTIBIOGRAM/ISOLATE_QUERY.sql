select * from ih_dw.results
where requisition_id = '00891P4';

select count(1) from
(select requisition_id from STATERPT_OWNER.MICRO_ISOLATE_EXTRACT
group by requisition_id);

select count(1) from
(select requ from STATERPT_OWNER.MICRO_ISOLATE_ORGANISM
group by requisition_id);

select abnormal_flag,count(1) from STATERPT_OWNER.MICRO_ISOLATE_ORGANISM o
join 
(select requisition_id from STATERPT_OWNER.MICRO_ISOLATE_EXTRACT
group by requisition_id) e ON e.requisition_id = o.REQUISITION_ID
where regexp_like(organism_name,'CANDIDA ALBICANS','i') and result_name in ('CASPOFUNGIN')
and abnormal_flag IN ('R','I','S') 
group by abnormal_flag;

select organism_name,result_name,abnormal_flag,count(1) from STATERPT_OWNER.MICRO_ISOLATE_ORGANISM o
join 
(select requisition_id from STATERPT_OWNER.MICRO_ISOLATE_EXTRACT
group by requisition_id) e ON e.requisition_id = o.REQUISITION_ID
where regexp_like(organism_name,'^Can','i')
and abnormal_flag IN ('S','R','I')
group by organism_name,result_name,abnormal_flag
order by organism_name,result_name;





where requisition_id = '00891P4';

select * from asr_process_run;

/
insert into micro_isolate_extract
/
SELECT
 null as PATIENT_FK ,
 null as FACILITY_FK ,
 DLO.lab_fk as LAB_FK ,
 null as TEST_FK ,
 null as TIME_FK ,
 null as PHYSICIAN_FK ,
 R.ABNORMAL_FLAG as ABNORMAL_FLAG ,
 R.ACCESSION_NUMBER as ACCESSION_NO ,
 trunc(R.COLLECTION_DATE) as COLLECTION_DATE ,
 R.COLLECTION_date_TIME as COLLECTION_TIME ,
 R.ORDER_TEST_CODE as COMPOUND_TEST_CODE ,
 DLOD.DRAW_FREQUENCY as DRAW_FREQ ,
 DLOD.diagnosis_code as ICD9 ,
 decode(DLO.lab_fk,5,'HE',7,'HS','XX') as LOGGING_SITE ,
 DLO.MODALITY_CODE as MODALITY ,
 R.COLLECTION_DATE_TIME as OBSERVATION_DATE_TIME ,
 ORDERING_PHYSICIAN_NAME as ORDERING_PHYSICIAN_NAME ,
 DLO.LAB_ESTABLISH_DATE_TIME as ORDER_DATE ,
 R.TEST_CATEGORY as ORDER_METHOD ,
 R.REQUISITION_ID as ORDER_NUMBER ,
 DLOD.ORDER_DETAIL_STATUS as ORDER_STATUS ,
 DLOD.ORDER_EFF_DATE_TIME as ORDER_TIME ,
 R.PERFORMING_LAB as PERFORMING_LAB_ID ,
 R.REFERENCE_RANGE as REFERENCE_RANGE ,
 TRUNC(R.RELEASE_DATE_TIME) as RELEASE_DATE ,
 R.RELEASE_DATE_TIME as RELEASE_TIME ,
 DLOD.REPORT_NOTES as REPORT_NOTES ,
 DLOD.REQUESTED_DATE_TIME as REQUESTED_DATE_TIME ,
 DLO.PATIENT_DOB as REQUISITION_DOB ,
 DLO.GENDER as REQUISITION_GENDER ,
 DLO.REQUISITION_ID as REQUISITION_ID ,
 DLO.SSN as REQUISITION_SSN ,
 DLO.REQUISITION_STATUS as REQUISITION_STATUS ,
 R.RESULT_COMMENT as RESULT_COMMENTS ,
 R.RESULT_STATUS as RESULT_STATUS ,
 DLOD.RESULT_RPT_CHNG_DATE_TIME as RES_RPRT_STATUS_CHNG_DT_TIME ,
 R.RESULT_SEQUENCE as SEQUENCE_NO ,
 R.SOURCE_OF_COMMENT as SOURCE_OF_COMMENT ,
 TRUNC(DLOD.SPECIMEN_RECEIVED_DATE_TIME) as SPECIMEN_RECEIVE_DATE ,
 DLOD.SPECIMEN_RECEIVED_DATE_TIME as SPECIMEN_RECEIVE_TIME ,
      NVL (dlod.specimen_method_desc, '')
           || NVL2 (
                  dlod.specimen_source_desc,
                     NVL2 (dlod.specimen_method_desc, '/', '')
                  || dlod.specimen_source_desc,
                  '')
               AS SPECIMEN_SOURCE ,
 R.TEXTUAL_RESULT_FULL as TEXTUAL_NUMERIC_RESULT ,
 R.VALUE_TYPE as VALUE_TYPE ,
 R.CREATED_DATE as CREATION_TIME ,
 R.LAST_UPDATED_DATE as LAST_UPDATE_TIME ,
 DLO.PATIENT_TYPE as PATIENT_TYPE ,
 DLOD.REMOTE_ORDER_NUM as REMOTE_ORDER_NUM ,
 DLOD.ORDER_OCCURRENCE_ID as ORDER_OCCURRENCE_ID ,
 DLOD.EMR_ORDER_ID as EMR_ORDER_ID ,
 DLOD.EMR_PHYSICIAN_INFO as EMR_PHYSICIAN_INFO ,
 TRUNC(DLOD.REQUESTED_DATE_TIME) as ORDER_RECEIVE_DATE ,
 DLOD.REQUESTED_DATE_TIME as ORDER_RECEIVE_TIME ,
 R.OBSERVATION_METHOD as SUS_METHOD ,
 R.LOINC_CODE as LOINC_CODE ,
 R.LOINC_NAME as LOINC_NAME ,
 R.LAST_UPDATED_DATE as RR_UPDATE_TIME
FROM IH_DW.DIM_LAB_ORDER DLO
JOIN IH_DW.DIM_LAB_ORDER_DETAILS DLOD ON DLOD.REQUISITION_ID = DLO.REQUISITION_ID AND DLOD.LAB_ORDER_FK = DLO.LAB_ORDER_PK
JOIN IH_DW.RESULTS R ON DLO.REQUISITION_ID = R.REQUISITION_ID AND R.LAB_ORDER_FK = DLO.LAB_ORDER_PK AND dlod.lab_order_details_pk = r.lab_order_details_fk
Where DLOD.test_category = 'MICRO'
--AND  R.collection_date >= date'2024-08-01'
--AND DLOD.collection_date >= date'2024-08-01'
--AND DLO.collection_date >= date'2024-08-01'
and dlo.collection_date = dlod.collection_date
and dlod.collection_date=r.collection_date
AND EXTRACT(YEAR FROM DLO.collection_date) = '2023'
AND EXTRACT(YEAR FROM DLOD.collection_date) = '2023'
AND EXTRACT(YEAR FROM R.collection_date) = '2023'
and R.REQUISITION_ID = '00891P4'
AND         (    UPPER(R.RESULT_TEST_NAME) like UPPER('%CULTURE%')
        OR         UPPER(R.RESULT_TEST_NAME) like UPPER('%ORGANISM%')
        OR         UPPER(R.RESULT_TEST_NAME) like UPPER('%ISOLATE%')
        );
