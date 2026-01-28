create or replace PROCEDURE  SP_ASR_PROC_TRACK_RESULTS_Z (
	p_state IN varchar2,
  p_gtt_count out number
) AS
	v_process  VARCHAR2(30) := 'ASR_PROCESS_' || UPPER(p_state);
	v_next_time TIMESTAMP(6) := SYSTIMESTAMP;
	v_start_time TIMESTAMP(6);
	v_error_flag BOOLEAN := FALSE;
	v_count NUMBER := 0;
  v_sql VARCHAR2(4000);
  v_gtt_count number := 0;

  v_order_number varchar2(25) := '';
  v_gtt_filter_count number := 0;
	
  v_noaddr_order_number varchar2(25) := null;
  v_noaddr_accession_number varchar2(25) := null;
  v_noaddr_otc varchar2(25) := null;
  v_noaddr_rtc varchar2(25) := null;  
  
    table_or_view_not_exist exception;
    pragma exception_init(table_or_view_not_exist, -942);
    attempted_ddl_on_in_use_GTT exception;
    pragma exception_init(attempted_ddl_on_in_use_GTT, -14452);
    
	BEGIN
     BEGIN

        delete from STATERPT_OWNER.GTT_RESULTS_EXTRACT where accession_number is not null;
        commit;
        delete from STATERPT_OWNER.GTT_STAFF_RESULTS_EXTRACT where accession_number is not null;
        commit;
      END;  
  
		BEGIN

   

		SELECT 
			MAX (ASR_PROCESS_TRACKING.start_time)
		INTO   
			v_start_time
		FROM   
			STATERPT_OWNER.ASR_PROCESS_TRACKING
		WHERE  
			ASR_PROCESS_TRACKING.process_name = v_process
			and ASR_PROCESS_TRACKING.status = '1';

		dbms_output.put_line('v_start_time = ' || v_start_time);
		dbms_output.put_line('v_next_time = ' || v_next_time);

            INSERT INTO
              STATERPT_OWNER.GTT_RESULTS_EXTRACT
            select * from micro_messages_nc
            where order_test_code not in ('750B');
      
      
