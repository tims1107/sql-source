set SERVEROUTPUT ON;

select * from asr_process_run
where complete = 'N'
and activitydate = '22-FEB-24';

-- 315 >5
-- 317L >25
-- 323 > 135
-- 322 > 9

update asr_process_run
set complete = 'Q'
where complete = 'N'
and activitydate = '22-FEB-24'
and result_test_code IN 
(
  '317L','322','315'
);

/

-- Update result comments 

declare var_cnt number;
--activitydate varchar2(10) := '24-FEB-22';

BEGIN

update daily_results 
set result_comments = 's/co ratio    Interpretation    Supplemental testing
<0.80         Nonreactive       No furthur testing required.
0.80-0.99     Equivocal         HCV RNA Quantitative Real-Time PCR is recommended.
1.00->11.00   Reactive          HCV RNA Quantitative Real-Time PCR is recommended 
                                to distinguish active from resolved cases.'
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



/

-- find nulls ---
--create table rm_results
--as
select order_number,ORDER_TEST_CODE,RESULT_TEST_CODE,TEXTUAL_RESULT,(select distinct pat_results.FACILITY_STATE from pat_results where requisition_id = dr.order_number) facility_state,
(select distinct patient_last_name from pat_results where requisition_id = dr.order_number) last_name from daily_results dr
where order_number in 
(select requisition_id from pat_results
where PATIENT_ACCOUNT_STATE is null)
order by order_number;

select * from pat_results
where REQUISITION_ID = '1984FY7';

update pat_results
set PATIENT_ACCOUNT_STATE =
(select facility_state from pat_results
where REQUISITION_ID ='1984FY7')
,PATIENT_ACCOUNT_ADDRESS1 =
(select facility_address1 from pat_results
where REQUISITION_ID ='1984FY7')
,PATIENT_ACCOUNT_CITY =
(select facility_city from pat_results
where REQUISITION_ID ='1984FY7')
,PATIENT_ACCOUNT_ZIP =
(select facility_zip from pat_results
where REQUISITION_ID ='1984FY7')
where REQUISITION_ID = '1984FY7';

/

delete 

update asr_process_run
set complete = 'Q'
where order_number = '05376C7';

delete STATERPT_OWNER.DAILY_RESULTS
where order_number = '2161CA7';

/

-- delete null accounts
-- remove ELR states and exceptions
DECLARE var_cnt number;

begin
delete STATERPT_OWNER.DAILY_RESULTS
where order_number in
(select requisition_id from pat_results
where PATIENT_ACCOUNT_STATE in ('CA','OR','NJ','NY','LA','MD','NM','AL','TX'))


or RESULT_TEST_CODE like 'P%'
or (order_number IN (select REQUISITION_ID from pat_results where patient_account_state like 'PA') and result_test_code like '332' and regexp_like(textual_result,'negative','i'))
;



var_cnt := SQL%rowcount;

DBMS_OUTPUT.PUT_LINE('Deleted : ' || var_cnt );



commit;

end;

/

begin

for rec IN (select * from daily_results dr
join pat_results pr ON pr.requisition_id = dr.order_number)
loop


--dbms_output.put_line(rec.patient_account_state || chr(9) || rec.order_number || chr(9) || rec.result_test_code);
if(length(rec.patient_account_state) = 0) then
  dbms_output.put_line('Missing - ' || rec.patient_account_state || chr(9) || rec.order_number);
end if;

if(regexp_like(rec.patient_account_state,'CA|OR|NJ|NY|LA|MD|NM|AL|TX','i')) then
  delete daily_results
  where order_number = rec.order_number;
  
  dbms_output.put_line('Delete ' || rec.order_number || ' for state source ' || rec.patient_account_state);
  commit;
end if;

if(rec.result_test_code = '310A' and
   regexp_like(rec.result_comments,'^s/co.+interpretation','i')) then
  
  update daily_results 
    set result_comments = 's/co ratio    Interpretation    Supplemental testing
<0.80         Nonreactive       No furthur testing required.
0.80-0.99     Equivocal         HCV RNA Quantitative Real-Time PCR is recommended.
1.00->11.00   Reactive          HCV RNA Quantitative Real-Time PCR is recommended 
                                to distinguish active from resolved cases.'
  
  where order_number = rec.order_number
  and result_test_code = '310A';
  
  dbms_output.put_line('Update comment ' || rec.order_number || ' for state source ' || regexp_substr(rec.result_comments,'s/co ratio',1,1) ||
    ' ' || regexp_substr(rec.result_comments,'\w+',1,4) || rec.result_test_code);

  commit;

end if;


end loop;



end;

/



create table save_comment
as
select result_comments from daily_results
where RESULT_TEST_CODE = '310A'
and order_number = '0320AW7';

update daily_results
--set result_comments = regexp_replace(result_comments,'\s{2,}',chr(9))
set result_comments =  's/co ratio    Interpretation    Supplemental testing
<0.80         Nonreactive       No furthur testing required.
0.80-0.99     Equivocal         HCV RNA Quantitative Real-Time PCR is recommended.
1.00->11.00   Reactive          HCV RNA Quantitative Real-Time PCR is recommended 
                                to distinguish active from resolved cases.'
where RESULT_TEST_CODE = '310A'
and order_number = '0320AW7';

select * from save_comment;
