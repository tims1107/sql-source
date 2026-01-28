select * from
(select 'A' pri,facility_name,w.primary_account primaryaccount,hlab_num,type_of_service,account_status from westfacility w
where primary_account is not null  
union all 
select 'P' pri,facility_name,w.hlab_num primaryaccount,hlab_num,type_of_service,account_status from westfacility w
where primary_account is null) t1
where primaryaccount = hlab_num
and type_of_service = 'ASSOCIATE'
and account_status; 

select * from westfacility
--where primary_account is null
where primary_account = 'A105190';

select * from
(select 'E' tableflag, f.* from eastequiphlab_report f
where hlab_num = 'A123099'
union all
select 'S' tableflag, f.* from westequiphlab_report f
where hlab_num = 'A123099') t1
;


select tableflag,hlab_num hlabnumber,facility_num accountnumber,open_timeMWF opentimemwf,close_timeMWF closetimemwf
,open_timetths opentimetths,close_timetths closetimetths
,open_timeSat opentimesat,close_timesat closetimesat
,opensun,closesun,pickupmwf,pickuptth,pickupsat
from
(select 'E' tableflag, f.* from more_account_info f
union all 
select 'S' tableflag,f.* from westmore_account_info f
union all 
select 'W' tableflag,f.* from westmore_account_info f) t1
where hlab_num IN ('A119605','A112960','A111764','A112587')
;

/

update eastadd_info
    set kits = @kits,custom = @custom,
      custom_month = @custom_month,custom_mid = @custom_mid,generic = @generic,generic_month = @generic_month,
      generic_mid = @generic_mid
    where hlab_num = @hlabnum
    
update eastadd_info
    set kits = @kits,
      custom = @custom,
      custom_month = decode(@custom,false,false,@custom_month),
      custom_mid = decode(@custom,false,false,@custom_mid),
      generic = @generic,
      generic_month = decode(@generic,false,false,@generic_month),
      generic_mid = decode(@generic,false,false,@generic_mid)
    where hlab_num = @hlabnum;
    
update eastadd_info
    set kits = @kits,
      custom = @custom,
      custom_month = IIF(@custom=0,0,@custom_month),
      custom_mid = IIF(@custom=0,0,@custom_mid),
      generic = @generic,
      generic_month = IIF(@generic=0,0,@generic_month),
      generic_mid = IIF(@generic=0,0,@generic_mid)
    where hlab_num = @hlabnum;

select IIF('Y'='Y','Yes',IIF('Y'= 'N','No','Unknown')) as result;

select IIF(1=0,0,1);

select * from facility
where hlab_num = 'A126418';

select * from southadd_info
where hlab_num = 'A126418';



        
    
   
