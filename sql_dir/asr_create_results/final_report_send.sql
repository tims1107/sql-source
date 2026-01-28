declare pat_count number;
  pat_delete number := 0;
  pat_updated number;
  v_activitydate varchar2(9);
  pat_county varchar2(64);
  var_cnt number := 0;
  
  

begin
  
--  update result_comments formatting
  BEGIN

    update daily_results 
    set result_comments = 
    's/co ratio ' ||  chr(9) || 'Interpretation    Supplemental testing' || chr(10) ||
    '<0.80      ' ||  chr(9) || 'Nonreactive       No furthur testing required.' || chr(10) ||
    '0.80-0.99  ' ||  chr(9) || 'Equivocal         HCV RNA Quantitative Real-Time PCR is recommended.' || chr(10) ||
    '1.00->11.00' ||  chr(9) || 'Reactive          HCV RNA Quantitative Real-Time PCR is recommended' || chr(10) ||
    '           ' ||  chr(9) || '                  to distinguish active from resolved cases.'
    where RESULT_TEST_CODE = '310A'
    and result_comments like 's/co%'; 
    
    var_cnt := SQL%rowcount;
    
    DBMS_OUTPUT.PUT_LINE('310A Update Count : ' || var_cnt );
    
    commit;
    
    update daily_results
    set result_comments = 'The SARS-CoV-2 Ag assay uses chemiluminescence immunoassay (CLIA) technology for 
    the qualitative determination of SARS-CoV-2 nucleocapsid protein antigen in 
    appropriate nasopharyngeal swab (NPS) and nasal swab (NS) specimens from 
    individuals suspected to have COVID-19. 
    
    A Positive result indicates the presence of viral antigens, but clinical 
    correlation with the patient''s history and other diagnostic information is 
    necessary to determine the infection status. A Positive result does not rule 
    out bacterial infection or co-infection with other viruses. The agent detected 
    may not be the definite cause of disease. 
    
    A Negative result does not rule out infection by SARS-CoV-2. Negative results 
    should be treated as presumptive and confirmation with a molecular assay, if 
    necessary, for patient management may be performed.
    
    This product has been authorized by FDA under EUA for use by laboratories.'
    where result_test_code = '331';
    
    var_cnt := SQL%rowcount;
    
    DBMS_OUTPUT.PUT_LINE('331 Update Count : ' || var_cnt );
    
    commit;
    
    update daily_results 
    set result_comments = 'Verified by repeat analysis.
    s/co ratio    Interpretation    Supplemental testing
    <0.80         Nonreactive       No furthur testing required.
    0.80-0.99     Equivocal         HCV RNA Quantitative Real-Time PCR is recommended.
    1.00->11.00   Reactive          HCV RNA Quantitative Real-Time PCR is recommended 
                                    to distinguish active from resolved cases.'
    where RESULT_TEST_CODE = '310A'
    and result_comments like 'Verified by repeat%'
    ; 
    
    
    var_cnt := SQL%rowcount;
    
    DBMS_OUTPUT.PUT_LINE('310A Update Count : ' || var_cnt );
    
    commit;
    
    END;

    BEGIN
        -- remove previous pat_results
        delete from pat_results;
        pat_delete := SQL%ROWCOUNT;
        commit;
        dbms_output.put_line('Deleted count: ' || pat_delete);
    END;

    
  select to_char(max(last_update_time) -1,'dd-MON-yy') into v_activitydate from results_sent_log;
