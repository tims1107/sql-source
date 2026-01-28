
select * from distributor_items_map;

select d.* from distributor d 
join distributor_items i ON i.distributor_fk = d.distributor_pk
join distributor_items_map m ON m.distributor_fk = d.distributor_pk
--where distribution_type = 'samba';

where state_fk IN
(select state_master_pk from state_master
where state_abbreviation = 'IL');

update distributor_items
set distributor_item_value='\\njnas01\CommonFS\JohnShen\test\asr\spectraHLAB_External_Interface_Results\IL\prod\'
where distributor_item_pk = 63;

select * from condition_master
where order_test_code IN ('318')
and state_fk IN
(select state_master_pk from state_master
where state_abbreviation = 'IL');

select * from condition_filters;

select f.* from generator g
join generator_fields f ON f.generator_fk = g.generator_pk
where state_fk IN
(select state_master_pk from state_master
where state_abbreviation = 'IL');

select * from results_sent_log
order by last_update_time desc;