--            INSERT INTO
--              STATERPT_OWNER.GTT_RESULTS_EXTRACT
--                      select
--                        distinct(re.ACCESSION_NUMBER) accession_no,
--                        f.FACILITY_ID,
--                        a.CID,
--                        dp.ethnicity ethnic_group,
--                        dp.RACE patient_race,
--                        lo.EXTERNAL_MRN mrn,
--                       
--                        nvl(p.lname, '') PATIENT_LAST_NAME,
--                        nvl(p.fname, '') PATIENT_FIRST_NAME,
--                        --p.mname PATIENT_MIDDLE_NAME,
--                        (
--                          CASE
--                            WHEN p.mname is null THEN null
--                            WHEN upper(p.mname) = 'NULL' THEN null
--                            ELSE p.mname
--                          END
--                        ) PATIENT_MIDDLE_NAME,          
--                        --to_date(p.DOB, 'YYYY-MM-DD') date_of_birth,
--                        (
--                          CASE
--                            WHEN p.DOB is null THEN null
--                            WHEN test_date(p.DOB) = 'Valid' THEN
--                              (
--                                CASE 
--                                  WHEN (EXTRACT(YEAR FROM sysdate) - to_number(SUBSTR(replace(p.DOB, '-'), 1, 4))) <= 0 THEN NULL 
--                                  ELSE to_date(p.DOB, 'YYYY-MM-DD')
--                                END
--                              )
--                            ELSE NULL	
--                          END
--                        ) date_of_birth,          
--                        p.sex gender,
--                        p.ssn patient_ssn,
--                        --dph.NPI,
--                        --dph.PHYSICIAN_NAME ordering_physician_name,
--                        lo.ordering_physician_npi NPI,
--                        lo.ordering_physician_name ordering_physician_name,          
--                        lod.REPORT_NOTES,
--                        lod.SPECIMEN_RECEIVED_DATE_TIME specimen_receive_date,
--                        lod.COLLECTION_DATE collection_date,
--                        lod.COLLECTION_TIME collection_time,
--                        lod.COLLECTION_DATE_TIME,
--                        lod.DRAW_FREQUENCY draw_freq,
--                        lod.RESULT_RPT_CHNG_DATE_TIME res_rprt_status_chng_dt_time,
--                        lod.ORDER_DETAIL_STATUS,
--                        re.ORDER_TEST_CODE,
--                        re.ORDER_TEST_NAME,
--                        re.RESULT_TEST_CODE,
--                        re.RESULT_TEST_NAME,
--                        re.RESULT_STATUS,
--                        re.TEXTUAL_RESULT,
--                        re.TEXTUAL_RESULT_FULL,
--                        re.NUMERIC_RESULT,
--                        re.UNIT_OF_MEASURE units,
--                        re.REFERENCE_RANGE,
--                        re.ABNORMAL_FLAG,
--                        re.RELEASE_DATE_TIME,
--                        trim(dbms_lob.substr( re.RESULT_COMMENT, 4000, 1 )) as RESULT_COMMENTS,
--                        re.PERFORMING_LAB performing_lab_id,
--                        --'SE' performing_lab_id,
--                        lod.TEST_CATEGORY order_method,
--                        lod.SPECIMEN_METHOD_DESC specimen_source,
--                        re.REQUISITION_ID order_number,
--                        dl.LAB_ID logging_site,
--                        (
--                          CASE
--                            WHEN p.DOB is null THEN 0
--                            WHEN test_date(p.DOB) = 'Valid' THEN
--                              (
--                                CASE 
--                                  WHEN (EXTRACT(YEAR FROM sysdate) - to_number(SUBSTR(replace(p.DOB, '-'), 1, 4))) <= 0 THEN 0 
--                                  ELSE trunc(months_between(sysdate, to_date(p.DOB, 'YYYY-MM-DD'))/12)
--                                END
--                              )
--                            ELSE NULL	
--                          END
--                        ) age,
--                        f.DISPLAY_NAME facility_name,
--                        null cond_code,
--                        lo.PATIENT_TYPE,
--                        lod.ORDER_OCCURRENCE_ID source_of_comment,
--                        lo.INITIATE_ID	patient_id,
--                        lo.ALTERNATE_PATIENT_ID,
--                        lo.REQUISITION_STATUS,
--                        f.ADDRESS_LINE1 facility_address1,
--                        f.ADDRESS_LINE2 facility_address2,
--                        f.CITY facility_city,
--                        f.STATE facility_state,
--                        f.ZIP facility_zip,
--                        f.PHONE_NUMBER facility_phone,
--                        p.stline1 patient_account_address1,
--                        p.stline2 patient_account_address2,
--                        p.CITY patient_account_city,
--                        p.state patient_account_state,
--                        --'IL' patient_account_state,
--                        p.zipcode patient_account_zip,
--                        --p.phnumber patient_home_phone,
--                    (
--                       CASE
--                         WHEN p.phnumber is null THEN null
--                         WHEN length(p.phnumber) > 10 THEN substr(p.phnumber, ((length(p.phnumber) - 10) + 1))
--                         ELSE p.phnumber
--                       END
--                     ) patient_home_phone, 
--                     (case when re.loinc_code is null and re.order_test_code = '336' then '48345-3' 
--                            when re.loinc_code is null and re.order_test_code = '332' then '94309-2' 
--                            when re.loinc_code is null and re.order_test_code = '331' then '96119-3' else re.loinc_code end) 
--                            loinc_code ,
--                    ( case when re.loinc_name is null and re.order_test_code = '336' then 'HIV 1+O+2 Ab:PrThr:Pt:Ser/Plas:Ord' 
--                            when re.loinc_name is null and re.order_test_code = '332' then 'SARS coronavirus 2 RNA:PrThr:Pt:XXX:Ord:Probe.amp.tar' 
--                            when re.loinc_name is null and re.order_test_code = '331' then 'SARS coronavirus 2 Ag:PrThr:Pt:Respiratory.upper:Ord:IA'else re.loinc_name end
--                    ) loinc_name,
--                        re.VALUE_TYPE,
--                        f.EAST_WEST_FLAG,
--                        f.INTERNAL_EXTERNAL_FLAG,
--                        re.LAST_UPDATED_DATE last_update_time,
--                        re.RESULT_SEQUENCE sequence_no,
--                        f.ACCOUNT_STATUS facility_account_status,
--                        f.FACILITY_ACTIVE_FLAG,
--                        re.MICRO_ISOLATE,
--                        re.MICRO_ORGANISM_NAME,
--                        re.lab_fk,
--                        f.CLINICAL_MANAGER,
--                        dl.MEDICAL_DIRECTOR,
--                        f.FACILITY_ID acti_facility_id,
--                        f.FMC_NUMBER,
--                        null reportable_state,
--                        'patient' source_state,
--                        re.observation_method device_name
--                        
--                      from
--                        (
--                            select
--                            r.*
--                          from
--                            asr_process_run proc
--                            join IH_DW.DW_ODS_ACTIVITY act on act.requisition_id = proc.order_number
--                            JOIN IH_DW.RESULTS r ON r.requisition_id = act.requisition_id
--                            where r.result_test_code = proc.result_test_code and r.order_test_code = proc.order_test_code
--                            and complete = 'N'
--
----                               ih_dw.dw_ods_activity act
----                              join ih_dw.results r ON r.requisition_id = act.requisition_id
----                              where act.requisition_id  IN
----                                ('7560X56','7530MN6','7560XY6','7672WV6','78387N6','7516B26','76693N6',
----                                '0916T94','74136H6','76656W6','7516B36','7838A56','7690A26','7530MB6')
----                              and r.result_test_code IN
----                              (select result_test_code from asr_process_run
----                              where order_number = act.requisition_id)
----                            
----                              select
----                                distinct(order_number)
----                              from
----                                asr_process_run
----                              where
----                            
----                             --requisition_id IN (select order_number from asr_process_run ar where complete = 'N' )
----                              
----                               -- ****
----                               order_number in (select order_number from asr_process_run r
----                                  --where to_date(activitydate,'dd-MON-yy') > sysdate - 3
----                                      --and source in ('CA','NJ','NY','OR','TX','IL','MD','CT','FL','DC','PA','GA','IN','NV','NM','NC','TN','MS','MN','OH','VA','LA','OK')
----                                        where complete = 'N')
----                              
----                                              
----      
----                            ) a
----                          where
----                            r.requisition_id = a.order_number
--                        ) re,
--                        IH_DW.DIM_LAB_ORDER lo,
--                        IH_DW.DIM_LAB_ORDER_DETAILS lod,
--                        STATERPT_OWNER.PatientMaster_test p,
--                        --staterpt_owner.gtt_pm p,
--                        IH_DW.DIM_ACCOUNT a,
--                        IH_DW.DIM_FACILITY f,
--                        --IH_DW.DIM_PHYSICIAN dph,
--                        IH_DW.DIM_LAB dl,
--                        IH_DW.DIM_PATIENT dp,
--                        IH_DW.SPECTRA_MRN_ASSOCIATIONS asso	
--                      where
--                        lo.requisition_id = re.requisition_id
--                        and re.LAB_ORDER_FK = lo.LAB_ORDER_PK
--                        and lo.initiate_id = p.eid
--                        and p.lab_fk = re.lab_fk
--                        and re.LAB_ORDER_DETAILS_FK = lod.LAB_ORDER_DETAILS_PK
--                        and lo.LAB_ORDER_PK = lod.LAB_ORDER_FK
--                        and lo.account_fk = a.account_pk	
--                        and a.facility_fk = f.facility_pk
--                        --and lo.ORDERING_PHYSICIAN_NPI = dph.NPI
--                        and re.lab_fk = dl.lab_pk
--                        and lo.lab_fk = dl.lab_pk
--                        and lo.SPECTRA_MRN_ASSC_FK = asso.SPECTRA_MRN_ASSC_pk
--                        and dp.SPECTRA_MRN_FK = asso.SPECTRA_MRN_fK 
--                        and dp.FACILITY_FK = asso.FACILITY_fK;
--                        --and lod.TEST_CATEGORY in ('IMMUNO','IMMUN','PCR','ARUP','CHEM','MICRO');
--                        --and lod.TEST_CATEGORY in ('IMMUNO','IMMUN','PCR','ARUP','HEMA');
--                        --and p.state = p_state;
--                        --and p.state in (p_state);
--                        --and p.state in ('TX','AZ','CA','PA','OR','FL','WA');
--                        --and p.state = 'CA';