--  v_activitydate := '03-JUL-25'; 
  for results IN (select rs.* from asr_process_run pr
    join results_sent_log rs ON rs.order_number = pr.order_number
      and pr.result_test_code = rs.result_test_code
      where pr.activitydate = v_activitydate order by patient_account_state)
    loop
      dbms_output.put_line('Inserting Patient: ' || results.order_number || chr(9) || results.result_test_code || chr(9) || results.patient_account_state);
      pat_county := null;
      
      begin
      select county into pat_county from dl_zip_code where zip = results.patient_account_zip;
      
      exception
      when others then dbms_output.put_line(results.patient_account_state || chr(9) || results.patient_account_zip || chr(9) || sqlerrm);
      end;
      
      -- pat_results_insert
        insert into pat_results
        
          (REQUISITION_ID,
          EID,
          COUNTY,
          FACILITY_ID,
          CID,
          PATIENT_LAST_NAME,
          PATIENT_FIRST_NAME,
          PATIENT_MIDDLE_NAME,
          DATE_OF_BIRTH,
          GENDER,
          PATIENT_SSN,
          AGE,
          PATIENT_ACCOUNT_ADDRESS1,
          PATIENT_ACCOUNT_ADDRESS2,
          PATIENT_ACCOUNT_CITY,
          PATIENT_ACCOUNT_STATE,
          PATIENT_ACCOUNT_ZIP,
          PATIENT_HOME_PHONE,
          FACILITY_ADDRESS1,
          FACILITY_ADDRESS2,
          FACILITY_CITY,
          FACILITY_STATE,
          FACILITY_ZIP,
          FACILITY_PHONE,
          EAST_WEST_FLAG,
          INTERNAL_EXTERNAL_FLAG,
          FACILITY_ACCOUNT_STATUS,
          FACILITY_ACTIVE_FLAG,
          CLINICAL_MANAGER,
          MEDICAL_DIRECTOR,
          ACTI_FACILITY_ID,
          FMC_NUMBER,
          PATIENT_RACE,
          ETHNIC_GROUP,
          FACILITY_NAME,
          GENDER_IDENTITY,
          SEX_ORIENT )
          VALUES 
          (results.ORDER_NUMBER
          ,results.patient_id
      ,pat_county
      ,results.FACILITY_ID
      ,results.CID
      ,results.PATIENT_LAST_NAME
      ,results.PATIENT_FIRST_NAME
      ,results.PATIENT_MIDDLE_NAME
      ,results.DATE_OF_BIRTH
      ,results.GENDER
      ,results.PATIENT_SSN
      ,results.AGE
      ,results.PATIENT_ACCOUNT_ADDRESS1
      ,results.PATIENT_ACCOUNT_ADDRESS2
      ,results.PATIENT_ACCOUNT_CITY
      ,results.PATIENT_ACCOUNT_STATE
      ,results.PATIENT_ACCOUNT_ZIP
      ,results.PATIENT_HOME_PHONE
      ,results.FACILITY_ADDRESS1
      ,results.FACILITY_ADDRESS2
      ,results.FACILITY_CITY
      ,results.FACILITY_STATE
      ,results.FACILITY_ZIP
      ,results.FACILITY_PHONE
      ,results.EAST_WEST_FLAG
      ,results.INTERNAL_EXTERNAL_FLAG
      ,results.FACILITY_ACCOUNT_STATUS
      ,results.FACILITY_ACTIVE_FLAG
      ,results.CLINICAL_MANAGER
      ,results.MEDICAL_DIRECTOR
      ,results.ACTI_FACILITY_ID
      ,results.FMC_NUMBER
      ,results.PATIENT_RACE
      ,results.ETHNIC_GROUP
      ,results.FACILITY_NAME
      ,''
      ,''
      );
       
      commit;    
      
      if (results.patient_account_state is null) then
        dbms_output.put_line('Update patient state: ' || results.facility_state);
        update pat_results
        set patient_account_state = results.facility_state
        where requisition_id = results.order_number and eid = results.patient_id;
        
        commit;
          if (regexp_like(results.facility_state,'^(CA|OR|NJ|NY|LA|MD|NM|AL|TX|IL)$')) then
            delete DAILY_RESULTS
            where order_number = results.order_number;
            pat_delete := sql%rowcount;
            commit;
          end if;
          
                    
         
        
            
      else
        if (regexp_like(results.patient_account_state,'^(IL|CA|OR|NJ|NY|LA|MD|NM|AL|TX|NC)$')) then
            delete DAILY_RESULTS
            where order_number = results.order_number;
            pat_delete := sql%rowcount;
            commit;
        end if;
              
       
       
        
      end if;
      
      dbms_output.put_line('Deleted patient count: ' || pat_delete);
      
      
    end loop;
  


end;

/
select source_lab_system,device_id from daily_results;

select * from results_sent_log
where last_update_ti;

