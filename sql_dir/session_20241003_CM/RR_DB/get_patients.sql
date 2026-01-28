select * from HLAB_STATE_NYC_LOG
where order_number = '8421CB6'
order by run desc;

/

declare v_next_time timestamp(6) ;

BEGIN

BEGIN
         EXECUTE IMMEDIATE 'truncate table HLAB_NYC_RESULTS drop storage';
         COMMIT;
         EXECUTE IMMEDIATE 'truncate table TEMP_HLAB_ACTIVITY_NYC drop storage';
         COMMIT;

      END;

   BEGIN
      INSERT INTO TEMP_HLAB_ACTIVITY_NYC

select
          act.REQUISITION_ID,
          act.receiving_facility2	
        from
          (
            select
                distinct(a.REQUISITION_ID),
                a.receiving_facility2,
                r.REQUISITION_SSN,
                a.ACCESSION_NO,              
                r.patient_fk,
                dp.patient_id
            from
                RESULT_REPUSER.HLAB_ACTIVITY a,
                RESULT_REPUSER.FACT_RESULTS r,
                --RESULT_REPUSER.DIM_PATIENT dp
                RESULT_REPUSER.NDIM_REQ dp
            where
                a.ACCESSION_NO = r.ACCESSION_NO and
                a.receiving_facility2 LIKE '%E' AND 
                a.receiving_facility2 NOT LIKE '8%' AND
              (
                (a.receiving_facility2 not like '%TEST%') or 
                (a.receiving_facility2 not like '%Test%') or 
                (a.receiving_facility2 not like '%TEST') or 
                (a.receiving_facility2 not like '%Test') or 
                (a.receiving_facility2 not like '%TES')
              ) and              
                r.REQUISITION_SSN <> '000000000' AND
                r.requisition_id = dp.requisition_id and
                --r.facility_fk in (select facility_pk from RESULT_REPUSER.dim_facility where facility_state in ('NY', 'Ny')) and
              --(to_date(a.release_date_time, 'YYYY-MM-DD HH24:MI') >= (sysdate - 7)) and              
              --  a.last_update_time  >= v_start_time
              r.requisition_id = '22754Y7'
              --a.LAST_UPDATE_TIME between '26-JUN-24 01.3.51.085130000 PM' and '27-JUN-24 02.31.51.085130000 PM'
              --a.LAST_UPDATE_TIME between '21-MAY-22 02.23.39.950700000 AM' and '22-MAY-22 02.23.39.950700000 AM'
              --a.LAST_UPDATE_TIME between '22-MAY-22 02.23.39.950700000 AM' and '23-MAY-22 02.23.39.950700000 AM'
              --a.LAST_UPDATE_TIME between '23-MAY-22 02.23.39.950700000 AM' and '24-MAY-22 02.23.39.950700000 AM'
              --a.LAST_UPDATE_TIME between '24-MAY-22 02.23.39.950700000 AM' and '25-MAY-22 02.23.39.950700000 AM'
             
              --  a.LAST_UPDATE_TIME between '25-MAY-22 02.23.39.950700000 AM' and '26-MAY-22 02.23.39.950700000 AM'
              --a.LAST_UPDATE_TIME between '26-MAY-22 02.23.39.950700000 AM' and '27-MAY-22 02.23.39.950700000 AM'
              
              --a.LAST_UPDATE_TIME between '27-MAY-22 02.23.39.950700000 AM' and '28-MAY-22 02.23.39.950700000 AM'
                 --a.LAST_UPDATE_TIME between '28-MAY-22 02.23.39.950700000 AM' and '29-MAY-22 02.23.39.950700000 AM'
                 --a.LAST_UPDATE_TIME between '29-MAY-22 02.23.39.950700000 AM' and '30-MAY-22 02.23.39.950700000 AM'
                 --a.LAST_UPDATE_TIME between '30-MAY-22 02.23.39.950700000 AM' and '31-MAY-22 02.23.39.950700000 AM'
                 --a.LAST_UPDATE_TIME between '31-MAY-22 02.23.39.950700000 AM' and '01-JUN-22 02.23.39.950700000 AM'
                 --a.LAST_UPDATE_TIME between '01-JUN-22 02.23.39.950700000 AM' and '02-JUN-22 02.23.39.950700000 AM'
              -- * a.LAST_UPDATE_TIME between '02-JUN-22 02.23.39.950700000 AM' and '03-JUN-22 02.23.39.950700000 AM'
                 -- *a.LAST_UPDATE_TIME between '03-JUN-22 02.23.39.950700000 AM' and '04-JUN-22 02.23.39.950700000 AM'
                 --a.LAST_UPDATE_TIME between '04-JUN-22 02.23.39.950700000 AM' and '13-JUN-22 02.23.39.950700000 AM'
                 --a.LAST_UPDATE_TIME between '05-JUN-22 02.23.39.950700000 AM' and '06-JUN-22 02.23.39.950700000 AM'
                 --a.LAST_UPDATE_TIME between '06-JUN-22 02.23.39.950700000 AM' and '07-JUN-22 02.23.39.950700000 AM'
                 --a.LAST_UPDATE_TIME between '07-JUN-22 02.23.39.950700000 AM' and '08-JUN-22 02.23.39.950700000 AM'
                 --a.LAST_UPDATE_TIME between '08-JUN-22 02.23.39.950700000 AM' and '09-JUN-22 02.23.39.950700000 AM'
                 --a.LAST_UPDATE_TIME between '09-JUN-22 02.23.39.950700000 AM' and '10-JUN-22 02.23.39.950700000 AM'
                 --a.LAST_UPDATE_TIME between '10-JUN-22 02.23.39.950700000 AM' and '11-JUN-22 02.23.39.950700000 AM'
                 --a.LAST_UPDATE_TIME between '11-JUN-22 02.23.39.950700000 AM' and '12-JUN-22 02.23.39.950700000 AM'
                 --a.LAST_UPDATE_TIME between '12-JUN-22 02.23.39.950700000 AM' and '13-JUN-22 02.23.39.950700000 AM'
                 --a.LAST_UPDATE_TIME between '27-JUN-22 03.16.04.633703000 AM' and '30-JUN-22 02.23.39.950700000 AM'
              
              
              --and r.patient_fk = dp.PATIENT_PK  				  			
              
          ) act,
          (
                select
                       *
                from
                       dl_all_patients
                where
                       state = 'NY'
                       and zip in (
                         select
                            zip
                         from
                            WH_TRACK.DL_ZIP_CODE
                         where
                            state_abbrev = 'NY'
                            and county in ('New York','Bronx','Kings','Queens','Richmond')            
              )            
          ) nycp	
        where
          --(act.patient_id = nycp.eid or act.REQUISITION_SSN = nycp.ssn);
          (act.patient_id = nycp.eid);
          
      
        
  
  
  MERGE INTO HLAB_NYC_RESULTS dest
           
        USING 
       (SELECT 
            distinct(fact_results.accession_no) accession_no,
            dim_facility.facility_id facility_id, dim_facility.cid cid,
             --fact_results.accession_no accession_no,
            --------------------------------------------------------------------------             
            --eid_mrn_map2.mrn mrn,
            --dim_patient.patient_name patient_name,
            --dim_patient.date_of_birth date_of_birth,
            --dim_patient.gender gender,
            --------------------------------------------------------------------------
            ndr.requisition_mrn  mrn, 
            /*
            p.LAST_NAME||', '||p.FIRST_NAME  patient_name,
            p.DOB date_of_birth,
            SUBSTR(p.GENDER, 0, 1) gender,
            */
            ndr.requisition_patient_name patient_name,
             (
                CASE ndr.requisition_dob 
                  WHEN '0'  THEN NULL 
                  ELSE to_date(rpad(trim(ndr.requisition_dob), 8, 1),'YYYYMMDD')
                END
             ) date_of_birth,            
            SUBSTR(ndr.requisition_gender, 0, 1) gender,            
            --------------------------------------------------------------------------             
             fact_results.requisition_ssn patient_ssn, dim_physician.npi npi,
             fact_results.ordering_physician_name ordering_physician_name,
             --fact_results.report_notes report_notes,
             trim(dbms_lob.substr( fact_results.report_notes, 4000, 1 )) as report_notes,
             fact_results.specimen_receive_date specimen_receive_date,
             fact_results.collection_date collection_date,
             fact_results.collection_time collection_time,
             fact_results.draw_freq draw_freq,
             fact_results.res_rprt_status_chng_dt_time res_rprt_status_chng_dt_time,
             fact_results.order_status order_status,
             fact_results.compound_test_code compound_test_code,
             dim_test.test_code test_code,
             dim_test.result_name result_name,
             dim_test.test_name test_name,
             fact_results.result_status result_status,
             fact_results.textual_numeric_result  textual_numeric_result,
             fact_results.units units,
             fact_results.reference_range reference_range,
             fact_results.abnormal_flag abnormal_flag,
             fact_results.release_date release_date,
             fact_results.release_time release_time,
             --fact_results.result_comments result_comments,
             trim(dbms_lob.substr( fact_results.result_comments, 4000, 1 )) as result_comments,
             fact_results.performing_lab_id performing_lab_id,
             fact_results.order_method order_method,
             fact_results.specimen_source specimen_source,
             fact_results.order_number order_number,
             fact_results.logging_site logging_site,
             -------------------------------------------------------------------
             --dim_patient.age age,
             NULL age,
             -------------------------------------------------------------------              
             dim_facility.facility_name facility_name,
             fact_results.cond_code cond_code,
             fact_results.patient_type patient_type,
             fact_results.source_of_comment source_of_comment,
             -------------------------------------------------------------------             
            dim_patient.patient_id patient_id,
            dim_patient.alternate_patient_id alternate_patient_id,
            fact_results.requisition_status requisition_status,
            -------------------------------------------------------------------              
            dim_facility.facility_address1 facility_address1, 
            dim_facility.facility_address2 facility_address2,
            dim_facility.facility_city facility_city, 
            dim_facility.facility_state facility_state,
            dim_facility.facility_zip facility_zip, 
            dim_facility.facility_phone facility_phone,
             -------------------------------------------------------------------             
            p.ADDRESS patient_account_address1, 
            NULL      patient_account_address2, 
            p.CITY    patient_account_city, 
            p.STATE   patient_account_state, 
            p.ZIP     patient_account_zip, 
            replace(p.PHONE,'-')  patient_home_phone,  
             -------------------------------------------------------------------             
            --dim_patient.patient_account_address1 patient_account_address1, 
            --dim_patient.patient_account_address2 patient_account_address2, 
            --dim_patient.patient_account_city     patient_account_city, 
            --dim_patient.patient_account_state    patient_account_state, 
            --dim_patient.patient_account_zip      patient_account_zip, 
            --dim_patient.patient_home_phone       patient_home_phone,    
--------------------------------------------------------------------------------              
            fact_results.loinc_code loinc_code,
            fact_results.loinc_name loinc_name,
            SYSTIMESTAMP(6) last_update_time                 
          FROM   result_repuser.dim_facility,
                 result_repuser.fact_results,
                 result_repuser.dim_patient,
                 result_repuser.dim_test,
                 result_repuser.dim_physician,
                 --wh_track.eid_mrn_map2,
                 --wh_track.TEMP_HLAB_ACTIVITY_STATE acti,
                 wh_track.TEMP_HLAB_ACTIVITY_NYC acti,
            -------------------------------------------------------------------             
            -- trac_patient_view@LNK_WH_TRACK_TO_MDPROD01 p,
            --NYC_PATIENTS  p,
            --TMP_NYC_PATIENTS  p,
            
            (
                select
                    *
                from
                    dl_all_patients
                where
                    state = 'NY'
                    and zip in (
                      select
                        zip
                      from
                        WH_TRACK.DL_ZIP_CODE
                      --where
                      --  state_abbrev = 'NY'
                      --  and county in ('New York','Bronx','Kings','Queens','Richmond')            
                    )            
            ) p,
            result_repuser.ndim_req  ndr
            -------------------------------------------------------------------     
            
               
          WHERE  
             -------------------------------------------------------------------             
             (ndr.requisition_id   = fact_results.requisition_id)
             and ((trim(fact_results.requisition_ssn) <> '000000000' AND (ndr.patient_id = p.eid or ndr.REQUISITION_SSN = p.ssn)))
             --and ((trim(fact_results.requisition_ssn) <> '000000000' AND (ndr.patient_id = p.eid)))
             --and ((ndr.patient_id = p.eid or ndr.REQUISITION_SSN = p.ssn))
             /*
             AND
             -------------------------------------------------------------------             
             ((trim(fact_results.requisition_ssn) <> '000000000' AND trim(fact_results.requisition_ssn) = trim(p.ssn))
               OR (trim(dim_patient.patient_id) = trim(p.EID)))
            */   
            -------------------------------------------------------------------           
              
          AND  dim_test.TEST_CODE = '525' 
          
          AND  fact_results.facility_fk = dim_facility.facility_pk
          AND  fact_results.patient_fk = dim_patient.patient_pk
          AND  fact_results.test_fk = dim_test.test_pk
          AND  fact_results.physician_fk = dim_physician.physician_pk
          --AND  dim_facility.facility_id = eid_mrn_map2.facility_id
          --AND  dim_patient.patient_id = eid_mrn_map2.eid
          AND  fact_results.requisition_id = acti.requisition_id
          --AND  SUBSTR (acti.receiving_facility2, 0, 5) = dim_facility.facility_id
          and trim(substr(acti.receiving_facility2, 0, length(acti.receiving_facility2) - 1)) = dim_facility.facility_id
       ) src


      ON  ( dest.accession_no = src.accession_no
            AND dest.facility_id = src.facility_id
            AND dest.patient_id = src.patient_id
            AND dest.result_name = src.result_name 
            AND dest.test_code = src.test_code 
            AND dest.textual_numeric_result = src.textual_numeric_result
            AND dest.last_update_time = src.last_update_time            
          )
          
      WHEN MATCHED THEN
         UPDATE
            SET dest.current_run_time = v_next_time
      WHEN NOT MATCHED THEN
      
      INSERT (dest.facility_id, dest.cid, dest.accession_no, dest.mrn,
           dest.patient_name, dest.date_of_birth, dest.gender,
           dest.patient_ssn, dest.npi, dest.ordering_physician_name,
           dest.report_notes, dest.specimen_receive_date,
           dest.collection_date, dest.collection_time, dest.draw_freq,
           dest.res_rprt_status_chng_dt_time, dest.order_status,
           dest.compound_test_code, dest.test_code, dest.result_name,
           dest.test_name, dest.result_status, dest.textual_numeric_result,
           dest.units, dest.reference_range, dest.abnormal_flag,
           dest.release_date, dest.release_time, dest.result_comments,
           dest.performing_lab_id, dest.order_method, dest.specimen_source,
           dest.order_number, dest.logging_site, dest.age, dest.facility_name,
           dest.cond_code, dest.patient_type, dest.source_of_comment,
           dest.patient_id, dest.alternate_patient_id, dest.current_run_time, 
           dest.requisition_status,
            dest.facility_address1,
            dest.facility_address2,
            dest.facility_city, 
            dest.facility_state,
            dest.facility_zip, 
            dest.facility_phone,
            dest.patient_account_address1, 
            dest.patient_account_address2, 
            dest.patient_account_city, 
            dest.patient_account_state, 
            dest.patient_account_zip, 
            dest.patient_home_phone,
            dest.loinc_code,
            dest.loinc_name,
            dest.last_update_time  
      )
      VALUES (src.facility_id, src.cid, src.accession_no, src.mrn,
           src.patient_name, src.date_of_birth, src.gender, src.patient_ssn,
           src.npi, src.ordering_physician_name, src.report_notes,
           src.specimen_receive_date, src.collection_date,
           src.collection_time, src.draw_freq,
           src.res_rprt_status_chng_dt_time, src.order_status,
           src.compound_test_code, src.test_code, src.result_name,
           src.test_name, src.result_status, src.textual_numeric_result,
           src.units, src.reference_range, src.abnormal_flag,
           src.release_date, src.release_time, src.result_comments,
           src.performing_lab_id, src.order_method, src.specimen_source,
           src.order_number, src.logging_site, src.age, src.facility_name,
           src.cond_code, src.patient_type, src.source_of_comment,
           src.patient_id, src.alternate_patient_id, v_next_time, src.requisition_status,
            src.facility_address1, 
            src.facility_address2,
            src.facility_city, 
            src.facility_state,
            src.facility_zip, 
            src.facility_phone,
            src.patient_account_address1, 
            src.patient_account_address2, 
            src.patient_account_city, 
            src.patient_account_state, 
            src.patient_account_zip, 
            src.patient_home_phone,
            src.loinc_code,
            src.loinc_name,
            src.last_update_time  
      );
      
      END;
      
