select * from process_tracking;

update process_tracking
set LAST_UPDATED = '01-JUL-24 02.14.47.739288000 PM',
START_TIME = '01-JUL-24 02.14.47.739288000 PM';

select p.PATIENT_ACCOUNT_CITY,r.COLLECTION_DATE,r.COLLECTION_TIME
from RESULT_REPUSER.FACT_RESULTS r
join RESULT_REPUSER.NDIM_REQ dp ON dp.REQUISITION_ID = r.REQUISITION_ID
join RESULT_REPUSER.DIM_PATIENT p ON p.patient_pk = r.patient_fk
where r.REQUISITION_ID = '1ER4ZT7'
and compound_test_code = '525';

select * from nyc_patients;

delete process_tracking;

select * from HLAB_STATE_NYC_LOG l
where LAST_UPDATE_TIME > sysdate - 2960;

select to_char(RES_RPRT_STATUS_CHNG_DT_TIME,'rrrrMMddhhmm') chg_dt,to_char(SPECIMEN_RECEIVE_DATE,'rrrrMMddhhmm') spec_rcv from hlab_state_nyc_log;

delete HLAB_STATE_NYC_LOG;

select * from nyc_patients;


Insert into DL_ALL_PATIENTS (FACILITY_ID,SSN,LAST_NAME,FIRST_NAME,DOB,GENDER,RACE,ADDRESS,CITY,STATE,ZIP,PHONE,CELL_PHONE,WORK_PHONE,NPI_UPIN,ACCTNO,EID,CURRENT_STATUS,CHANGE_DATE,LAST_UPDATE_TIME,SOURCE)
values (null,null,'ASHTEST','ASHLEY',to_date('12-MAR-53','DD-MON-RR'),'F',null,null,null,null,null,null,null,null,null,null,'8000075630',null,to_timestamp('03-JAN-22 12.00.00.000000000 AM','DD-MON-RR HH.MI.SSXFF AM'),to_timestamp('25-JUL-23 09.02.25.882682000 PM','DD-MON-RR HH.MI.SSXFF AM'),'INITIATE');

UPDATE DL_ALL_PATIENTS
set STATE = 'NY',zip = '11218'
/

select * from RESULT_REPUSER.HLAB_ACTIVITY a
where requisition_id = '1ER4ZT7';
where last_update_time > sysdate -60;
/
select
                    *
                from
                    dl_all_patients;

delete HLAB_STATE_NYC_LOG
where order_number = '1ER4ZT7';

/

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
                a.ACCESSION_NO = r.ACCESSION_NO 
                and
                --a.receiving_facility2 LIKE '%E' AND 
--                a.receiving_facility2 NOT LIKE '8%' AND
--              (
--                (a.receiving_facility2 not like '%TEST%') or 
--                (a.receiving_facility2 not like '%Test%') or 
--                (a.receiving_facility2 not like '%TEST') or 
--                (a.receiving_facility2 not like '%Test') or 
--                (a.receiving_facility2 not like '%TES')
--              ) and              
                --r.REQUISITION_SSN <> '000000000' AND
                r.requisition_id = dp.requisition_id
                
                and
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
              
              a.LAST_UPDATE_TIME between '24-JUL-24 02.23.39.950700000 AM' and '28-SEP-24 02.23.39.950700000 AM'
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
              
          ) act
          
          ,
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
                            DL_ZIP_CODE
                         where
                            state_abbrev = 'NY'
                            and county in ('New York','Bronx','Kings','Queens','Richmond')            
              )            
          ) nycp	
        where
          --(act.patient_id = nycp.eid or act.REQUISITION_SSN = nycp.ssn);
          (act.patient_id = nycp.eid);