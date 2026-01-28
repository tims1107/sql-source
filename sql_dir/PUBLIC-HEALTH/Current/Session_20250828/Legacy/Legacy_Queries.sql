select * from
(select 'S' tableflag, f.* from southfacility f
union all
select 'E' tableflag, f.* from facility f
union all
select 'W' tableflag, f.* from westfacility f) as t1;

select 'E' tableflag, f.* from facility f
where hlab_num = 'A101186';

select * from 
(select 'E' tableflag, f.* from facility_change f
union all
select 'S' tableflag ,f.* from southfacility_change f) t1
where hlab_num = 'A101186'
order by date_change desc;

select * from vw_ensemblenew
where hlab_num = 'A101186';

select * from facility_transfer
where hlab_num = 'A101186';