--insert into STATERPT_OWNER.RESULTS_TEST_TABLE select * from STATERPT_OWNER.GTT_RESULTS_EXTRACT;

commit;
             






      
			
		END;	

    

--    BEGIN
--    
--       delete from 
--          STATERPT_OWNER.GTT_RESULTS_EXTRACT
--        where
--          (accession_number || order_number || order_test_code || result_test_code) in
--          (
--              select
--                distinct(r.accession_number || r.order_number || r.order_test_code || r.result_test_code)
--              from
--                STATERPT_OWNER.GTT_RESULTS_EXTRACT r,
--                STATERPT_OWNER.RESULTS_SENT_LOG l
--              where
--                r.order_number = l.order_number
--                and r.accession_number = l.accession_number
--                and r.order_test_code = l.order_test_code
--                and r.result_test_code = l.result_test_code
--                and r.release_date_time = l.release_date_time
--          );
--       commit;   
--    END;


		
		BEGIN
 
        select
          count(*)
        into
          v_gtt_count
        from
          --STATERPT_OWNER.TEMP_RESULTS_EXTRACT;
          STATERPT_OWNER.GTT_RESULTS_EXTRACT;
          
        dbms_output.put_line('v_gtt_count: ' || v_gtt_count); 
        
        select v_gtt_count into p_gtt_count from dual;
        
        
        
        
        
