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
              r.requisition_id in 
              ('2079SX7','1358GR4','2029K17','2079T37','2079T47','2079T67','13548J4','2079ST7','20761C7','2079SH7','2003BX7','1928R77','1928PK7','1847J27','1370FX4','2079SU7','2079SP7','2079SR7','2079T17','2029JZ7','2079SW7','2079T07','2079T87','2079T97','2079TB7','2079TC7','2079TF7','2079TJ7',
              '2102PZ7','2132RM7','2147AG7','2147AT7','2159TA7','23467W7','2348S37','2351MN7','2422J77','2423MY7','2467X07','2481NA7','24886H7','2494CZ7','26450M7','2646XM7','2647RH7','2134AC7','2139WX7')
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
      
      END;
      
END;

/
select requisition_id,LAST_UPDATE_TIME from result_repuser.fact_results
where requisition_id IN
(select order_number from HLAB_NYC_RESULTS)
and compound_test_code = '525'
order by last_update_time;

select * from result_repuser.ndim_req
where patient_id = '8002209159';

select * from 
(
select
                    *
                from
                    dl_all_patients
                where eid  = '8003822838';
                
                where
                    state = 'NY'
                    and zip in (
                      select
                        *
                      from
                        WH_TRACK.DL_ZIP_CODE
                      where zip = '11101'
                      and
                        state_abbrev = 'NY'
                        and county in ('New York','Bronx','Kings','Queens','Richmond')            
                    )            
            ) p where eid = '8003822838';
            
select PATIENT_ACCOUNT_ADDRESS1,PATIENT_ACCOUNT_ADDRESS2 from RESULT_REPUSER.dim_patient
where patient_id = '8002209159';

CREATE TABLE "PATIENTMASTER" ("EID" VARCHAR2(30 BYTE), "MRN" VARCHAR2(75 BYTE), "LNAME" VARCHAR2(75 BYTE), "FNAME" VARCHAR2(30 BYTE), "MNAME" VARCHAR2(30 BYTE), "STLINE1" VARCHAR2(150 BYTE), "STLINE2" VARCHAR2(150 BYTE), "CITY" VARCHAR2(50 BYTE), "STATE" VARCHAR2(15 BYTE), "ZIPCODE" VARCHAR2(10 BYTE), "PHNUMBER" VARCHAR2(50 BYTE), "DOB" VARCHAR2(19 BYTE), "SSN" VARCHAR2(40 BYTE), "SEX" VARCHAR2(10 BYTE), "LAB_FK" NUMBER(3,0), "TABLE_UPDATED" DATE DEFAULT sysdate) ;


select max(last_update_time) from DL_ALL_PATIENTS;
where rownum < 10
order by LAST_UPDATE_TIME desc;

select * from patientmaster;

select r.patient_id,order_number,patient_account_address1,patient_account_address2,patient_account_city,patient_account_state,patient_account_zip,r.LAST_UPDATE_TIME from HLAB_NYC_RESULTS r;

---select run,l.order_number,l.performing_lab_id,l.test_code,l.PATIENT_ID,PATIENT_NAME,PATIENT_ACCOUNT_ADDRESS1,PATIENT_ACCOUNT_ADDRESS2,PATIENT_ACCOUNT_CITY,PATIENT_ACCOUNT_ZIP 
select * from HLAB_STATE_NYC_LOG l
--left outer join result_repuser.fact_results r ON r.requisition_id = l.order_number
--where l.order_number IN
--where requisition_id IN
--('2079SX7','1358GR4','2029K17','2079T37','2079T47','2079T67','13548J4','2079ST7','20761C7','2079SH7','2003BX7','1928R77','1928PK7','1847J27','1370FX4',
--'2079SU7','2079SP7','2079SR7','2079T17','2029JZ7','2079SW7','2079T07','2079T87','2079T97','2079TB7','2079TC7','2079TF7','2079TJ7','2102PZ7','2132RM7',
--'2147AG7','2147AT7','2159TA7','23467W7','2348S37','2351MN7','2422J77','2423MY7','2467X07','2481NA7','24886H7','2494CZ7','26450M7','2646XM7','2647RH7',
--'2134AC7','2139WX7')
--
where l.RELEASE_TIME > '27-SEP-24 03.03.19.975284000 AM'
and l.TEST_CODE = '525' and l.PATIENT_ACCOUNT_STATE = 'NY';
and patient_account_state = 'NY'
order by l.LAST_UPDATE_TIME;
group by performing_lab_id,test_code;
--and PATIENT_HOME_PHONE is null
order by run desc;

select * from DL_ALL_PATIENTS
where eid IN
('8003132981'
,'8003504665'
,'8003058516'
,'8003418354'
,'8003980295');

select * from hlab_nyc_results;

select * from RESULT_REPUSER.dim_patient
where patient_id = '8002209159';

select max(LAST_UPDATE_TIME) from dl_all_patients
where rownum < 2
order by LAST_UPDATE_TIME desc;

select * from process_tracking
order by last_updated desc;

select * from dl_all_patients
where state = 'NY' 
and  eid = '8003822838';

select * from patientmaster@asr_ihubprd
where eid = '8003822838';

delete PATIENTMASTER;

commit;

insert into patientmaster
select * from patientmaster@asr_ihubprd;

/

begin



merge into dl_all_patients dl
using (
  select * from patientmaster 
  where lab_fk = 5 and state = 'NY'
) u
ON (dl.eid = u.eid)
when matched then
  update set dl.last_update_time = systimestamp,source='PATIENTMASTER'
when not matched then
  insert (
  dl.eid
  ,dl.ssn
  ,dl.last_name
  ,dl.first_name
  ,dl.address
  ,dl.city
  ,dl.state
  ,dl.zip
  ,dl.phone
  ,dl.dob
  ,last_update_time
  ,source )
  values (
  u.eid
  ,u.ssn
  ,u.lname
  ,u.fname
  ,u.stline1
  ,u.city
  ,u.state
  ,u.zipcode
  ,u.phnumber
  ,to_date(u.dob,'rrrr-MM-dd')
  ,systimestamp
  ,'PATIENTMASTER');

end;

/

drop database link asr_ihubprd;


create database LINK ASR_IHUBPRD
CONNECT TO staterpt_user IDENTIFIED BY "madly81-expelled"
USING '(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=korusdb1-scan.spectraeastnj.com)(PORT=1521))(CONNECT_DATA=(SERVICE_NAME=ihubprd)))';

select * from PATIENTMASTER@asr_ihubprd;



