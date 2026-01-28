create or replace PROCEDURE            "SP_CREATE_NYC_RESULTS" 

                  ( p_interface  IN VARCHAR2
                  , p_start_date IN VARCHAR2
                  , p_end_date   IN VARCHAR2
                  , rc OUT NUMBER
                  ) AS

   v_next_time                   TIMESTAMP ( 6 ) := SYSTIMESTAMP;
   v_start_time                  TIMESTAMP ( 6 );
   v_error_flag                  BOOLEAN := FALSE;
   v_count                       NUMBER := 0;
   
   v_start DATE := TO_DATE(p_start_date, 'DD-MON-RR');
   v_end   DATE := TO_DATE(p_end_date, 'DD-MON-RR');

   v_results    VARCHAR2(30) := '_RESULTS';
   v_interface  VARCHAR2(30) := UPPER(p_interface) || '_RESULTS';
  
BEGIN
   BEGIN
      --INSERT INTO wh_track.process_tracking
      --            (start_time, process_name, status, last_updated)
      --     VALUES (v_next_time, v_interface, '0', v_next_time);
      --COMMIT;
      
      SELECT MAX (process_tracking.start_time)
            INTO   v_start_time
            FROM   wh_track.process_tracking
            WHERE  process_tracking.process_name = v_interface
            AND    process_tracking.status = '1';
      
      dbms_output.put_line('v_start_time = ' || v_start_time);
      dbms_output.put_line('v_next_time = ' || v_next_time);
      
      INSERT INTO wh_track.process_tracking
                  (start_time, process_name, status, last_updated)
           VALUES (v_next_time, v_interface, '1', v_next_time);
      COMMIT;      
      
     EXCEPTION
      WHEN OTHERS THEN
         v_error_flag   := TRUE;
   END;

   IF (v_error_flag = FALSE) THEN  
   
   
      BEGIN
         EXECUTE IMMEDIATE 'truncate table HLAB_NYC_RESULTS drop storage';
         COMMIT;
         EXECUTE IMMEDIATE 'truncate table TEMP_HLAB_ACTIVITY_NYC drop storage';
         COMMIT;

      END;

   BEGIN
      INSERT INTO TEMP_HLAB_ACTIVITY_NYC
        /*----------------------------------------------------------------------
        /* THIS is the NEW old logic...!! using TRACK...  18-OCT-12 12.35 PM  
        --------------------------------------------------------------------- */
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
--                a.receiving_facility2 NOT LIKE '8%' AND
--              (
--                (a.receiving_facility2 not like '%TEST%') or 
--                (a.receiving_facility2 not like '%Test%') or 
--                (a.receiving_facility2 not like '%TEST') or 
--                (a.receiving_facility2 not like '%Test') or 
--                (a.receiving_facility2 not like '%TES')
--              ) and              
                r.REQUISITION_SSN <> '000000000' AND
                r.requisition_id = dp.requisition_id and
                --r.facility_fk in (select facility_pk from RESULT_REPUSER.dim_facility where facility_state in ('NY', 'Ny')) and
              --(to_date(a.release_date_time, 'YYYY-MM-DD HH24:MI') >= (sysdate - 7)) and              
              --  a.last_update_time  >= v_start_time
              
              --a.LAST_UPDATE_TIME between '20-MAY-22 02.23.39.950700000 AM' and '21-MAY-22 02.23.39.950700000 AM'
              --a.LAST_UPDATE_TIME between '21-MAY-22 02.23.39.950700000 AM' and '22-MAY-22 02.23.39.950700000 AM'
              --a.LAST_UPDATE_TIME between '22-MAY-22 02.23.39.950700000 AM' and '23-MAY-22 02.23.39.950700000 AM'
              --a.LAST_UPDATE_TIME between '23-MAY-22 02.23.39.950700000 AM' and '24-MAY-22 02.23.39.950700000 AM'
              --a.LAST_UPDATE_TIME between '24-MAY-22 02.23.39.950700000 AM' and '25-MAY-22 02.23.39.950700000 AM'
             
              --  a.LAST_UPDATE_TIME between '25-MAY-22 02.23.39.950700000 AM' and '26-MAY-22 02.23.39.950700000 AM'
              --a.LAST_UPDATE_TIME between '26-MAY-22 02.23.39.950700000 AM' and '27-MAY-22 02.23.39.950700000 AM'
              
              a.LAST_UPDATE_TIME between '27-MAY-24 02.23.39.950700000 AM' and '28-SEP-24 02.23.39.950700000 AM'
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
          
