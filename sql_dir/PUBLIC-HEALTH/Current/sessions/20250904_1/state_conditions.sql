

SELECT    sm.state_abbreviation,
        sm.state,
            cm.condition_master_pk,
            cm.order_test_code,
            cm.result_test_code,
            cm.condition_value,
            cm.value_type,  -- Add this field
            cm.status,
            cf.filter
        FROM CONDITION_MASTER cm
        JOIN CONDITION_FILTERS cf ON cm.condition_filter_fk = cf.condition_filter_pk
        join state_master sm ON sm.state_master_pk = cm.state_fk
        where length(state_abbreviation) = 2
        and entity_type = 'Abnormal'
        AND cm.order_test_code = '310'
        --and state_abbreviation in ('AK','MI','NC')
        
        
        AND cm.status = 'active'
        AND cf.status = 'active'
        order by state;
        
delete condition_master
where condition_master_pk IN (1097,1589,1349,1350,1741,154,1753,1754);
        
        
SELECT    sm.state_abbreviation,
        sm.state
            
        FROM CONDITION_MASTER cm
        JOIN CONDITION_FILTERS cf ON cm.condition_filter_fk = cf.condition_filter_pk
        join state_master sm ON sm.state_master_pk = cm.state_fk
        where length(state_abbreviation) = 2
        and entity_type = 'Abnormal'
        AND cm.order_test_code = '318'
        AND cm.status = 'active'
        AND cf.status = 'active'
        group by state_abbreviation,sm.state
        having count(1) = 1
        order by state_abbreviation;
        
        ;
        
/

select * from asr_process_run
where activitydate = '22-AUG-25'
and complete = 'L';

