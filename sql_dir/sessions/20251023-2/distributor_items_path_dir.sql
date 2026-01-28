select * from generator
where state_fk IN
(select state_master_pk from state_master
where state_abbreviation = 'NY');

select * from generator_fields
where generator_fk = 24;

select * from distributor
where state_fk IN
(select state_master_pk from state_master
where state_abbreviation = 'IL');

select * from distributor_items
where distributor_fk = 2;

-- \\njnas01\CommonFS\JohnShen\test\asr\spectraHLAB_External_Interface_Results\IL\prod\
update distributor_items
set distributor_item_value = '\\njnas01\CommonFS\JohnShen\test\asr\spectraHLAB_External_Interface_Results\IL\il_doh\'
where distributor_item_pk = 63;

select * from condition_master
where state_fk IN
(select state_master_pk from state_master
where state_abbreviation = 'IL')
and order_test_code = '311';

select * from condition_filters;

update condition_master
set result_test_code = '311R'
where condition_master_pk = 193;