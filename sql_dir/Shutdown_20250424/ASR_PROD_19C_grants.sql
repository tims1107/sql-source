/
BEGIN
    FOR t IN (SELECT table_name FROM all_tables WHERE owner = 'STATERPT_OWNER') LOOP
        EXECUTE IMMEDIATE 'GRANT SELECT, INSERT, UPDATE, DELETE ON ' || t.owner || '.' || t.table_name || ' TO STATERPT_USER';
    END LOOP;

    FOR v IN (SELECT view_name FROM all_views WHERE owner = 'STATERPT_OWNER') LOOP
        EXECUTE IMMEDIATE 'GRANT SELECT ON ' || v.owner || '.' || v.view_name || ' TO STATERPT_USER';
    END LOOP;

    FOR s IN (SELECT sequence_name FROM all_sequences WHERE owner = 'STATERPT_OWNER') LOOP
        EXECUTE IMMEDIATE 'GRANT SELECT ON ' || s.owner || '.' || s.sequence_name || ' TO STATERPT_USER';
    END LOOP;

    FOR p IN (SELECT object_name FROM all_objects WHERE object_type IN ('PROCEDURE', 'FUNCTION') AND owner = 'STATERPT_OWNER') LOOP
        EXECUTE IMMEDIATE 'GRANT EXECUTE ON ' || p.owner || '.' || p.object_name || ' TO STATERPT_USER';
    END LOOP;

    FOR p IN (SELECT object_name FROM all_objects WHERE object_type = 'PACKAGE' AND owner = 'STATERPT_OWNER') LOOP
        EXECUTE IMMEDIATE 'GRANT EXECUTE ON ' || p.owner || '.' || p.object_name || ' TO STATERPT_USER';
    END LOOP;
END;
/
BEGIN
    -- table loop
    FOR t IN (SELECT owner,table_name FROM all_tables WHERE owner = 'STATERPT_OWNER') LOOP
        begin
            EXECUTE IMMEDIATE 'GRANT SELECT, INSERT, UPDATE, DELETE ON ' || t.owner || '.' || t.table_name || ' TO STATERPT_USER';
            
            Exception 
            when others then dbms_output.put_line(t.table_name || chr(9) || sqlerrm);
        
        end;
    END LOOP;
    
       
    -- view loop
    FOR v IN (SELECT owner,view_name FROM all_views WHERE owner = 'STATERPT_OWNER') LOOP
        begin    
            EXECUTE IMMEDIATE 'GRANT SELECT ON ' || v.owner || '.' || v.view_name || ' TO STATERPT_USER';
            
            
            Exception 
            when others then dbms_output.put_line(v.view_name || chr(9) || sqlerrm);
            
        end; 
    END LOOP;
 
end;


/

select * from vw_staff_results;

create synonym dim_lab for ih_dw.dim_lab;
create synonym DIM_LAB_ORDER for IH_DW.DIM_LAB_ORDER;

grant select ON DIM_LAB_ORDER to staterpt_user;

create table test_table4 
as
select * from snomed_master;