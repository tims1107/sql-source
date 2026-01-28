select type_id from;

create view vw_ami_label
as
select 'E' table_flag,
f.* from eastequipami_label f
union all 
select 'S' table_flag, f.* from westequipami_label f ;

select * from vw_ami_label;


select * into eastequipami_label_bak from eastequipami_label;
select * into westequipami_label_bak from westequipami_label;

select count(1) from eastequipami_label_bak;
select count(1) from westequipami_label_bak;

drop table eastequipami_label_bak;

select * into from
(select 'E' table_flag,
       CHOOSE(f.type_id, 'label', 'zebra') as type_label,
       f.* 
from eastequipami_label f
union all 
select 'S' table_flag,
       CHOOSE(f.type_id, 'label', 'zebra') as type_label,
       f.* 
from westequipami_label f ) labels
where type_label = 'label';

