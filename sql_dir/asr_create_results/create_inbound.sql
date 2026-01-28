create table ASR_INBOUND_EXTRACT
(trackid number
,ordernumber varchar2(10)
,ordertestcode varchar2(8)
,resulttestcode varchar2(8)
,stateabbrev varchar2(2)
,eid varchar2(16)
,lastupdatetime timestamp(6)
,batchseq varchar2(64)
,statuscode number);

create table ASR_INBOUND_STATUS
(statusid number,
statuscode varchar2(32));

insert into ASR_INBOUND_STATUS
values (9,'DUPLICATE');


select EXTRACT_TRACKING$SEQ.nextval from dual;

/
begin
reset_sequence('EXTRACT_TRACKING$SEQ','asr_inbound_extract','trackid');
end;
/
select * from asr_inbound_extract
where (ordernumber,ordertestcode,resulttestcode) 
IN
(select order_number,order_test_code,result_test_code from asr_process_run
where activitydate = '20-JAN-25')
--and activity < '19-JAN-25 01.10.04.783246000 AM'

and regexp_like(stateabbrev ,'^(AL|CA|LA|MD|NC|NJ|NM|NY|OR|TX)$')
order by trackid;

/

select r.order_number,e.*,decode(e.statuscode,1,'New','Processed') statusname from asr_inbound_extract e
left outer join asr_process_run r ON r.order_number = e.ordernumber and r.result_test_code = e.resulttestcode
--where regexp_like(stateabbrev ,'^(AL|CA|LA|MD|NC|NJ|NM|NY|OR|TX)$')
where r.activitydate = '18-JAN-25'
--and not regexp_like(e.ordertestcode,'111');
--and order_number is null
order by stateabbrev;

select * from asr_process_run
where activitydate = '18-JAN-25'
and order_number IN
(select ordernumber from asr_inbound_extract e
where statuscode IN (1))
and complete IN ('Q');

select sum(cnt) from
(select statuscode,count(1) cnt from asr_inbound_extract e
group by statuscode);

select e.statuscode,e.STATEABBREV , count(1) from asr_inbound_extract e
where statuscode IN (2)
group by statuscode,stateabbrev
order by stateabbrev;

select * from asr_inbound_extract e
where statuscode IN (2)
order by stateabbrev;

select * from asr_process_run
where order_number = '1853WP4';

select sum(cnt) from
(select e.statuscode,e.STATEABBREV , count(1) cnt from asr_inbound_extract e
where statuscode NOT IN (2)
group by statuscode,stateabbrev);
order by stateabbrev;

select * from asr_inbound_extract e
where batchseq = 'LOAD_20250121'
and statuscode = 2
order by stateabbrev;

select e.statuscode,e.STATEABBREV , e.batchseq,count(1) cnt from asr_inbound_extract e
where statuscode  IN (5)
and stateabbrev = 'IL'
--and e.batchseq = 'LOAD_20250120'
group by statuscode,stateabbrev,batchseq
order by stateabbrev;

select * from asr_process_run
where source = 'IL'
and activitydate = trunc(sysdate - 1);

delete asr_inbound_extract
where statuscode = 1;


select e.source , e.complete, count(1) from asr_process_run e
--where complete IN
where activitydate = '23-JAN-25'
group by source,complete
order by source;

select e.stateabbrev , statuscode,count(1) from asr_inbound_extract e
where batchseq = 'LOAD_20250123'
and trunc(e.LASTUPDATETIME) = trunc(sysdate -1)
group by stateabbrev
order by e.STATEABBREV;
/

-- check statuscode
select * from asr_inbound_extract e
join ASR_INBOUND_STATUS s ON s.statusid = e.statuscode
where batchseq = 'LOAD_20250123'
and e.statuscode  IN (2)
--and stateabbrev = 'XX'
order by lastupdatetime desc;

select count(1) from asr_process_run
where complete = 'R'
and source = 'NJ'
and activitydate = trunc(sysdate - 1);




