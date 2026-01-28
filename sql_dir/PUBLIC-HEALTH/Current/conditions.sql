select * from asr_process_run
where source = 'NY'
and complete = 'R'
order by to_date(activitydate,'dd-MON-yy') desc;


select patient_race from results_sent_log
where result_source = 'New York NYHL7GeneratorContext'
group by patient_race
order by patient_race;

select * from results_sent_log
where result_source = 'New York NYHL7GeneratorContext'
and order_number = '2716F74';
order by last_update

update asr_process_run
set complete = 'N'
where order_number = '2716F74';

create table ny_race_test
as
select * from  results_sent_log
where order_number = '2716F74';

delete results_sent_log
where order_number = '2716F74';

select * from condition_master
where state_fk IN
(
/

-- regexp_like(order_test_code,'^(301)$')

select sm.state_abbreviation,cm.* from condition_master cm
join state_master sm ON sm.state_master_pk = state_fk 
and regexp_like(state_abbreviation,'^(AL|CA|IL|LA|MD|NC|NJ|NM|NY|MD|PA|TX)$')
where entity_type = 'Abnormal'
and order_test_code = '336'
--and cm.status = 'active'
order by state_abbreviation;

update condition_master
set status = 'active'
where condition_master_pk = 194;

select * from condition_filters
--where condition_filter_pk = 1
where status = 'inactive';
