-- test new 310 rule
DECLARE
    v_cursor SYS_REFCURSOR;
    v_record STATERPT_OWNER.GTT_RESULTS_EXTRACT%ROWTYPE;
    v_count NUMBER := 0;
    v_total_count NUMBER := 0;
    v_total_matched NUMBER := 0;
    v_total_unmatched NUMBER := 0;
    v_max_records NUMBER := 200;
    v_process_date DATE := TRUNC(SYSDATE - 1);
    v_process number := 0;
    
    -- Dynamic state array populated from state_master table
    TYPE state_array_type IS TABLE OF VARCHAR2(2);
    v_states state_array_type;
    
    -- Validation summary variables
    v_state_results_count NUMBER;
    v_failed_results_count NUMBER;
    v_sent_results_count NUMBER;
    
    
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== COMPREHENSIVE VALIDATION FOR ALL STATES ===');
    DBMS_OUTPUT.PUT_LINE('Process Date: ' || TO_CHAR(v_process_date, 'DD-MON-YYYY'));
    DBMS_OUTPUT.PUT_LINE('');
    
    -- Populate states array using condition_processor package function
    DECLARE
        v_states_cursor SYS_REFCURSOR;
        v_state_abbrev VARCHAR2(2);
        v_state_name VARCHAR2(100);
        v_single_state VARCHAR2(2) := 'IL';
        
    BEGIN
        v_states_cursor := condition_processor.get_active_states();
        
        -- Initialize collection
        v_states := state_array_type();
        
        LOOP
            FETCH v_states_cursor INTO v_state_abbrev, v_state_name;
            EXIT WHEN v_states_cursor%NOTFOUND;
            IF (v_state_abbrev = v_single_state) THEN
                v_states.EXTEND;
                v_states(1) := v_single_state;
            END IF;
            
        END LOOP;
        
        CLOSE v_states_cursor;
    END;
    
    DBMS_OUTPUT.PUT_LINE('Found ' || v_states.COUNT || ' active states to validate');
    DBMS_OUTPUT.PUT_LINE('');
    
    -- Loop through all states
    FOR i IN 1..1 LOOP
        v_count := 0;
        v_state_results_count := 0;
        v_failed_results_count := 0;
        v_sent_results_count := 0;
        
        BEGIN
            -- Validate results for current state with 'F' (Final) status filter
--            v_cursor := condition_processor.validate_results(
--                p_state_abbrev => v_states(i),
--                p_process_date => v_process_date,
--                p_result_status_filter => 'F'
--            );
            
            -- Get filtered cursor directly
        v_cursor := condition_processor.validate_results(
            p_state_abbrev => v_states(i),
            p_process_date => v_process_date,
            p_max_records => v_max_records,
            p_result_status_filter => 'F'
        );
            
            DBMS_OUTPUT.PUT_LINE('--- STATE: ' || v_states(i) || ' (Final Results) ---');
            
            LOOP
                FETCH v_cursor INTO v_record;
                EXIT WHEN v_cursor%NOTFOUND;
                

                
                --dbms_output.put_line('Not skipped..... ' || to_char(v_process));
                v_count := v_count + 1;
                
                -- Check if this result exists in results_sent_log
                DECLARE
                    v_exists_in_sent_log NUMBER;
                BEGIN
                    SELECT COUNT(*)
                    INTO v_exists_in_sent_log
                    FROM results_sent_log
                    WHERE order_number = v_record.order_number
                    AND result_test_code = v_record.result_test_code;
                    
                    IF v_exists_in_sent_log > 0 THEN
                        v_sent_results_count := v_sent_results_count + 1;
                    ELSE
                        v_failed_results_count := v_failed_results_count + 1; 
                    -- MERGE statement to insert/update asr_process_run
                        MERGE INTO asr_process_run target
                        USING (
                            SELECT 
                                v_record.order_number as order_number,
                                v_record.order_test_code as order_test_code,
                                v_record.result_test_code as result_test_code,
                                v_record.performing_lab_id as performing_lab_id,
                                v_record.textual_result_full as textual_result_full,
                                v_record.patient_last_name as patient_last_name,
                                v_states(i) as source,
                                TO_CHAR(v_process_date, 'DD-MON-YY') as activitydate,
                                'N' as complete
                            FROM DUAL
                        ) source ON (
                            target.order_number = source.order_number 
                            AND target.result_test_code = source.result_test_code
                        )