select e.ordernumber,e.stateabbrev,resulttestcode,performing_lab,r.TEXTUAL_RESULT_FULL,batchseq,e.LASTUPDATETIME,e.statuscode from asr_inbound_extract e
join ih_dw.results r ON r.requisition_id = e.ordernumber and r.result_test_code = e.resulttestcode
join ASR_INBOUND_STATUS s ON s.statusid = e.statuscode
where batchseq = 'LOAD_20250123'
and e.statuscode  IN (2)
and stateabbrev IN ('AL','WV')
--group by e.stateabbrev,e.resulttestcode,performing_lab
order by e.batchseq,e.STATEABBREV,resulttestcode,performing_lab;

delete asr_inbound_extract e
where batchseq = 'LOAD_20250122'
and statuscode = 1;

select r.ACTIVITYDATE,e.LASTUPDATETIME,complete,statuscode,batchseq from asr_process_run r
join asr_inbound_extract e ON e.ordernumber = r.order_number
where lastupdatetime = trunc(sysdate -1);
where order_number = '1595U74';


select * from asr_process_run
where result_test_code = '111'
and activitydate = trunc(sysdate-1)
and complete = 'N'
and (order_number,result_test_code) NOT IN
(select ordernumber,resulttestcode from asr_inbound_extract)
;

select a.requisition_id,a.last_updated_date,lo.INITIATE_ID from ih_dw.dw_ods_activity a
join ih_dw.dim_lab_order lo ON lo.requisition_id = a.requisition_id
where a.requisition_id IN ('1806XG4');


Insert into ASR_INBOUND_EXTRACT (TRACKID,ORDERNUMBER,ORDERTESTCODE,RESULTTESTCODE,STATEABBREV,EID,LASTUPDATETIME,BATCHSEQ,STATUSCODE) 
values (EXTRACT_TRACKING$SEQ.nextval,'1806XG4','111','111','NY','8004267935',to_timestamp('23-JAN-25 05.25.03.833086000 PM','DD-MON-RR HH.MI.SS.FF AM'),'LOAD_20250111',3);


select * from asr_inbound_extract e
join asr_inbound_status s ON s.statusid = e.statuscode
where batchseq = 'LOAD_20250124'
and resulttestcode = '111';

select * from asr_process_run
where complete = 'N'
and result_test_code = '111'
and (order_number,result_test_code) IN
(select ordernumber,resulttestcode from asr_inbound_extract e
join asr_inbound_status s ON s.statusid = e.statuscode
--where batchseq = 'LOAD_20250124'
where resulttestcode = '111');

--update asr_inbound_extract
--set statuscode = 9
--order_number IN ('7951VG7'
--,'7637PZ7');
--and statuscode = 1;

select * from asr_inbound_extract
where ordernumber IN ('7954G27'
,'7637PZ7')
;

select * from patientmaster
where eid = '8001542650';

select * from asr_process_run
where complete = 'N'
and result_test_code = '111';
select * from asr_process_run
where order_number IN ('7951VG7'
,'7637PZ7');

select e.ordernumber,e.stateabbrev,resulttestcode,performing_lab,r.TEXTUAL_RESULT_FULL,batchseq,e.LASTUPDATETIME,e.statuscode from asr_inbound_extract e
join ih_dw.results r ON r.requisition_id = e.ordernumber and r.result_test_code = e.resulttestcode
join ASR_INBOUND_STATUS s ON s.statusid = e.statuscode
where batchseq = 'LOAD_20250123'
and e.statuscode  IN (2)
and stateabbrev IN ('AL','WV','AZ','CA','CT','DE','FL','GA','IL','IN','LA','MD')
--group by e.stateabbrev,e.resulttestcode,performing_lab
order by e.batchseq,e.STATEABBREV,resulttestcode,performing_lab;

