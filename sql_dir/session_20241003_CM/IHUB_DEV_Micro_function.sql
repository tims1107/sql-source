select case when MICRO_RESIST_CARBAPENEMS('Citrobacter freundii','0524KJS') = 'reportable'
  then 1 else 0 end reports, MICRO_RESIST_CARBAPENEMS('Citrobacter freundii','0524KJS') res from dual;
  
select result_test_name,abnormal_flag,micro_organism_name from ih_dw.results
where requisition_id = '0524KJS';
  
select result_test_name,abnormal_flag,MICRO_ORGANISM_NAME,r.* from ih_dw.results r
where requisition_id IN ('0524K9S')
and regexp_like(result_test_name,'isolate','i');

select * from asr_process_run
where source = 'IL'
and rownum < 2;

select
            distinct(abnormal_flag)
          
          from
            ih_dw.results
          where
            requisition_id = '0524KJS'
            and (regexp_like(result_test_name,'CEFTRIAXONE','i') and abnormal_flag = 'R');
            
select distinct(abnormal_flag)
from ih_dw.results
where
  requisition_id = '0524KJS'
  and
            ((  
                result_test_name = 'ERTAPENEM' and abnormal_flag = 'R')
                or (result_test_name = 'IMIPENEM' and abnormal_flag = 'R')
                or (result_test_name = 'MEROPENEM' and abnormal_flag = 'R'));
            and ((regexp_like(result_test_name,'CEFTRIAXONE','i') and abnormal_flag = 'R'));
            

/

create or replace FUNCTION                             MICRO_RESIST_CARBAPENEMS(p_org_name in varchar2, p_requisition_id in varchar2) RETURN VARCHAR2 AS
	v_org_name  VARCHAR2(4000) DEFAULT p_org_name;
	v_list_count number := 0;
	v_otc varchar2(2000);
	v_cond_val varchar2(2000);
  v_abnormal_flag varchar2(5) := null;
BEGIN

  if(p_requisition_id is not null) then
      begin
          select
            distinct(abnormal_flag)
          into 
            v_abnormal_flag
          from
            ih_dw.results
          where
            requisition_id = p_requisition_id
            and (
                (result_test_name = 'CEFOTAXIME' and abnormal_flag = 'R')
                or (result_test_name = 'CEFTRIAXONE' and abnormal_flag = 'R')
                or (result_test_name = 'CEFTAZIDIME' and abnormal_flag = 'R')            
            );
            
        select 
          distinct(abnormal_flag)
         into 
            v_abnormal_flag
        from ih_dw.results
        where
        requisition_id = p_requisition_id
        and
            ((  
                result_test_name = 'ERTAPENEM' and abnormal_flag = 'R')
                or (result_test_name = 'IMIPENEM' and abnormal_flag = 'R')
                or (result_test_name = 'MEROPENEM' and abnormal_flag = 'R'));
            
          EXCEPTION when 
            no_data_found then 
              v_abnormal_flag := null;             
      end;  
    
/*
      begin
          select
            distinct(abnormal_flag)
          into
            v_abnormal_flag
          from
            ih_dw.results
          where
            requisition_id = p_requisition_id
            and (
                (result_test_name = 'ERTAPENEM' and abnormal_flag = 'R')
                or (result_test_name = 'IMIPENEM' and abnormal_flag = 'R')
                or (result_test_name = 'MEROPENEM' and abnormal_flag = 'R')
            )
            and (
                (result_test_name = 'CEFOTAXIME' and abnormal_flag = 'R')
                or (result_test_name = 'CEFTRIAXONE' and abnormal_flag = 'R')
                or (result_test_name = 'CEFTAZIDIME' and abnormal_flag = 'R')            
            );
            
          EXCEPTION when 
            no_data_found then 
              v_abnormal_flag := null;             
      end;    
*/    
    
      if(v_abnormal_flag is not null) then
        return 'reportable';
      else
        return null;
      end if;  

  else
      return null;
  end if;  

  EXCEPTION when no_data_found then return null;
  
END MICRO_RESIST_CARBAPENEMS;

/


Insert into ASR_PROCESS_RUN (ORDER_NUMBER,ORDER_TEST_CODE,RESULT_TEST_CODE,PERFORMING_LAB_ID,TEXTUAL_RESULT_FULL,PATIENT_LAST_NAME,SOURCE,ACTIVITYDATE,COMPLETE) values ('9607S8K','301','301','SE','Positive','CANTEST','IL','29-NOV-23','N');
