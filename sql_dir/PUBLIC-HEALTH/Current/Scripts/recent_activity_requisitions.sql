select * from condition_master_test cmt
join condition_filters cf

/

WITH recent_activity_requisitions AS (
    SELECT requisition_id
    FROM ih_dw.dw_ods_activity
    WHERE last_updated_date > TO_TIMESTAMP('24-MAY-25 12.00.00.000000000 AM', 'DD-MON-RR HH.MI.SS.FF9 PM')
    GROUP BY requisition_id -- Achieves the same as DISTINCT requisition_id
)
-- ... rest of the query remains the same
SELECT
    r.requisition_id,
    r.order_test_code,
    r.result_test_code,
    r.performing_lab,
    r.textual_result_full,
    dp.last_name lname,
    dp.state,
    r.last_updated_date
   
FROM
    ih_dw.results r
INNER JOIN
    ih_dw.dim_lab_order lo ON lo.requisition_id = r.requisition_id
--INNER JOIN

    -- patientmaster pm ON pm.eid = lo.initiate_id AND r.lab_fk = pm.lab_fk
INNER JOIN
    IH_DW.SPECTRA_MRN_ASSOCIATIONS asso ON  asso.SPECTRA_MRN_ASSC_pk = lo.SPECTRA_MRN_ASSC_FK 
    
INNER JOIN
    IH_DW.DIM_PATIENT dp ON dp.spectra_mrn_fk = asso.spectra_mrn_fk   

INNER JOIN
    recent_activity_requisitions rar ON r.requisition_id = rar.requisition_id -- Joining with the CTE
WHERE
dp.state = 'IL'  -- Filter for patient state
    AND EXISTS (
        -- This subquery checks if the requisition_id from 'r'
        -- exists in recent activities.
        SELECT 1
        FROM ih_dw.dw_ods_activity doa
        WHERE doa.requisition_id = r.requisition_id -- Correlation with the outer query
          AND doa.last_updated_date > TO_TIMESTAMP('24-MAY-25 12.00.00.000000000 AM', 'DD-MON-RR HH.MI.SS.FF9 PM')
          AND r.last_updated_date > TO_TIMESTAMP('24-MAY-25 12.00.00.000000000 AM', 'DD-MON-RR HH.MI.SS.FF9 PM')
    )
    AND r.result_status = 'F'
    and external_id_type = 'INITIATE_ID'
    and regexp_like(external_id,'^8');
    
/

select distinct order_number,order_test_code,order_test_name,result_test_code,result_test_name,textual_result_full,collection_date from results_sent_log
where patient_account_state = 'PA'
and order_test_code IN ('303','308','301','312','336','332')
and collection_date between TO_TIMESTAMP('01-JAN-25 12.00.00.000000000 AM', 'DD-MON-RR HH.MI.SS.FF9 PM')
and TO_TIMESTAMP('15-MAR-25 12.00.00.000000000 AM', 'DD-MON-RR HH.MI.SS.FF9 PM')
order by order_test_code;
order by last_update_time desc;

select patient_account_state from results_sent_log
where order_number = '96665WK';
