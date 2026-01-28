select hlab_num,primary_account,account_status,type_of_service,account_category from facility
where hlab_num IN ('A103458');

select * from customer_num
where customer_num = 'C061210';

select * from 
(select 'E' tableflag, f.* from facility_change f
union all 
select 'S' tableflag, f.* from southfacility_change f
union all
select 'W' tableflag, f.* from westfacility_change f) t1
where primary_account = 'A118608';

select type_of_service,account_status,count(1) from 
(select 'W' tableflag, f.primary_account,f.hlab_num,f.facility_name,f.type_of_service,f.account_status from westfacility f
union all
select 'E' tableflag, f.primary_account,f.hlab_num,f.facility_name,f.type_of_service,f.account_status from facility f
union all
select 'S' tableflag, f.primary_account,f.hlab_num,f.facility_name,f.type_of_service,f.account_status from southfacility f) t1
--where account_status IN ('Active','In progress','Inactive #')
where tableflag IN ('E')
--and hlab_num like 'A1%'
and account_status IN ('Active')
group by type_of_service,account_status
order by type_of_service;

select count(1) from 
(select 'W' tableflag, f.primary_account,f.hlab_num,f.facility_name,f.type_of_service,f.account_status from westfacility f
union all
select 'E' tableflag, f.primary_account,f.hlab_num,f.facility_name,f.type_of_service,f.account_status from facility f
union all
select 'S' tableflag, f.primary_account,f.hlab_num,f.facility_name,f.type_of_service,f.account_status from southfacility f) t1
where account_status not IN ('Transferred');

select count(1) from facility
where account_status = 'Active'
and len(type_of_service) = 0;

select account_status,type_of_service,count(1) from vw_ensemblenew
where account_status IN( 'Active','In progress')
and location = 'E'
group by account_status,type_of_service
order by type_of_service;

--and account_status not in ('Transferred');
--where tableflag = 'W' and account_status = 'Active';
where primary_account IN
('A120581'
);

select * from 
(select 'W' tableflag, f.primary_account,f.hlab_num,f.facility_name,f.type_of_service,f.account_status from westfacility f
union all
select 'E' tableflag, f.primary_account,f.hlab_num,f.facility_name,f.type_of_service,f.account_status from facility f
union all
select 'S' tableflag, f.primary_account,f.hlab_num,f.facility_name,f.type_of_service,f.account_status from southfacility f) t1
--where account_status IN ('Active','In progress','Inactive #')
where tableflag IN ('S','E')
and hlab_num like 'A1%'
and len(type_of_service) = 0
--order by type_of_service
and account_status in ('Active');
--where tableflag = 'W' and account_status = 'Active';
where primary_account IN
('A120581'
);

select * from southadd_info
where hlab_num = 'A200636';

select clinical_rep,count(1) from
(select 'E' tableflag, f.* from eastadd_info f
union all
select 'S' tableflag, f.* from southadd_info f) t1
group by clinical_rep;


select * from southfacility
where hlab_num = 'A200636';

select * from clinicalsupport
where clinical_support = 'PIA BUSTOS';



or hlab_num = 'A120581';

('A102774','A102779','A102825','A103001','A103027','A103028','A103035','A103069','A103070','A103081','A103105','A103106','A103119','A103260','A103413','A103414'

);



select * from customer_num
where customer_num = 'C072883';

A101176

select * from facility_transfer
where hlab_num IN
(
'A106259'
,'A118608'
,'A118609'
,'A118610'
,'A123137'
,'A123138'
,'A123136'
,'A101176'
,'A125505'
,'A125506'
,'A125507'
,'A121778'
);



use cdbhlab;

select * from facility
where hlab_num = 'A200639';