select e.ordernumber,e.stateabbrev,resulttestcode,performing_lab,r.TEXTUAL_RESULT_FULL,batchseq,e.LASTUPDATETIME,e.statuscode from asr_inbound_extract e
join ih_dw.results r ON r.requisition_id = e.ordernumber and r.result_test_code = e.resulttestcode
join ASR_INBOUND_STATUS s ON s.statusid = e.statuscode
--where batchseq = 'LOAD_20250124'
where e.statuscode  IN (2)
--and ordernumber = '7274A37'
--and stateabbrev IN ('AL','WV','AZ','CA')
--group by e.stateabbrev,e.resulttestcode,performing_lab
order by e.STATEABBREV,resulttestcode,performing_lab,e.batchseq;

select * from asr_process_run
where order_number = '7694JT7';

select * from results_sent_log
where order_number = '7694JT7';

select to_timestamp(trunc(sysdate -1),'DD-MON-RR HH.MI.SS.FF AM') from dual;

select 'LOAD_' || to_char(sysdate -1,'yyyyMMdd')from dual;
/

select count(1) from asr_process_run
where activitydate = trunc(sysdate - 1);

select * from asr_inbound_extract
where BATCHSEQ = 'LOAD_20250201';

select * from asr_process_run
where order_number IN ('8278CU7','82848A7','8285H47','8282PV7','82763S7','8284JF7','8217AJ7','8267CJ7','8282C57')
and complete = 'N';

select pr.order_number,e.ordernumber from asr_process_run pr
join asr_inbound_extract e ON e.ordernumber = pr.order_number and e.resulttestcode = pr.result_test_code
where activitydate = trunc(sysdate -1)
and statuscode = 2
order by e.ordernumber desc;

select * from asr_process_run
where result_test_code = '311R'
and to_date(activitydate,'dd-MON-yy') > sysdate - 30
and source = 'NC';

update asr_process_run
set complete = 'Z'
where order_number in ('7674S97'
,'7956BJ7'
,'76723Z7'
,'8588KK7')
and result_test_code = '311R';

select * from asr_process_run
where complete = 'Z';


select * from results_sent_log;

select * from asr_process_run
where complete = 'N'
and activitydate = trunc(sysdate -1);

update asr_process_run
set complete = 'R'
where order_number = '9111M77';




select * from patientmaster
where eid in 
(
select initiate_id from ih_dw.dim_lab_order
where REQUISITION_ID IN ('0594G8S'
,'0594G9S'));

select * from asr_process_run
where order_number IN ('0594G8S'
,'0594G9S');

update asr_process_run
set complete = 'Q'
where order_number = '2008Z44'
and complete = 'N';

where patient_last_name = 'COV-03-2025'
and complete = 'N';

select * from asr_process_run
where order_number = '1941M2W';

update asr_process_run
set complete = 'Q'
where source = 'NY'
and complete = 'T';

select order_number from results_sent_log
where order_number IN
(select ordernumber from asr_inbound_extract
where stateabbrev = 'XX'
and LASTUPDATETIME > sysdate - 2);

delete results_sent_log
where patient_account_state = 'NC'
--and result_source = 'North Carolina NCHL7GeneratorContext'
and last_update_time > sysdate -.2;


select * from asr_inbound_extract
where statuscode = 2
and batchseq = 'LOAD_20250306';

select * from asr_inbound_extract
where stateabbrev = 'NY'
and statuscode = 2;

where ordernumber IN ('8545XS7');

select * from asr_process_run
where order_number IN ('9599HB7'
,'');

select source,complete,activitydate,count(1) from asr_process_run
--where activitydate = '06-MAR-25'
where complete = 'N'
group by source,complete,activitydate
order by source; 
;

select * from condition_master
where state_fk IN
(select state_master_pk from state_master
where state_abbreviation = 'NC')
and regexp_like(order_test_code,'^(315|317|322|323|327)$');

update condition_master
set status = 'inactive'
where condition_master_pk IN (1874,1875,1877,1898);