--                        WHEN MATCHED THEN
--                            UPDATE SET
--                                target.order_test_code = source.order_test_code,
--                                target.performing_lab_id = source.performing_lab_id,
--                                target.textual_result_full = source.textual_result_full,
--                                target.patient_last_name = source.patient_last_name,
--                                target.source = source.source,
--                                target.activitydate = source.activitydate,
--                                target.complete = 'Z'
                        WHEN NOT MATCHED THEN
                            INSERT (
                                order_number,
                                order_test_code,
                                result_test_code,
                                performing_lab_id,
                                textual_result_full,
                                patient_last_name,
                                source,
                                activitydate,
                                complete
                            ) VALUES (
                                source.order_number,
                                source.order_test_code,
                                source.result_test_code,
                                source.performing_lab_id,
                                source.textual_result_full,
                                source.patient_last_name,
                                source.source,
                                source.activitydate,
                                source.complete
                            );
                    END IF;
                    
                  
                    
                    -- Display first 5 results for each state
                    IF v_count <= 35 THEN
                        DBMS_OUTPUT.PUT_LINE('  Result ' || v_count || ': ' || 
                            NVL(TO_CHAR(v_record.order_number), 'NULL') || ' | ' || 
                            NVL(TO_CHAR(v_record.order_test_code), 'NULL') || ' | ' || 
                            NVL(TO_CHAR(v_record.result_test_code), 'NULL') || ' | ' ||
                            NVL(TO_CHAR(v_record.result_status), 'NULL') || ' | ' ||
                            NVL(SUBSTR(v_record.textual_result, 1, 20), 'NULL') || ' | ' ||
                            CASE WHEN v_exists_in_sent_log > 0 THEN 'IN_SENT_LOG' ELSE 'NOT_IN_SENT_LOG' END);
                    END IF;
                EXCEPTION
                    WHEN OTHERS THEN
                        DBMS_OUTPUT.PUT_LINE('  ERROR checking record ' || v_count || ': ' || SQLERRM);
                        v_failed_results_count := v_failed_results_count + 1;
                END;
                
                commit;
            END LOOP;
            
            CLOSE v_cursor;
            
            -- Display summary for this state
            DBMS_OUTPUT.PUT_LINE('  Summary - Total Final Results: ' || v_count || 
                               ', Found in sent_log: ' || v_sent_results_count || 
                               ', Missing from sent_log: ' || v_failed_results_count || 
                               ', Match Rate: ' || ROUND((v_sent_results_count / GREATEST(v_count, 1)) * 100, 1) || '%');
            
            v_total_count := v_total_count + v_count;
            v_total_matched := v_total_matched + v_sent_results_count;
            v_total_unmatched := v_total_unmatched + v_failed_results_count;
            
        EXCEPTION
            WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE('  ERROR for state ' || v_states(i) || ': ' || SQLERRM);
        END;
        
        DBMS_OUTPUT.PUT_LINE('');
    END LOOP;
    
    BEGIN
    
    DELETE FROM asr_process_run 
    WHERE activitydate = TRUNC(SYSDATE)
    AND order_test_code = '310'
    AND (order_number, order_test_code) IN (
    SELECT order_number, order_test_code
    FROM asr_process_run
    WHERE activitydate = TRUNC(SYSDATE)
    AND order_test_code = '310'
    GROUP BY order_number, order_test_code
    HAVING COUNT(1) = 1
);

DBMS_OUTPUT.PUT_LINE('Deleting 310 invalid ' || SQL%Rowcount);

    COMMIT;
    
    

    EXCEPTION
            WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE('  ERROR Deleting 310 invalid ' || SQLERRM);
       
    
    END;
    
    DBMS_OUTPUT.PUT_LINE('=== OVERALL SUMMARY ===');
    DBMS_OUTPUT.PUT_LINE('States processed: ' || v_states.COUNT);
    DBMS_OUTPUT.PUT_LINE('Total records processed: ' || v_total_count);
    DBMS_OUTPUT.PUT_LINE('Total matched in sent_log: ' || v_total_matched);
    DBMS_OUTPUT.PUT_LINE('Total missing from sent_log: ' || v_total_unmatched);
    DBMS_OUTPUT.PUT_LINE('Overall match rate: ' || ROUND((v_total_matched / GREATEST(v_total_count, 1)) * 100, 2) || '%');
    
END;