--        SP_ASR_FILTER_RESULTS( 
--          p_state => p_state, 
--          p_gtt_count => v_gtt_count
--        );

        dbms_output.put_line('v_gtt_count: ' || v_gtt_count);
        select v_gtt_count into p_gtt_count from dual;
        
        
--         EXECUTE IMMEDIATE 'truncate table STATERPT_OWNER.GTT_RESULTS_EXTRACT';
--         COMMIT;


--        for filtered_sendout in (
--          select
--            *
--          from
--            STATERPT_OWNER.GTT_FILTER_RESULTS_EXTRACT 
--          where 
--            source_state = 'sendout'            
--        ) loop
--            begin
--                v_noaddr_order_number := null;
--                v_noaddr_accession_number := null;
--                v_noaddr_otc := null;
--                v_noaddr_rtc := null;
--                
--                select
--                    order_number,
--                    accession_number,
--                    order_test_code,
--                    result_test_code
--                into
--                    v_noaddr_order_number,
--                    v_noaddr_accession_number,
--                    v_noaddr_otc,
--                    v_noaddr_rtc
--                from
--                    STATERPT_OWNER.GTT_FILTER_RESULTS_EXTRACT
--                where
--                    order_number = filtered_sendout.order_number
--                    and accession_number = filtered_sendout.accession_number
--                    and order_test_code = filtered_sendout.order_test_code
--                    and result_test_code = filtered_sendout.result_test_code
--                    and source_state = 'noaddr';
--
--                if(v_noaddr_order_number is not null) then
--                    --dbms_output.put_line('v_noaddr_order_number: ' || v_noaddr_order_number);
--                    --dbms_output.put_line('v_noaddr_accession_number: ' || v_noaddr_accession_number);
--                    --dbms_output.put_line('v_noaddr_otc: ' || v_noaddr_otc);
--                    --dbms_output.put_line('v_noaddr_rtc: ' || v_noaddr_rtc);                
--                  
--                    delete from
--                        STATERPT_OWNER.GTT_FILTER_RESULTS_EXTRACT
--                    where
--                        order_number = v_noaddr_order_number
--                        and accession_number = v_noaddr_accession_number
--                        and order_test_code = v_noaddr_otc
--                        and result_test_code = v_noaddr_rtc                        
--                        and source_state = 'noaddr';
--                    commit;    
--                end if;
--                EXCEPTION when 
--                  no_data_found then 
--                    v_noaddr_order_number := null;                
--            end;
--        end loop;


