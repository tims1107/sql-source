
begin
    for rec IN (
        select e.requisition_id,e.last_updated_date,e.release_date_time,pm.*,zc.county,e.result_test_name,mi.* from micro_results_extract e
        join ih_dw.dim_lab_order lo ON lo.requisition_id = e.requisition_id
        join patientmaster pm ON pm.eid = lo.initiate_id and pm.lab_fk = e.lab_fk
        join dl_zip_code zc ON zc.zip = pm.zipcode
        join micro_identified mi ON mi.organism_name = e.micro_organism_name
        where regexp_like(result_test_name,'Isolate #','i')
        and regexp_like(pm.state,'^(CA|CO|CT|GA|MD|MN|NM|NY|OR|TN)$')
        and result_status = 'F'
        and regexp_like(e.micro_organism_name,'agalactiae','i')
        --and cre = 'N'
        --and e.requisition_id IN ('33374R8','4003Z18')
        order by e.micro_organism_name)
        loop
        
        
--            dbms_output.put_line(rec.requisition_id || chr(9)
--                || rec.organism_name);  
                
            if(rec.cre = 'Y') then
                begin
                --dbms_output.put_line('CRE');
                for drug IN (
                    select result_test_name,derived_abnormal_flag from ih_dw.results
                    where requisition_id = rec.requisition_id
                    and regexp_like(result_test_name,'penem','i')
                    and derived_abnormal_flag IN ('R','I'))
                loop
                    
                    dbms_output.put_line(rec.requisition_id || chr(9)
                        ||drug.result_test_name || chr(9)
                        || drug.derived_abnormal_flag || chr(9) 
                        || rec.organism_name || chr(9) 
                        || rec.county || chr(9) 
                        || rec.state);
                
                
                end loop;
                end;
            else
                dbms_output.put_line(rec.requisition_id || chr(9)
                        || rec.result_test_name || chr(9)
                        || 'N' || chr(9) 
                        || rec.organism_name
                        || rec.county || chr(9) 
                        || rec.state);
            end if;
                
        
        end loop;
        
end;

/

select result_test_name,abnormal_flag,micro_organism_name from ih_dw.results
where requisition_id = '5480A28';

select lod.* from ih_dw.dim_lab_order lo
join ih_dw.dim_lab_order_details lod ON lod.lab_order_fk = lo.lab_order_pk
where lo.requisition_id IN '2575NH4'
and regexp_like(test_category, 'micro','i');