/
SELECT      accession_number, facility_id, cid, ethnic_group, patient_race, external_mrn,     patient_last_name, patient_first_name, patient_middle_name, date_of_birth,     gender, patient_ssn, npi, ordering_physician_name, report_notes,     specimen_receive_date, collection_date, collection_time, collection_date_time,     draw_freq, res_rprt_status_chng_dt_time, order_detail_status, order_test_code,     order_test_name, result_test_code, result_test_name, result_status,     textual_result, textual_result_full, numeric_result, units, reference_range,     abnormal_flag, release_date_time, result_comments, performing_lab_id,     order_method, specimen_source, order_number, logging_site, age,     facility_name, cond_code, patient_type, source_of_comment, patient_id,     alternate_patient_id, requisition_status, facility_address1, facility_address2,     facility_city, facility_state, facility_zip, facility_phone,     patient_account_address1, patient_account_address2, patient_account_city,     patient_account_state, patient_account_zip, patient_home_phone, loinc_code,     loinc_name, value_type, east_west_flag, internal_external_flag,     last_update_time, sequence_no, facility_account_status, facility_active_flag,     micro_isolate, micro_organism_name, lab_fk, clinical_manager, medical_director,     acti_facility_id, fmc_number, reportable_state, source_state, device_name FROM ( SELECT base.* ,ROW_NUMBER() OVER (PARTITION BY order_number, result_test_code ORDER BY accession_number, facility_id, patient_last_name ) as rn  FROM (SELECT gtt.* FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT gtt WHERE 1=1 AND gtt.order_test_code = '301' AND gtt.result_test_code = '301' AND ((upper(result_comments) LIKE upper('%Newly confirmed Positive%') or upper(result_comments) LIKE upper('%New positive%'))) UNION ALL SELECT gtt.* FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT gtt WHERE 1=1 AND gtt.order_test_code = '310' AND gtt.result_test_code = '310' AND ((upper(textual_result_full) LIKE upper('Positive%') or upper(textual_result_full) LIKE upper('Equivocal%') or upper(textual_result_full) LIKE upper('Reactive%')))
 UNION ALL SELECT gtt.* FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT gtt WHERE 1=1 AND gtt.order_test_code = '312' AND gtt.result_test_code = '312' AND ((upper(textual_result_full) LIKE upper('Positive%') or upper(textual_result_full) LIKE upper('Equivocal%') or upper(textual_result_full) LIKE upper('Reactive%')))
 UNION ALL SELECT gtt.* FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT gtt WHERE 1=1 AND gtt.order_test_code = '319N' AND gtt.result_test_code = '319N' AND ((upper(textual_result_full) LIKE upper('Positive%') or upper(textual_result_full) LIKE upper('Equivocal%') or upper(textual_result_full) LIKE upper('Reactive%')))
 UNION ALL SELECT gtt.* FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT gtt WHERE 1=1 AND gtt.order_test_code = '9239' AND gtt.result_test_code = 'A409' AND ((upper(textual_result_full) LIKE upper('Positive%') or upper(textual_result_full) LIKE upper('Equivocal%') or upper(textual_result_full) LIKE upper('Reactive%')))
 UNION ALL SELECT gtt.* FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT gtt WHERE 1=1 AND gtt.order_test_code = '303' AND gtt.result_test_code = '303' AND ((upper(textual_result_full) LIKE upper('Positive%') or upper(textual_result_full) LIKE upper('Equivocal%') or upper(textual_result_full) LIKE upper('Reactive%')))
 UNION ALL SELECT gtt.* FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT gtt WHERE 1=1 AND gtt.order_test_code = '308' AND gtt.result_test_code = '308' AND ((upper(textual_result_full) LIKE upper('Positive%') or upper(textual_result_full) LIKE upper('Equivocal%') or upper(textual_result_full) LIKE upper('Reactive%')))
 UNION ALL SELECT gtt.* FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT gtt WHERE 1=1 AND gtt.order_test_code = '319C' AND gtt.result_test_code = '319T' AND ((upper(textual_result_full) LIKE upper('Positive%') or upper(textual_result_full) LIKE upper('Equivocal%') or upper(textual_result_full) LIKE upper('Reactive%')))
 UNION ALL SELECT gtt.* FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT gtt WHERE 1=1 AND gtt.order_test_code = '304' AND gtt.result_test_code = '304' AND ((upper(textual_result_full) LIKE upper('Positive%') or upper(textual_result_full) LIKE upper('Equivocal%') or upper(textual_result_full) LIKE upper('Reactive%')))
 UNION ALL SELECT gtt.* FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT gtt WHERE 1=1 AND gtt.order_test_code = '310' AND gtt.result_test_code = '310A' AND ((gtt.value_type = 'ST' and gtt.textual_result_full like '%>11.00%'))
 UNION ALL SELECT gtt.* FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT gtt WHERE 1=1 AND gtt.order_test_code = '332' AND gtt.result_test_code = '332' AND ((upper(textual_result_full) LIKE upper('Positive%') or upper(textual_result_full) LIKE upper('Equivocal%') or upper(textual_result_full) LIKE upper('Reactive%')))
 UNION ALL SELECT gtt.* FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT gtt WHERE 1=1 AND gtt.order_test_code = '336' AND gtt.result_test_code = '336' AND ((upper(textual_result_full) LIKE upper('Positive%') or upper(textual_result_full) LIKE upper('Equivocal%') or upper(textual_result_full) LIKE upper('Reactive%')))
 UNION ALL SELECT gtt.* FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT gtt WHERE 1=1 AND gtt.order_test_code = '311' AND ((upper(textual_result_full) LIKE upper('%')))
 UNION ALL SELECT gtt.* FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT gtt WHERE 1=1 AND gtt.order_test_code = '318' AND gtt.result_test_code = '318L' AND ((upper(textual_result_full) LIKE upper('%')))
 UNION ALL SELECT gtt.* FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT gtt WHERE 1=1 AND gtt.order_test_code = '318' AND gtt.result_test_code = '318R' AND ((upper(textual_result_full) LIKE upper('%')))
 UNION ALL SELECT gtt.* FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT gtt WHERE 1=1 AND gtt.order_test_code = '310' AND gtt.result_test_code = '310A' AND ((gtt.value_type = 'NM' and gtt.numeric_result > 0.00))
) base WHERE patient_account_state = 'TX' AND TRUNC(release_date_time) = DATE '2025-09-06' AND result_status = 'F')
 where rn = 1