--        for filtered_sendout in (
--          select
--            *
--          from
--            STATERPT_OWNER.GTT_FILTER_RESULTS_EXTRACT 
--          where 
--            source_state = 'facility'            
--        ) loop
--            begin
--                v_noaddr_order_number := null;
--                v_noaddr_accession_number := null;
--                v_noaddr_otc := null;
--                v_noaddr_rtc := null;
--                
--                select
--                    order_number,
--                    accession_number,
--                    order_test_code,
--                    result_test_code
--                into
--                    v_noaddr_order_number,
--                    v_noaddr_accession_number,
--                    v_noaddr_otc,
--                    v_noaddr_rtc
--                from
--                    STATERPT_OWNER.GTT_FILTER_RESULTS_EXTRACT
--                where
--                    order_number = filtered_sendout.order_number
--                    and accession_number = filtered_sendout.accession_number
--                    and order_test_code = filtered_sendout.order_test_code
--                    and result_test_code = filtered_sendout.result_test_code
--                    and source_state = 'noaddr';
--
--                if(v_noaddr_order_number is not null) then
--                    --dbms_output.put_line('v_noaddr_order_number: ' || v_noaddr_order_number);
--                    --dbms_output.put_line('v_noaddr_accession_number: ' || v_noaddr_accession_number);
--                    --dbms_output.put_line('v_noaddr_otc: ' || v_noaddr_otc);
--                    --dbms_output.put_line('v_noaddr_rtc: ' || v_noaddr_rtc);                
--                  
--                    delete from
--                        STATERPT_OWNER.GTT_FILTER_RESULTS_EXTRACT
--                    where
--                        order_number = v_noaddr_order_number
--                        and accession_number = v_noaddr_accession_number
--                        and order_test_code = v_noaddr_otc
--                        and result_test_code = v_noaddr_rtc                        
--                        and source_state = 'noaddr';
--                    commit;    
--                end if;
--                EXCEPTION when 
--                  no_data_found then 
--                    v_noaddr_order_number := null;                
--            end;
--        end loop;

/*
        insert into 
          STATERPT_OWNER.GTT_RESULTS_EXTRACT
          select 
            * 
          from 
            STATERPT_OWNER.GTT_FILTER_RESULTS_EXTRACT;
*/            
            
            
--        insert into 
--            STATERPT_OWNER.GTT_RESULTS_EXTRACT
--            select 
--                * 
--            from 
--                STATERPT_OWNER.GTT_FILTER_RESULTS_EXTRACT
--            
--            
--            where
--                ACTI_FACILITY_ID not in (
--                    select
--                        facility_id
--                    from
--                        STATERPT_OWNER.TEST_FACILITIES
--                    where
--                        status = 'active'
--                );            
--            
            
            
            

