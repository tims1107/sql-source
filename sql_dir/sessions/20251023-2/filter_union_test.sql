SELECT      accession_number, facility_id, cid, ethnic_group, patient_race, external_mrn,     patient_last_name, patient_first_name, patient_middle_name, date_of_birth,     gender, patient_ssn, npi, ordering_physician_name, report_notes,     specimen_receive_date, collection_date, collection_time, collection_date_time,     draw_freq, res_rprt_status_chng_dt_time, order_detail_status, order_test_code,     order_test_name, result_test_code, result_test_name, result_status,     textual_result, textual_result_full, numeric_result, units, reference_range,     abnormal_flag, release_date_time, result_comments, performing_lab_id,     order_method, specimen_source, order_number, logging_site, age,     facility_name, cond_code, patient_type, source_of_comment, patient_id,     alternate_patient_id, requisition_status, facility_address1, facility_address2,     facility_city, facility_state, facility_zip, facility_phone,     patient_account_address1, patient_account_address2, patient_account_city,     patient_account_state, patient_account_zip, patient_home_phone, loinc_code,     loinc_name, value_type, east_west_flag, internal_external_flag,     last_update_time, sequence_no, facility_account_status, facility_active_flag,     micro_isolate, micro_organism_name, lab_fk, clinical_manager, medical_director,     acti_facility_id, fmc_number, reportable_state, source_state, device_name FROM ( SELECT base.* ,ROW_NUMBER() OVER (PARTITION BY
order_number, result_test_code ORDER BY accession_number, facility_id, patient_last_name ) as rn  FROM (SELECT gtt.* FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT gtt WHERE 1=1 AND gtt.order_test_code = '301' AND gtt.result_test_code = '301' AND ((upper(result_comments) LIKE upper('%Newly confirmed Positive%') or upper(result_comments) LIKE upper('%New positive%'))) UNION ALL SELECT gtt.* FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT gtt WHERE 1=1 AND gtt.order_test_code = '318' AND ((upper(textual_result_full) LIKE upper('%')))
 UNION ALL SELECT gtt.* FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT gtt WHERE 1=1 AND gtt.order_test_code = '310' AND gtt.result_test_code = '310' AND ((upper(textual_result_full) LIKE upper('Positive%') or upper(textual_result_full) LIKE upper('Equivocal%') or upper(textual_result_full) LIKE upper('Reactive%')))
 UNION ALL SELECT gtt.* FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT gtt WHERE 1=1 AND gtt.order_test_code = '311' AND ((upper(textual_result_full) LIKE upper('%')))
 UNION ALL SELECT gtt.* FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT gtt WHERE 1=1 AND gtt.order_test_code = '312' AND gtt.result_test_code = '312' AND ((upper(textual_result_full) LIKE upper('Positive%') or upper(textual_result_full) LIKE upper('Equivocal%') or upper(textual_result_full) LIKE upper('Reactive%')))
 UNION ALL SELECT gtt.* FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT gtt WHERE 1=1 AND gtt.order_test_code = '319N' AND gtt.result_test_code = '319N' AND ((upper(textual_result_full) LIKE upper('Positive%') or upper(textual_result_full) LIKE upper('Equivocal%') or upper(textual_result_full) LIKE upper('Reactive%')))
 UNION ALL SELECT gtt.* FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT gtt WHERE 1=1 AND gtt.order_test_code = '9239' AND gtt.result_test_code = 'A409' AND ((upper(textual_result_full) LIKE upper('Positive%') or upper(textual_result_full) LIKE upper('Equivocal%') or upper(textual_result_full) LIKE upper('Reactive%')))
 UNION ALL SELECT gtt.* FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT gtt WHERE 1=1 AND gtt.order_test_code = '303' AND gtt.result_test_code = '303' AND ((upper(textual_result_full) LIKE upper('Positive%') or upper(textual_result_full) LIKE upper('Equivocal%') or upper(textual_result_full) LIKE upper('Reactive%')))
 UNION ALL SELECT gtt.* FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT gtt WHERE 1=1 AND gtt.order_test_code = '308' AND gtt.result_test_code = '308' AND ((upper(textual_result_full) LIKE upper('Positive%') or upper(textual_result_full) LIKE upper('Equivocal%') or upper(textual_result_full) LIKE upper('Reactive%')))
 UNION ALL SELECT gtt.* FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT gtt WHERE 1=1 AND gtt.order_test_code = '319C' AND gtt.result_test_code = '319T' AND ((upper(textual_result_full) LIKE upper('Positive%') or upper(textual_result_full) LIKE upper('Equivocal%') or upper(textual_result_full) LIKE upper('Reactive%')))
 UNION ALL SELECT gtt.* FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT gtt WHERE 1=1 AND gtt.order_test_code = '304' AND gtt.result_test_code = '304' AND ((upper(textual_result_full) LIKE upper('Positive%') or upper(textual_result_full) LIKE upper('Equivocal%') or upper(textual_result_full) LIKE upper('Reactive%')))
 UNION ALL SELECT gtt.* FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT gtt WHERE 1=1 AND gtt.order_test_code = '310' AND gtt.result_test_code = '310A' AND ((gtt.value_type = 'NM' and gtt.numeric_result > 0.00))
 UNION ALL SELECT gtt.* FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT gtt WHERE 1=1 AND gtt.order_test_code = '310' AND gtt.result_test_code = '310A' AND ((gtt.value_type = 'ST' and gtt.textual_result_full like '%>11.00%'))
 UNION ALL SELECT gtt.* FROM STATERPT_OWNER.GTT_RESULTS_EXTRACT gtt WHERE 1=1 AND gtt.order_test_code = '332' AND gtt.result_test_code = '332' AND ((upper(textual_result_full) LIKE upper('Positive%') or upper(textual_result_full) LIKE upper('Negative%')))
) base WHERE patient_account_state = 'AL' AND TRUNC(release_date_time) = DATE '2025-10-14' AND result_status = 'F' AND regexp_like(order_test_code,'^(110|111|113|301|303|304|308|310|311|312|315|317L|318|319N|322|323|327|332|336)$'))
 where rn = 1
 
 /
 
 select * from state_master
 where length(state_abbreviation) = 2
 order by state;
 
 create table results_extract_20251015
 as
 select * from gtt_results_extract;
 
 select * from results_extract_20251015
 where patient_account_state = 'CA'
 and regexp_like(order_test_code,'^(110|111|113|301|303|304|308|310|311|312|315|317L|318|319N|322|323|327|332|336)$');
 
 select patient_account_state from gtt_results_extract
 where regexp_like(order_test_code,'^(315|317L|322|323|327)$')
 and (regexp_like(patient_account_state,'^(PR|GU|MP|VI|UT|OH|ME|ID|IL|IN|AR|AZ)$')
 or regexp_like(facility_state,'^(PR|GU|MP|VI|UT|OH|ME|ID|IL|IN|AR|AZ)$'));