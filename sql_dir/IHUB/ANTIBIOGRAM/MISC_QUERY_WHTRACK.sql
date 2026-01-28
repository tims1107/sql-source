select * from MICRO_ISOLATE_EXTRACT
where requisition_id = '00891P4';

select * from MICRO_ISOLATE_ORGANISM
where requisition_id = '00891P4';

select count(1) from
(select requisition_id from MICRO_ISOLATE_EXTRACT
group by requisition_id);

select count(1) from MICRO_ISOLATE_ORGANISM o
join 
(select requisition_id from MICRO_ISOLATE_EXTRACT
group by requisition_id) e ON e.requisition_id = o.REQUISITION_ID;

select * from MICRO_ISOLATE_ORGANISM o
join 
(select requisition_id from MICRO_ISOLATE_EXTRACT
group by requisition_id) e ON e.requisition_id = o.REQUISITION_ID
where regexp_like(organism_name,'Can','i');