/

SELECT      accession_number, facility_id, cid, ethnic_group, patient_race, external_mrn,     patient_last_name, patient_first_name, patient_middle_name, date_of_birth,     gender, patient_ssn, npi, ordering_physician_name, report_notes,     specimen_receive_date, collection_date, collection_time, collection_date_time,     draw_freq, res_rprt_status_chng_dt_time, order_detail_status, order_test_code,     order_test_name, result_test_code, result_test_name, result_status,     textual_result, textual_result_full, numeric_result, units, reference_range,     abnormal_flag, release_date_time, result_comments, performing_lab_id,     order_method, specimen_source, order_number, logging_site, age,     facility_name, cond_code, patient_type, source_of_comment, patient_id,     alternate_patient_id, requisition_status, facility_address1, facility_address2,     facility_city, facility_state, facility_zip, facility_phone,     patient_account_address1, patient_account_address2, patient_account_city,     patient_account_state, patient_account_zip, patient_home_phone, loinc_code,     loinc_name, value_type, east_west_flag, internal_external_flag,     last_update_time, sequence_no, facility_account_status, facility_active_flag,     micro_isolate, micro_organism_name, lab_fk, clinical_manager, medical_director,     acti_facility_id, fmc_number, reportable_state, source_state, device_name 
FROM ( 
SELECT base.* ,ROW_NUMBER() OVER (PARTITION BY order_number, result_test_code ORDER BY accession_number, facility_id, patient_last_name ) as rn  
FROM 
(SELECT gtt.* FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT gtt WHERE 1=1 AND gtt.order_test_code = '310' AND gtt.result_test_code = '310' AND ((upper(textual_result_full) LIKE upper('Positive%') or upper(textual_result_full) LIKE upper('Equivocal%') or upper(textual_result_full) LIKE upper('Reactive%'))) UNION ALL SELECT gtt.* FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT gtt WHERE 1=1 AND gtt.order_test_code = '310' AND gtt.result_test_code = '310A' AND ((gtt.value_type = 'ST' and gtt.textual_result_full like '%>11.00%'))
 UNION ALL SELECT gtt.* FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT gtt WHERE 1=1 AND gtt.order_test_code = '310' AND gtt.result_test_code = '310A' AND ((gtt.value_type = 'NM' and gtt.numeric_result > 0.00))
 UNION ALL SELECT gtt.* FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT gtt WHERE 1=1 AND gtt.order_test_code = '311' AND ((upper(textual_result_full) NOT LIKE upper('Not Detected%')))
 UNION ALL SELECT gtt.* FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT gtt WHERE 1=1 AND gtt.order_test_code = '301' AND gtt.result_test_code = '301' AND ((upper(result_comments) LIKE upper('%Newly confirmed Positive%') or upper(result_comments) LIKE upper('%New positive%')))
 UNION ALL SELECT gtt.* FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT gtt WHERE 1=1 AND gtt.order_test_code = '312' AND gtt.result_test_code = '312' AND ((upper(textual_result_full) LIKE upper('Positive%') or upper(textual_result_full) LIKE upper('Equivocal%') or upper(textual_result_full) LIKE upper('Reactive%')))
 UNION ALL SELECT gtt.* FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT gtt WHERE 1=1 AND gtt.order_test_code = '319N' AND gtt.result_test_code = '319N' AND ((upper(textual_result_full) LIKE upper('Positive%') or upper(textual_result_full) LIKE upper('Equivocal%') or upper(textual_result_full) LIKE upper('Reactive%')))
 UNION ALL SELECT gtt.* FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT gtt WHERE 1=1 AND gtt.order_test_code = '9129' AND gtt.result_test_code = 'A191' AND ((upper(textual_result_full) LIKE upper('%')))
 UNION ALL SELECT gtt.* FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT gtt WHERE 1=1 AND gtt.order_test_code = '9239' AND gtt.result_test_code = 'A409' AND ((upper(textual_result_full) LIKE upper('Positive%') or upper(textual_result_full) LIKE upper('Equivocal%') or upper(textual_result_full) LIKE upper('Reactive%')))
 UNION ALL SELECT gtt.* FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT gtt WHERE 1=1 AND gtt.order_test_code = '303' AND gtt.result_test_code = '303' AND ((upper(textual_result_full) LIKE upper('Positive%') or upper(textual_result_full) LIKE upper('Equivocal%') or upper(textual_result_full) LIKE upper('Reactive%')))
 UNION ALL SELECT gtt.* FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT gtt WHERE 1=1 AND gtt.order_test_code = '308' AND gtt.result_test_code = '308' AND ((upper(textual_result_full) LIKE upper('Positive%') or upper(textual_result_full) LIKE upper('Equivocal%') or upper(textual_result_full) LIKE upper('Reactive%')))
 UNION ALL SELECT gtt.* FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT gtt WHERE 1=1 AND gtt.order_test_code = '319C' AND gtt.result_test_code = '319T' AND ((upper(textual_result_full) LIKE upper('Positive%') or upper(textual_result_full) LIKE upper('Equivocal%') or upper(textual_result_full) LIKE upper('Reactive%')))
 UNION ALL SELECT gtt.* FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT gtt WHERE 1=1 AND gtt.order_test_code = '301' AND gtt.result_test_code = '301' AND ((upper(result_comments) LIKE upper('%Newly confirmed Positive%') or upper(result_comments) LIKE upper('%New positive%')))
 UNION ALL SELECT gtt.* FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT gtt WHERE 1=1 AND gtt.order_test_code = '318' AND gtt.result_test_code = '318R' AND (regexp_like(textual_result_full,'^(Not Detected)$|([<>]=|<|>|=)?(\d+(?:\.\d+)?)'))
 UNION ALL SELECT gtt.* FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT gtt WHERE 1=1 AND gtt.order_test_code = '310' AND gtt.result_test_code = '310' AND ((upper(textual_result_full) LIKE upper('Positive%') or upper(textual_result_full) LIKE upper('Equivocal%') or upper(textual_result_full) LIKE upper('Reactive%')))
 UNION ALL SELECT gtt.* FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT gtt WHERE 1=1 AND gtt.order_test_code = '311' AND ((upper(textual_result_full) LIKE upper('%')))
 UNION ALL SELECT gtt.* FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT gtt WHERE 1=1 AND gtt.order_test_code = '312' AND gtt.result_test_code = '312' AND ((upper(textual_result_full) LIKE upper('Positive%') or upper(textual_result_full) LIKE upper('Equivocal%') or upper(textual_result_full) LIKE upper('Reactive%')))
 UNION ALL SELECT gtt.* FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT gtt WHERE 1=1 AND gtt.order_test_code = '319N' AND gtt.result_test_code = '319N' AND ((upper(textual_result_full) LIKE upper('Positive%') or upper(textual_result_full) LIKE upper('Equivocal%') or upper(textual_result_full) LIKE upper('Reactive%')))
 UNION ALL SELECT gtt.* FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT gtt WHERE 1=1 AND gtt.order_test_code = '9239' AND gtt.result_test_code = 'A409' AND ((upper(textual_result_full) LIKE upper('Positive%') or upper(textual_result_full) LIKE upper('Equivocal%') or upper(textual_result_full) LIKE upper('Reactive%')))
 UNION ALL SELECT gtt.* FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT gtt WHERE 1=1 AND gtt.order_test_code = '303' AND gtt.result_test_code = '303' AND ((upper(textual_result_full) LIKE upper('Positive%') or upper(textual_result_full) LIKE upper('Equivocal%') or upper(textual_result_full) LIKE upper('Reactive%')))
 UNION ALL SELECT gtt.* FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT gtt WHERE 1=1 AND gtt.order_test_code = '308' AND gtt.result_test_code = '308' AND ((upper(textual_result_full) LIKE upper('Positive%') or upper(textual_result_full) LIKE upper('Equivocal%') or upper(textual_result_full) LIKE upper('Reactive%')))
 UNION ALL SELECT gtt.* FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT gtt WHERE 1=1 AND gtt.order_test_code = '319C' AND gtt.result_test_code = '319T' AND ((upper(textual_result_full) LIKE upper('Positive%') or upper(textual_result_full) LIKE upper('Equivocal%') or upper(textual_result_full) LIKE upper('Reactive%')))
 UNION ALL SELECT gtt.* FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT gtt WHERE 1=1 AND gtt.order_test_code = '310' AND gtt.result_test_code = '310A' AND ((gtt.value_type = 'NM' and gtt.numeric_result > 0.00))
 UNION ALL SELECT gtt.* FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT gtt WHERE 1=1 AND gtt.order_test_code = '310' AND gtt.result_test_code = '310A' AND ((gtt.value_type = 'ST' and gtt.textual_result_full like '%>11.00%'))
 UNION ALL SELECT gtt.* FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT gtt WHERE 1=1 AND gtt.order_test_code = '332' AND gtt.result_test_code = '332' AND ((upper(textual_result_full) LIKE upper('Positive%') or upper(textual_result_full) LIKE upper('Negative%')))
 UNION ALL SELECT gtt.* FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT gtt WHERE 1=1 AND gtt.order_test_code = '336' AND gtt.result_test_code = '336' AND ((upper(textual_result_full) LIKE upper('Positive%') or upper(textual_result_full) LIKE upper('Equivocal%') or upper(textual_result_full) LIKE upper('Reactive%')))
 UNION ALL SELECT gtt.* FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT gtt WHERE 1=1 AND gtt.order_test_code = '317L' AND ((gtt.value_type = 'NM' and gtt.numeric_result >= 25.0))
) base 
WHERE 
patient_account_state = 'NC' 
AND TRUNC(release_date_time) = DATE '2025-09-06' 
AND result_status = 'F')
where rn = 1;