/*         
        insert into 
          STATERPT_OWNER.GTT_RESULTS_EXTRACT
          select 
            * 
          from 
            STATERPT_OWNER.GTT_FILTER_RESULTS_EXTRACT 
          where 
            source_state = 'patient';
            
        insert into 
          STATERPT_OWNER.GTT_RESULTS_EXTRACT
          select 
            * 
          from 
            STATERPT_OWNER.GTT_FILTER_RESULTS_EXTRACT 
          where 
            source_state = 'facility'; 
            
            
        for filtered_sendout in (
          select
            *
          from
            STATERPT_OWNER.GTT_FILTER_RESULTS_EXTRACT 
          where 
            source_state = 'sendout'            
        ) loop
          --dbms_output.put_line('filtered_sendout.order_number: ' || filtered_sendout.order_number);
          
          begin
            dbms_output.put_line('filtered_sendout.order_number: ' || filtered_sendout.order_number);

            
//            select
//              count(*)
//            into
//              v_gtt_filter_count
//            from
//              STATERPT_OWNER.INTRA_LABS_SENDOUT_NO_DEMO;
//            
//            select
//              distinct(order_number)
//            into
//              v_order_number
//            from
//              STATERPT_OWNER.INTRA_LABS_SENDOUT_NO_DEMO
//            where
//              order_number = filtered_sendout.order_number;
//
//            dbms_output.put_line('v_order_number: ' || v_order_number);
            
            
            select
              count(*)
            into
              v_gtt_filter_count              
            from
              (
	            select
	              distinct(order_number)
	            from
	              STATERPT_OWNER.INTRA_LABS_SENDOUT_NO_DEMO
	            where
	            	order_number = filtered_sendout.order_number                
              );            
            
              
            --if((v_order_number is null) or (length(ltrim(rtrim(v_order_number)))) = 0) then
            --if((v_gtt_filter_count = 0) or (v_order_number is null)) then
            if((v_gtt_filter_count = 0)) then
              insert into 
                STATERPT_OWNER.INTRA_LABS_SENDOUT_NO_DEMO
              (  
                  ACCESSION_NUMBER,
                  FACILITY_ID,
                  CID,
                  ETHNIC_GROUP,
                  PATIENT_RACE,
                  EXTERNAL_MRN,
                  PATIENT_LAST_NAME,
                  PATIENT_FIRST_NAME,
                  PATIENT_MIDDLE_NAME,
                  DATE_OF_BIRTH,
                  GENDER,
                  PATIENT_SSN,
                  NPI,
                  ORDERING_PHYSICIAN_NAME,
                  REPORT_NOTES,
                  SPECIMEN_RECEIVE_DATE,
                  COLLECTION_DATE,
                  COLLECTION_TIME,
                  COLLECTION_DATE_TIME,
                  DRAW_FREQ,
                  RES_RPRT_STATUS_CHNG_DT_TIME,
                  ORDER_DETAIL_STATUS,
                  ORDER_TEST_CODE,
                  ORDER_TEST_NAME,
                  RESULT_TEST_CODE,
                  RESULT_TEST_NAME,
                  RESULT_STATUS,
                  TEXTUAL_RESULT,
                  TEXTUAL_RESULT_FULL,
                  NUMERIC_RESULT,
                  UNITS,
                  REFERENCE_RANGE,
                  ABNORMAL_FLAG,
                  RELEASE_DATE_TIME,
                  RESULT_COMMENTS,
                  PERFORMING_LAB_ID,
                  ORDER_METHOD,
                  SPECIMEN_SOURCE,
                  ORDER_NUMBER,
                  LOGGING_SITE,
                  AGE,
                  FACILITY_NAME,
                  COND_CODE,
                  PATIENT_TYPE,
                  SOURCE_OF_COMMENT,
                  PATIENT_ID,
                  ALTERNATE_PATIENT_ID,
                  REQUISITION_STATUS,
                  FACILITY_ADDRESS1,
                  FACILITY_ADDRESS2,
                  FACILITY_CITY,
                  FACILITY_STATE,
                  FACILITY_ZIP,
                  FACILITY_PHONE,
                  PATIENT_ACCOUNT_ADDRESS1,
                  PATIENT_ACCOUNT_ADDRESS2,
                  PATIENT_ACCOUNT_CITY,
                  PATIENT_ACCOUNT_STATE,
                  PATIENT_ACCOUNT_ZIP,
                  PATIENT_HOME_PHONE,
                  LOINC_CODE,
                  LOINC_NAME,
                  VALUE_TYPE,
                  EAST_WEST_FLAG,
                  INTERNAL_EXTERNAL_FLAG,
                  LAST_UPDATE_TIME,
                  SEQUENCE_NO,
                  FACILITY_ACCOUNT_STATUS,
                  FACILITY_ACTIVE_FLAG,
                  MICRO_ISOLATE,
                  MICRO_ORGANISM_NAME,
                  LAB_FK,
                  CLINICAL_MANAGER,
                  MEDICAL_DIRECTOR,
                  ACTI_FACILITY_ID,
                  FMC_NUMBER,
                  REPORTABLE_STATE,
                  SOURCE_STATE,
                  NOTIFIED_FLAG,
                  NOTIFIED_TIME
              )values(
                  filtered_sendout.ACCESSION_NUMBER,
                  filtered_sendout.FACILITY_ID,
                  filtered_sendout.CID,
                  filtered_sendout.ETHNIC_GROUP,
                  filtered_sendout.PATIENT_RACE,
                  filtered_sendout.EXTERNAL_MRN,
                  filtered_sendout.PATIENT_LAST_NAME,
                  filtered_sendout.PATIENT_FIRST_NAME,
                  filtered_sendout.PATIENT_MIDDLE_NAME,
                  filtered_sendout.DATE_OF_BIRTH,
                  filtered_sendout.GENDER,
                  filtered_sendout.PATIENT_SSN,
                  filtered_sendout.NPI,
                  filtered_sendout.ORDERING_PHYSICIAN_NAME,
                  filtered_sendout.REPORT_NOTES,
                  filtered_sendout.SPECIMEN_RECEIVE_DATE,
                  filtered_sendout.COLLECTION_DATE,
                  filtered_sendout.COLLECTION_TIME,
                  filtered_sendout.COLLECTION_DATE_TIME,
                  filtered_sendout.DRAW_FREQ,
                  filtered_sendout.RES_RPRT_STATUS_CHNG_DT_TIME,
                  filtered_sendout.ORDER_DETAIL_STATUS,
                  filtered_sendout.ORDER_TEST_CODE,
                  filtered_sendout.ORDER_TEST_NAME,
                  filtered_sendout.RESULT_TEST_CODE,
                  filtered_sendout.RESULT_TEST_NAME,
                  filtered_sendout.RESULT_STATUS,
                  filtered_sendout.TEXTUAL_RESULT,
                  filtered_sendout.TEXTUAL_RESULT_FULL,
                  filtered_sendout.NUMERIC_RESULT,
                  filtered_sendout.UNITS,
                  filtered_sendout.REFERENCE_RANGE,
                  filtered_sendout.ABNORMAL_FLAG,
                  filtered_sendout.RELEASE_DATE_TIME,
                  filtered_sendout.RESULT_COMMENTS,
                  filtered_sendout.PERFORMING_LAB_ID,
                  filtered_sendout.ORDER_METHOD,
                  filtered_sendout.SPECIMEN_SOURCE,
                  filtered_sendout.ORDER_NUMBER,
                  filtered_sendout.LOGGING_SITE,
                  filtered_sendout.AGE,
                  filtered_sendout.FACILITY_NAME,
                  filtered_sendout.COND_CODE,
                  filtered_sendout.PATIENT_TYPE,
                  filtered_sendout.SOURCE_OF_COMMENT,
                  filtered_sendout.PATIENT_ID,
                  filtered_sendout.ALTERNATE_PATIENT_ID,
                  filtered_sendout.REQUISITION_STATUS,
                  filtered_sendout.FACILITY_ADDRESS1,
                  filtered_sendout.FACILITY_ADDRESS2,
                  filtered_sendout.FACILITY_CITY,
                  filtered_sendout.FACILITY_STATE,
                  filtered_sendout.FACILITY_ZIP,
                  filtered_sendout.FACILITY_PHONE,
                  filtered_sendout.PATIENT_ACCOUNT_ADDRESS1,
                  filtered_sendout.PATIENT_ACCOUNT_ADDRESS2,
                  filtered_sendout.PATIENT_ACCOUNT_CITY,
                  filtered_sendout.PATIENT_ACCOUNT_STATE,
                  filtered_sendout.PATIENT_ACCOUNT_ZIP,
                  filtered_sendout.PATIENT_HOME_PHONE,
                  filtered_sendout.LOINC_CODE,
                  filtered_sendout.LOINC_NAME,
                  filtered_sendout.VALUE_TYPE,
                  filtered_sendout.EAST_WEST_FLAG,
                  filtered_sendout.INTERNAL_EXTERNAL_FLAG,
                  filtered_sendout.LAST_UPDATE_TIME,
                  filtered_sendout.SEQUENCE_NO,
                  filtered_sendout.FACILITY_ACCOUNT_STATUS,
                  filtered_sendout.FACILITY_ACTIVE_FLAG,
                  filtered_sendout.MICRO_ISOLATE,
                  filtered_sendout.MICRO_ORGANISM_NAME,
                  filtered_sendout.LAB_FK,
                  filtered_sendout.CLINICAL_MANAGER,
                  filtered_sendout.MEDICAL_DIRECTOR,
                  filtered_sendout.ACTI_FACILITY_ID,
                  filtered_sendout.FMC_NUMBER,
                  filtered_sendout.REPORTABLE_STATE,
                  filtered_sendout.SOURCE_STATE,
                  'N',
                  null            
              );
                  
              COMMIT;
            end if;
            
            EXCEPTION when no_data_found
              then null; --or whatever you need here            
            
          end;  
        end loop;                
*/        
        
        --dbms_output.disable();
    

