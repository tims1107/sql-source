


create database LINK RR_DWPRD
CONNECT TO wh_track IDENTIFIED BY "wh6track"
USING '(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=njrr-scan.spectraeastnj.com)(PORT=1521))(CONNECT_DATA=(SERVICE_NAME=dwprd)))';

--------------------------------------------------------
--  DDL for DB Link ASR_IHUBPRD
--------------------------------------------------------

  CREATE DATABASE LINK "ASR_IHUBPRD"
   CONNECT TO "STATERPT_USER" IDENTIFIED BY VALUES ':1'
   USING '(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=korusdb1-scan.spectraeastnj.com)(PORT=1521))(CONNECT_DATA=(SERVICE_NAME=ihubprd)))';
   
   /
   
   select * from STATERPT_OWNER.MICRO_ORGANISM_GROUP
   where GROUPNAME = 'DRUG';
   
   select * from STATERPT_OWNER.MICRO_ORGANISM_FILTER
   where valuetype = 'DRUG';
   
   select lo.INITIATE_ID,r.* from ih_dw.results r
   join ih_dw.dim_lab_order lo ON lo.requisition_id = r.requisition_id
      where r.requisition_id = '7231Y76'
   and (regexp_like(result_test_name,'isolate','i')
   or result_test_name IN
   (select organismname from micro_organism_filter))
   order by result_sequence;
   
   /
   
   create index nuidx_results_requisition ON micro_results_extract (requisition_id);
   create index nuidx_pat_eip_requisition ON eip_pat_results (requisition_id);
   
   
   select * from eip_pat_results;
   
   select e.REQUISITION_ID,micro_organism_name,order_test_code,order_test_name,result_test_code,result_test_name,e.LAST_UPDATED_DATE from MICRO_RESULTS_EXTRACT e
		left outer join eip_pat_results pat ON pat.requisition_id = e.requisition_id
    join 
		(select REQUISITION_ID from ih_dw.DW_ODS_ACTIVITY) act ON act.requisition_id = e.requisition_id;
--		where 
--		                requisition_id is not null
--		                and EXTRACT(MONTH FROM LAST_UPDATED_DATE) = 9 
--		                and EXTRACT(YEAR FROM LAST_UPDATED_DATE) = 2024) act ON act.requisition_id = e.requisition_id;
                    
    
    select mnth,count(1) from 
    (select extract(month from LAST_UPDATED_DATE ) mnth from micro_results_extract) t1
    group by mnth;
    
		where pat.patient_account_state IN ('MN'
		,'CA'
		,'NM'
		,'TN'
		,'MD'
		,'GA'
		,'CO'
		,'NY'
		,'CT'
		,'OR')
		and regexp_like(e.result_test_name,'isolate','i')
		and e.REQUISITION_ID IN 
		(select e.REQUISITION_ID from ih_dw.DW_ODS_ACTIVITY
		where 
		                requisition_id is not null
		                and EXTRACT(MONTH FROM LAST_UPDATED_DATE) = 9 
		                and EXTRACT(YEAR FROM LAST_UPDATED_DATE) = 2024)
   
   select REQUISITION_ID from ih_dw.DW_ODS_ACTIVITY
where 
                requisition_id is not null
                and EXTRACT(MONTH FROM LAST_UPDATED_DATE) = 9 
                and EXTRACT(YEAR FROM LAST_UPDATED_DATE) = 2024;