/

-- Solution for deduplicating UNION ALL query with CLOB fields
-- Uses ROW_NUMBER() to avoid DISTINCT on CLOB columns

SELECT * FROM (
    SELECT 
        base.*,
        ROW_NUMBER() OVER (
            PARTITION BY order_number, result_test_code 
            ORDER BY ROWID
        ) as rn
    FROM (
        SELECT gtt.* FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT gtt WHERE 1=1 AND gtt.order_test_code = '310' AND gtt.result_test_code = '310' AND ((upper(textual_result_full) LIKE upper('Positive%') or upper(textual_result_full) LIKE upper('Equivocal%') or upper(textual_result_full) LIKE upper('Reactive%'))) 
        UNION ALL SELECT gtt.* FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT gtt WHERE 1=1 AND gtt.order_test_code = '310' AND gtt.result_test_code = '310A' AND ((gtt.value_type = 'ST' and gtt.textual_result_full like '%>11.00%'))
        UNION ALL SELECT gtt.* FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT gtt WHERE 1=1 AND gtt.order_test_code = '310' AND gtt.result_test_code = '310A' AND ((gtt.value_type = 'NM' and gtt.numeric_result > 0.00))
        UNION ALL SELECT gtt.* FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT gtt WHERE 1=1 AND gtt.order_test_code = '311' AND ((upper(textual_result_full) NOT LIKE upper('Not Detected%')))
        UNION ALL SELECT gtt.* FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT gtt WHERE 1=1 AND gtt.order_test_code = '301' AND gtt.result_test_code = '301' AND ((upper(result_comments) LIKE upper('%Newly confirmed Positive%') or upper(result_comments) LIKE upper('%New positive%')))
        UNION ALL SELECT gtt.* FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT gtt WHERE 1=1 AND gtt.order_test_code = '312' AND gtt.result_test_code = '312' AND ((upper(textual_result_full) LIKE upper('Positive%') or upper(textual_result_full) LIKE upper('Equivocal%') or upper(textual_result_full) LIKE upper('Reactive%')))
        UNION ALL SELECT gtt.* FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT gtt WHERE 1=1 AND gtt.order_test_code = '319N' AND gtt.result_test_code = '319N' AND ((upper(textual_result_full) LIKE upper('Positive%') or upper(textual_result_full) LIKE upper('Equivocal%') or upper(textual_result_full) LIKE upper('Reactive%')))
        UNION ALL SELECT gtt.* FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT gtt WHERE 1=1 AND gtt.order_test_code = '9129' AND gtt.result_test_code = 'A191' AND ((upper(textual_result_full) LIKE upper('%')))
        UNION ALL SELECT gtt.* FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT gtt WHERE 1=1 AND gtt.order_test_code = '9239' AND gtt.result_test_code = 'A409' AND ((upper(textual_result_full) LIKE upper('Positive%') or upper(textual_result_full) LIKE upper('Equivocal%') or upper(textual_result_full) LIKE upper('Reactive%')))
        UNION ALL SELECT gtt.* FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT gtt WHERE 1=1 AND gtt.order_test_code = '303' AND gtt.result_test_code = '303' AND ((upper(textual_result_full) LIKE upper('Positive%') or upper(textual_result_full) LIKE upper('Equivocal%') or upper(textual_result_full) LIKE upper('Reactive%')))
        UNION ALL SELECT gtt.* FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT gtt WHERE 1=1 AND gtt.order_test_code = '308' AND gtt.result_test_code = '308' AND ((upper(textual_result_full) LIKE upper('Positive%') or upper(textual_result_full) LIKE upper('Equivocal%') or upper(textual_result_full) LIKE upper('Reactive%')))
        UNION ALL SELECT gtt.* FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT gtt WHERE 1=1 AND gtt.order_test_code = '319C' AND gtt.result_test_code = '319T' AND ((upper(textual_result_full) LIKE upper('Positive%') or upper(textual_result_full) LIKE upper('Equivocal%') or upper(textual_result_full) LIKE upper('Reactive%')))
        UNION ALL SELECT gtt.* FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT gtt WHERE 1=1 AND gtt.order_test_code = '318' AND gtt.result_test_code = '318R' AND (regexp_like(textual_result_full,'^(Not Detected)$|([<>]=|<|>|=)?(\d+(?:\.\d+)?)'))
        UNION ALL SELECT gtt.* FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT gtt WHERE 1=1 AND gtt.order_test_code = '311' AND ((upper(textual_result_full) LIKE upper('%')))
        UNION ALL SELECT gtt.* FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT gtt WHERE 1=1 AND gtt.order_test_code = '332' AND gtt.result_test_code = '332' AND ((upper(textual_result_full) LIKE upper('Positive%') or upper(textual_result_full) LIKE upper('Negative%')))
        UNION ALL SELECT gtt.* FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT gtt WHERE 1=1 AND gtt.order_test_code = '336' AND gtt.result_test_code = '336' AND ((upper(textual_result_full) LIKE upper('Positive%') or upper(textual_result_full) LIKE upper('Equivocal%') or upper(textual_result_full) LIKE upper('Reactive%')))
        UNION ALL SELECT gtt.* FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT gtt WHERE 1=1 AND gtt.order_test_code = '317L' AND ((gtt.value_type = 'NM' and gtt.numeric_result >= 25.0))
    ) base 
    WHERE patient_account_state = 'NC' 
    AND TRUNC(release_date_time) = DATE '2025-09-06' 
    AND result_status = 'F'
) 
WHERE rn = 1
ORDER BY accession_number, order_test_code, result_test_code;