--        select * from STATERPT_OWNER.RESULTS_TEST_TABLE r
--        where patient_account_state = 'PA'
--        and order_number in ('5792ACU','5794RUU','5770YKU','5726X8U') and result_test_code = '331'
--        and r.LAST_UPDATE_TIME < '14-NOV-21 06.25.15.072368000 PM';
        
        --insert into STATERPT_OWNER.GTT_RESULTS_EXTRACT
        --select * from STATERPT_OWNER.GTT_RESULTS_EXTRACT;
        
        --where order_test_code = '301';
       -- where  order_number  in ('42820SA','42821SA','42822SA');
        
        --select v_sql into p_sql from dual;
        
        -- OPEN p_recordset FOR select * from STATERPT_OWNER.GTT_RESULTS_EXTRACT;
       
        --open p_recordset for select * from STATERPT_OWNER.RESULTS_TEST_TABLE;
        
       
      --insert into STATERPT_OWNER.GTT_RESULTS_EXTRACT 
      
      -- ****************** Delete MD 310A ***************************
      
      if(p_state = 'MD') then
        delete STATERPT_OWNER.GTT_RESULTS_EXTRACT where result_test_code = '310A';
      end if;
       
        select count(1) into p_gtt_count from STATERPT_OWNER.GTT_RESULTS_EXTRACT;
        
        
