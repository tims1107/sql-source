select i.* from distributor d
join distributor_items i ON i.distributor_fk = d.distributor_pk
where d.state_fk IN
(select state_master_pk from state_master
where state_abbreviation = 'PA');

select * from distributor_items_map;

-- //njnas01/CommonFS/JohnShen/test/asr/spectraHLAB_External_Interface_Results/PA/prod/
update distributor_items
set distributor_item_value = 'c:/ph-test/'
where distributor_item_pk = 99;