END;

/

select
                distinct(a.REQUISITION_ID),
                a.receiving_facility2,
                r.REQUISITION_SSN,
                a.ACCESSION_NO,              
                r.patient_fk,
                dp.patient_id
            from
                RESULT_REPUSER.HLAB_ACTIVITY a,
                RESULT_REPUSER.FACT_RESULTS r,
                --RESULT_REPUSER.DIM_PATIENT dp
                RESULT_REPUSER.NDIM_REQ dp
            where rownum < 3;

select * from TEMP_HLAB_ACTIVITY_NYC;

select * from result_repuser.ndim_req
where patient_id = '8002209159';

select * from 
(
select
                    *
                from
                    dl_all_patients
                where
                    state = 'NY'
                    and zip in (
                      select
                        zip
                      from
                        WH_TRACK.DL_ZIP_CODE
                      where
                        state_abbrev = 'NY'
                        and county in ('New York','Bronx','Kings','Queens','Richmond')            
                    )            
            ) p where eid = '8003726492';
            
select PATIENT_ACCOUNT_ADDRESS1,PATIENT_ACCOUNT_ADDRESS2 from RESULT_REPUSER.dim_patient
where patient_id = '8002209159';

select r.patient_id,order_number,patient_account_address1,patient_account_address2,patient_account_city,patient_account_state,patient_account_zip,r.LAST_UPDATE_TIME from HLAB_NYC_RESULTS r;

select * from RESULT_REPUSER.fact_results
where requisition_id IN '22754Y7'
and COMPOUND_TEST_CODE = '525';

select * from HLAB_STATE_NYC_LOG
where order_number = '22754Y7'
--and PATIENT_HOME_PHONE is null
order by run desc;

select * from RESULT_REPUSER.dim_patient
where patient_id = '8002209159';