update asr_process_run
set complete = 'T'
where complete = 'N'
and source = 'MN'
and order_number = '1880WK8';
and activitydate = '23-APR-25';

select * from condition_master
where state_fk IN
(select state_master_pk from state_master
where state_abbreviation = 'NC')
and order_test_code = '318';

delete condition_master
where condition_master_pk IN (1911,1912);

REM INSERTING into CONDITION_MASTER
SET DEFINE OFF;
Insert into CONDITION_MASTER (CONDITION_MASTER_PK,STATE_FK,CONDITION_FILTER_FK,ORDER_TEST_CODE,RESULT_TEST_CODE,CONDITION,VALUE_TYPE,CONDITION_VALUE,STATUS,CREATED_DATE,CREATED_BY,LAST_UPDATED_DATE,LAST_UPDATED_BY) 
values ((select max(condition_master_pk) + 1 from condition_master),49,2,'336','336','Positive Equivocal Reactive','ST',null,'active',to_timestamp('01-NOV-21 08.51.22.710462000 AM','DD-MON-RR HH.MI.SSXFF AM'),'ASR_ADMIN_UPDATE',to_timestamp('01-NOV-21 08.51.22.710462000 AM','DD-MON-RR HH.MI.SSXFF AM'),'ASR_ADMIN_UPDATE');


select * from asr_process_run
where order_number IN
(select e.ordernumber from asr_inbound_extract e
join results_sent_log l ON l.order_number = e.ordernumber and l.result_test_code = e.resulttestcode)
and activitydate = '26-APR-25'
and source = 'MN';

select * from ASR_process_run
where activitydate = '26-APR-25'
and source = 'MN';

select * from patientmaster
where eid IN
(select initiate_id from ih_dw.dim_lab_order
where requisition_id = '1880WK8');

select * from pat_results
where eid = '8003216358';

where statuscode in (6,7)
and batchseq = 'LOAD_20250306';

select * from asr_process_run
where activitydate = '12-MAR-25';

select order_number,ORDER_TEST_CODE,RESULT_TEST_CODE,PERFORMING_LAB_ID,TEXTUAL_RESULT_FULL,
       PATIENT_LAST_NAME,source,ACTIVITYDATE,'N' complete from report_results rr
       where regexp_like(activitydate,'MAR');

/

begin
  
  for rec IN (select * from asr_inbound_extract
where statuscode = 2
and batchseq = 'LOAD_20250306')
loop

  
end loop;

end;
/

select * from asr_process_run
where order_number = '2201FF4';

select e.* from asr_inbound_extract e
join ih_dw.results r ON r.requisition_id = e.ordernumber and r.result_test_code = e.resulttestcode
join ASR_INBOUND_STATUS s ON s.statusid = e.statuscode
order by e.lastupdatetime desc;

select e.* from asr_inbound_extract e
join ih_dw.results r ON r.requisition_id = e.ordernumber and r.result_test_code = e.resulttestcode
join ASR_INBOUND_STATUS s ON s.statusid = e.statuscode
where batchseq = 'LOAD_20250419'
--and stateabbrev = 'XX'
and e.statuscode   not IN (2);

delete asr_inbound_extract
where batchseq = 'LOAD_20250420';

select * from asr_inbound_status;

insert into asr_inbound_status values (10,'TESTING');

select e.* from asr_inbound_extract e
join ih_dw.results r ON r.requisition_id = e.ordernumber and r.result_test_code = e.resulttestcode
join ASR_INBOUND_STATUS s ON s.statusid = e.statuscode
--where batchseq = 'LOAD_20250417'
where e.statuscode  IN (1)
and stateabbrev = 'GA';
group by e.stateabbrev,e.resulttestcode,performing_lab
order by e.STATEABBREV;

select * from asr_process_run
where activitydate = '14-MAY-25'
and source = 'NY';
and order_test_code IN ('310','318');