--        for rec IN (select * from GTT_RESULTS_EXTRACT)
--        loop
--        
--        
--        dbms_output.put_line(rec.reportable_state);
--        
--        end loop;
        
      --insert into STATERPT_OWNER.RESULTS_TEST_TABLE select * from STATERPT_OWNER.GTT_RESULTS_EXTRACT;
    
--    commit;
    
    -- run with snapshot test file
        -- snapshot
        --delete from STATERPT_OWNER.GTT_RESULTS_EXTRACT where accession_number is not null;
        commit;

--
--insert into STATERPT_OWNER.GTT_RESULTS_EXTRACT
--select * from ca_332_test;
--select * from pa_332_test;
--select * from il_test_data;
--select * from tx_test_data;
--commit;
--
--select count(1) into p_gtt_count from ca_332_test;

-- comment out for production


        
        
				EXCEPTION
				WHEN table_or_view_not_exist THEN
					dbms_output.put_line('Table STATERPT_OWNER.GTT_RESULTS_EXTRACT did not exist at time of truncate. Continuing....');

				WHEN attempted_ddl_on_in_use_GTT THEN
					dbms_output.put_line('STATERPT_OWNER.GTT_RESULTS_EXTRACT is in use. Commit!');
					raise;

				WHEN OTHERS THEN
					DBMS_OUTPUT.put_line ('Error in creating table STATERPT_OWNER.GTT_RESULTS_EXTRACT');
					DBMS_OUTPUT.put_line('v_error:'||sqlcode);
					DBMS_OUTPUT.put_line('v_sqlerrm:'||sqlerrm);
          dbms_output.put_line('Backtrace => '||dbms_utility.format_error_backtrace);
          dbms_output.put_line('SQLCODE => '||SQLCODE);           
					if sqlcode = -60 then -- deadlock error is ORA-00060
					  null;
					else
					  raise;
					end if;		
		END;
	
END SP_ASR_PROC_TRACK_RESULTS_Z;