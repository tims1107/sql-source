select * from pat_results;

create table daily_results_pa_20250719
as
select * from daily_results; 

/
declare p_out number := 0;

begin

    SP_ASR_PROC_TRACK_RESULTS_C('PA',p_out);
    
    dbms_output.put_line('Count: ' || p_out);
end;

/

select * from results_sent_log
where order_number IN ('5234MS8','5067CX8','5067FA8','5234G88','5355ZU8','5067CW8');

delete results_sent_log
where order_number IN ('5234MS8','5067CX8','5067FA8','5234G88','5355ZU8','5067CW8');

select * from asr_process_run
where order_number IN ('5234MS8','5067CX8','5067FA8','5234G88','5355ZU8','5067CW8');

update asr_process_run
set complete = 'R'
where order_number IN ('5234MS8','5067CX8','5067FA8','5234G88','5355ZU8','5067CW8');

select * from condition_master_test
where state_fk IN(
select state_master_pk from state_master
where state_abbreviation = 'PA')
and order_test_code = '311';

update condition_master_test
set result_test_code = '311R'
where condition_master_pk = 916;

select order_number,result_test_code,textual_result_full from gtt_results_extract
where order_test_code in ('310','311','301');
and textual_result_full = '>11.00'
or textual_result_full = 'Reactive';

select * from clinic_printers;

select patient_last_name,
    patient_first_name,
    eid from pat_results
group by patient_last_name,
    patient_first_name,
    eid
having count(1)> 1;

select * from
(SELECT 
    patient_last_name,
    patient_first_name,
    eid,
    ROW_NUMBER() OVER (
        PARTITION BY patient_last_name, patient_first_name, eid
        ORDER BY patient_last_name, patient_first_name, eid
    ) as row_num
   
FROM pat_results)
where row_num = 1;

select * from patientmaster
where eid = '8005058429S';

DELETE FROM pat_results 
WHERE ROWID IN (
    SELECT ROWID 
    FROM (
        SELECT 
            ROWID,
            ROW_NUMBER() OVER (
                PARTITION BY patient_last_name, patient_first_name, eid
                ORDER BY patient_last_name, patient_first_name
            ) as row_num
        FROM pat_results
    ) 
    WHERE row_num > 1
);