select * from ih_dw.dim_lab_order
where requisition_id = '2651J58';

select * from state_master
where state_abbreviation = 'AA';

select * from patientmaster
where eid = '8005011643';

update patientmaster
set state = 'AZ'
where eid = '8005011643';

select * from dl_zip_code
where zip = '85392';

update asr_process_run
--set complete = 'Q'
set source = 'AZ'
where order_number = '2651J58';

update asr_inbound_extract
--set complete = 'Q'
set stateabbrev = 'AZ'
where ordernumber = '2651J58';

select e.stateabbrev,resulttestcode,performing_lab,batchseq,count(1) from asr_inbound_extract e
join ih_dw.results r ON r.requisition_id = e.ordernumber and r.result_test_code = e.resulttestcode
join ASR_INBOUND_STATUS s ON s.statusid = e.statuscode
--where batchseq = 'LOAD_20250512'
where e.statuscode  IN (2)
--and stateabbrev = 'NC'
group by e.stateabbrev,e.resulttestcode,performing_lab,batchseq
order by e.STATEABBREV;
/
declare 
  cntloop number := 7;
  v_activitydate varchar2(9);
  
begin
  
  for i IN 0 .. cntloop - 1  loop
    v_activitydate := trunc(sysdate - (cntloop -1 - i));
    dbms_output.put_line(i || chr(9) || v_activitydate);
  
  
  for rec IN (select * from asr_process_run
    where activitydate = v_activitydate)
  loop
  
    dbms_output.put_line(rec.activitydate || chr(9) || rec.order_number || chr(9) || rec.complete); 
  
    if(rec.complete = 'N') then
      update asr_inbound_extract 
      -- VALIDATED
      set statuscode = 2
      where ordernumber = rec.order_number and resulttestcode = rec.result_test_code;
    end if;
    
    if(rec.complete = 'T') then
      update asr_inbound_extract 
      -- TESTING ASR_INBOUND_STATUS TABLE
      set statuscode = 10
      where ordernumber = rec.order_number and resulttestcode = rec.result_test_code;
    end if;
    
    if(rec.complete = 'D') then
      update asr_inbound_extract 
      -- NY 111
      set statuscode = 3 
      where ordernumber = rec.order_number and resulttestcode = rec.result_test_code;
    end if;
    
    if(rec.complete = 'Q') then
      update asr_inbound_extract 
      -- NY ALT NOT QUALIFIED
      set statuscode = 4 
      where ordernumber = rec.order_number and resulttestcode = rec.result_test_code;
    end if;
    
    if(rec.complete = 'A') then
      update asr_inbound_extract 
      -- COVID PROMPT
      set statuscode = 5 
      where ordernumber = rec.order_number and resulttestcode = rec.result_test_code;
    end if;
    
    if(rec.complete = 'R') then
      update asr_inbound_extract 
      -- POSTED GENERAL
      set statuscode = 6 
      where ordernumber = rec.order_number and resulttestcode = rec.result_test_code;
    end if;
    
    if(rec.complete = 'S') then
      update asr_inbound_extract 
      -- POSTED COVID
      set statuscode = 7 
      where ordernumber = rec.order_number and resulttestcode = rec.result_test_code;
    end if;
    
    if(rec.complete = 'D') then
      update asr_inbound_extract 
      -- POSTED COVID
      set statuscode = 8 
      where ordernumber = rec.order_number and resulttestcode = rec.result_test_code;
    end if;
    commit;
    
    
  end loop;
  
  end loop;
  
end;

/

(select * from asr_inbound_extract
where (ordernumber,ordertestcode,resulttestcode) 
IN
(select order_number,order_test_code,result_test_code from asr_process_run)
and LASTUPDATETIME < '19-JAN-25 01.10.04.783246000 AM'

--and regexp_like(stateabbrev ,'^(AL|CA|LA|MD|NC|NJ|NM|NY|OR|TX)$')
order by trackid;