select 
results.ORDER_NUMBER
,results.PATIENT_TYPE
,results.LOINC_CODE
,results.LOINC_NAME
,results.ACCESSION_NUMBER
,results.EXTERNAL_MRN
,results.RELEASE_DATE_TIME
,results.ORDER_TEST_CODE
,results.ORDER_TEST_NAME
,results.RESULT_TEST_CODE
,results.RESULT_TEST_NAME
,results.COLLECTION_DATE_TIME
,results.COLLECTION_DATE
,results.COLLECTION_TIME
,results.RESULT_STATUS
--,results.SOURCE_LAB_SYSTEM
--,results.DEVICE_ID
,results.RESULT_COMMENTS
,results.VALUE_TYPE
,results.NUMERIC_RESULT
,results.TEXTUAL_RESULT_FULL
,results.TEXTUAL_RESULT
,results.REFERENCE_RANGE
,results.ABNORMAL_FLAG
,results.PERFORMING_LAB_ID
,results.ORDER_METHOD
,results.SPECIMEN_SOURCE
,results.ORDER_DETAIL_STATUS
,results.UNITS
,results.NPI
,results.ORDERING_PHYSICIAN_NAME
,results.LOGGING_SITE
,results.PATIENT_ID
,results.REQUISITION_STATUS
from results_sent_log results;


/

-- pat_results_insert
insert into pat_results

with asr (order_number,activitydate ,result_test_code,complete,source)
  as (select order_number,activitydate ,result_test_code,complete,source
      from asr_process_run),
pat as (select  v.* from vw_pat_results v
union all 
select  v.* from VW_STAFF_RESULTS v )

select 
REQUISITION_ID,
EID,
COUNTY,
FACILITY_ID,
CID,
PATIENT_LAST_NAME,
PATIENT_FIRST_NAME,
PATIENT_MIDDLE_NAME,
DATE_OF_BIRTH,
GENDER,
PATIENT_SSN,
AGE,
PATIENT_ACCOUNT_ADDRESS1,
PATIENT_ACCOUNT_ADDRESS2,
PATIENT_ACCOUNT_CITY,
PATIENT_ACCOUNT_STATE,
PATIENT_ACCOUNT_ZIP,
PATIENT_HOME_PHONE,
FACILITY_ADDRESS1,
FACILITY_ADDRESS2,
FACILITY_CITY,
FACILITY_STATE,
FACILITY_ZIP,
FACILITY_PHONE,
EAST_WEST_FLAG,
INTERNAL_EXTERNAL_FLAG,
FACILITY_ACCOUNT_STATUS,
FACILITY_ACTIVE_FLAG,
CLINICAL_MANAGER,
MEDICAL_DIRECTOR,
ACTI_FACILITY_ID,
FMC_NUMBER,
PATIENT_RACE,
ETHNIC_GROUP,
FACILITY_NAME,
GENDER_IDENTITY,
SEX_ORIENT
from asr 
join pat ON pat.requisition_id = asr.order_number
--left join vw_staff_results sr ON sr.requisition_id = asr.order_number

where complete IN ('R','S') and activitydate = to_char(sysdate - 1 ,'dd-MON-yy')
and pat.result_test_code = asr.result_test_code;

commit;

select * from pat_results
where PATIENT_ACCOUNT_STATE is null;

delete pat_results
where PATIENT_LAST_NAME like 'VM%';

delete pat_results;

select facility_state from pat_results
where PATIENT_ACCOUNT_STATE is null;

/

begin

  for rec IN (select * from pat_results)
  
  loop
  
    if (rec.patient_account_state is null) then
      dbms_output.put_line(rec.facility_state);
      update pat_results
      set patient_account_state = rec.facility_state
      where requisition_id = rec.requisition_id;
    end if;
  
  end loop;

end;

/



select * from daily_results
where order_number in
(select r.order_number from daily_results d
full outer join results_sent_log l  ON l.order_number = d.order_number
full outer join asr_process_run r ON r.order_number = l.order_number
where l.result_test_code = r.result_test_code
and d.result_test_code = l.result_test_code)
order by order_number;

/

select p.staff_pk,race,ethnicity,GENDER_IDENTITY,SEX_ORIENT from ih_dw.dim_STAff p
where staff_pk IN (113103);
