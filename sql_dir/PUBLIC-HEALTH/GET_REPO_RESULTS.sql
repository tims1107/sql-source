declare p_out number;


begin

    for rec IN (select lo.lab_fk,a.requisition_id, lo.initiate_id,state,order_test_code,textual_result_full,result_status,a.last_updated_date from ih_dw.dw_ods_activity a
        join ih_dw.results r ON r.requisition_id = a.requisition_id
        join ih_dw.dim_lab_order lo ON lo.requisition_id = a.requisition_id
        join patientmaster pm ON pm.eid = lo.initiate_id and pm.lab_fk = lo.lab_fk
        where a.last_updated_date > sysdate - 1
        and regexp_like(order_test_code,'^(310|301|311|318|319N|303|312|308)$')
        and result_status = 'F'
        and state = 'NJ'
        order by a.last_updated_date,order_test_code)
    loop
    
        for pat IN 
    end loop;
    
end;