/*        
        SELECT 
          DISTINCT(h.requisition_id), 
          h.receiving_facility2  --,requisition_ssn,  p.STATE, p.zip
        FROM result_repuser.hlab_activity h
           JOIN result_repuser.fact_results f
             ON f.requisition_id = h.requisition_id
        
         JOIN result_repuser.dim_patient d
           ON f.patient_fk = d.patient_pk

          JOIN 
               NYC_PATIENTS p 
               ON ((trim(f.requisition_ssn) <> '000000000' AND trim(f.requisition_ssn) = trim(p.ssn)) OR (trim(d.PATIENT_ID) = trim(p.EID)))
      
          WHERE --p.ZIP in (select zip from NYC_ZIPS)  AND  
                h.receiving_facility2     LIKE '%E' AND
                h.receiving_facility2 NOT LIKE '8%' AND 
                h.last_update_time  >= v_start_time;
                --h.last_update_time  >= '28-AUG-17 12.00.00.00000000 AM' and
                --h.last_update_time  < '03-SEP-17 12.00.00.00000000 AM';
*/                
        --------------------------------------------------------------------- */


      /*------------------------------------------------------------------------
        LAST RUN NYC:  using THIS Original/Old logic...!!
         '16-OCT-12 01.00.08.350857000 PM -04:00'
         
        SELECT distinct h.requisition_id, h.receiving_facility2
        FROM   result_repuser.hlab_activity h
           INNER join result_repuser.DIM_FACILITY f ON f.facility_id = SUBSTR (h.receiving_facility2, 0, 5)
        WHERE (f.east_west_flag='SE')
               AND f.facility_ZIP in (select zip from NYC_ZIPS)
               AND h.receiving_facility2 NOT LIKE '8%'
        AND    h.last_update_time  >= v_start_time;  
      ----------------------------------------------------------------------- */


      ---Misc --------------------------------------------------------------------
      -- WHERE (f.account_status='Active' and  f.east_west_flag='SE')
      --            SELECT distinct h.requisition_id, h.receiving_facility2
      --            FROM   result_repuser.hlab_activity h
      --               INNER join wh_track.facility_interface_prod i ON TO_CHAR (i.facility_id) = SUBSTR (h.receiving_facility2, 0, 5)
      --            WHERE  i.interface_type IN (p_interface)
      --            AND    SUBSTR (h.receiving_facility2, 0, 5) = TO_CHAR (i.facility_id)
      --              AND    h.last_update_time  >= v_start_time;              
      --          --  AND    h.last_update_time >= v_start; // <-- not the incoming parameter!!

      rc:= sql%rowcount ;
      
      COMMIT;
    END;

    BEGIN
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
                      where
                        state_abbrev = 'NY'
                        and county in ('New York','Bronx','Kings','Queens','Richmond')            
                    )            
            ) p,
            result_repuser.ndim_req  ndr
            -------------------------------------------------------------------     
            
               
          WHERE  
             -------------------------------------------------------------------             
             (ndr.requisition_id   = fact_results.requisition_id)
             --and ((trim(fact_results.requisition_ssn) <> '000000000' AND (ndr.patient_id = p.eid or ndr.REQUISITION_SSN = p.ssn)))
             and ((trim(fact_results.requisition_ssn) <> '000000000' AND (ndr.patient_id = p.eid)))
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

      --  rc:= sql%rowcount ;
         
      COMMIT;

      EXCEPTION
         WHEN OTHERS THEN
         
            DBMS_OUTPUT.put_line ('Error in creating table HLAB_NYC_RESULTS');
            DBMS_OUTPUT.put_line('v_error:'||sqlcode);
            DBMS_OUTPUT.put_line('v_sqlerrm:'||sqlerrm);
            if sqlcode = -60 then -- deadlock error is ORA-00060
              null;
            else
              raise;
            end if;             
    END;
      
  ------- do not send Bad test codes and HIV test codes  
  ------- see above select dim_test.TEST_CODE = '525' 
  
/*  
  BEGIN
     delete from 
        HLAB_NYC_RESULTS
      where
        HLAB_NYC_RESULTS.accession_no in
        (
            select
              distinct(r.accession_no)
            from
              HLAB_NYC_RESULTS r,
              HLAB_STATE_NYC_LOG l
            where
              r.order_number = l.order_number
              and r.accession_no = l.accession_no
              and r.compound_test_code = l.compound_test_code
              and r.test_code = l.test_code
              and r.release_date = l.release_date
              and r.release_time = l.release_time      
        );
     commit;   
  END;
*/  
    BEGIN
       delete from 
          HLAB_NYC_RESULTS
        where
          (accession_no || order_number || compound_test_code || test_code) in
          (
              select
                distinct(r.accession_no || r.order_number || r.compound_test_code || r.test_code)
              from
                HLAB_NYC_RESULTS r,
                HLAB_STATE_NYC_LOG l
              where
                r.order_number = l.order_number
                and r.accession_no = l.accession_no
                and r.compound_test_code = l.compound_test_code
                and r.test_code = l.test_code
                and r.release_date = l.release_date
                and r.release_time = l.release_time 
          );
       commit;   
    END;  
  
     BEGIN
     
       delete from HLAB_NYC_RESULTS 
            where  LENGTH(HLAB_NYC_RESULTS.TEST_CODE) > 5
                   OR LENGTH(HLAB_NYC_RESULTS.accession_no ) < 9
                   OR HLAB_NYC_RESULTS.result_comments like ( 'Conflicting or overlapping test%' )
            --       OR HLAB_NYC_RESULTS.TEST_CODE IN ( 'BC','TNT','CC','CR','CS','101H','150H','200Z',
            --              '378', '328', '328A','328D','62H','125Q','80M','128Q','156Q','131Z','129Q',
            --              '335','335X','335C'  ) 
---------------- 2012-12-20
                  OR 
                  ( 
                    HLAB_NYC_RESULTS.order_method = 'ARUP' 
                  )
---------------            
                   OR HLAB_NYC_RESULTS.order_number IS NULL 
                   OR textual_numeric_result like 'CANCELLED%' 
                   OR textual_numeric_result like 'PENDING%'
                   OR HLAB_NYC_RESULTS.order_method = 'MOL';
            -- OR HLAB_NYC_RESULTS.release_time < v_start_time;                   
     COMMIT;
     END;
        
           -- SELECT v_start_time as start_time, v_next_time as next_time, 
      
      BEGIN
              INSERT INTO HLAB_STATE_NYC_LOG
               
              SELECT SYSTIMESTAMP as run, HLAB_NYC_RESULTS.* FROM HLAB_NYC_RESULTS;
              
              COMMIT;
      END;

   END IF;
   

END SP_CREATE_NYC_RESULTS;
/

select * from process_tracking
order by last_updated desc;

/

declare v_out number;

begin

SP_CREATE_NYC_RESULTS('NYC','01-JUN-24','17-SEP-24',v_out);

dbms_output.put_line(v_out);

end;

/

