select i.* from distributor d 
join distributor_items i ON i.distributor_fk = d.distributor_pk
join distributor_items_map m ON m.distributor_fk = d.distributor_pk
and state_fk IN
(select state_master_pk from state_master
where state_abbreviation = 'CA');

select i.* from generator g 
join generator_fields i ON i.generator_fk = g.generator_pk

and state_fk IN
(select state_master_pk from state_master
where state_abbreviation = 'CA');