"CREATE PROCEDURE [dbo].[cm_updateHoursOfOperation]
@zone varchar(2), @hlabnum varchar(7),@opensun varchar(21),@closesun varchar(21),@open_timeMWF varchar(21),@close_timeMWF varchar(21),@pickupMWF varchar(21),
@open_timeTTHS varchar(21),@close_timeTTHS varchar(21),@pickupTTH varchar(21),@open_timeSat varchar(21),@close_timeSat varchar(21),@pickupSat varchar(21)

AS



if (@zone = 'E')
  
begin
  update more_account_info
  set open_timeMWF = convert(datetime,@open_timeMWF ),open_timeTTHS = convert(datetime,@open_timeTTHS),opensun = convert(datetime,@opensun),pickupMWF = convert(datetime,@pickupMWF),
  close_timeMWF = convert(datetime,@close_timeMWF),close_timeTTHS = convert(datetime,@close_timeTTHS),closesun = convert(datetime,@closesun),pickupTTH=convert(datetime,@pickupTTH)
  ,open_timeSat = convert(datetime,@open_timeSat),close_timeSat = convert(datetime,@close_timeSat),pickupSat = convert(datetime,@pickupSat)
  where hlab_num = @hlabnum
end
else if (@zone = 'W')
begin
  update westmore_account_info
  set open_timeMWF = convert(datetime,@open_timeMWF ),open_timeTTHS = convert(datetime,@open_timeTTHS),opensun = convert(datetime,@opensun),pickupMWF = convert(datetime,@pickupMWF),
  close_timeMWF = convert(datetime,@close_timeMWF),close_timeTTHS = convert(datetime,@close_timeTTHS),closesun = convert(datetime,@closesun),pickupTTH=convert(datetime,@pickupTTH)
  ,open_timeSat = convert(datetime,@open_timeSat),close_timeSat = convert(datetime,@close_timeSat),pickupSat = convert(datetime,@pickupSat)
  where hlab_num = @hlabnum

end
else if (@zone = 'S')
begin
  update westmore_account_info
  set open_timeMWF = convert(datetime,@open_timeMWF ),open_timeTTHS = convert(datetime,@open_timeTTHS),opensun = convert(datetime,@opensun),pickupMWF = convert(datetime,@pickupMWF),
  close_timeMWF = convert(datetime,@close_timeMWF),close_timeTTHS = convert(datetime,@close_timeTTHS),closesun = convert(datetime,@closesun),pickupTTH=convert(datetime,@pickupTTH)
  ,open_timeSat = convert(datetime,@open_timeSat),close_timeSat = convert(datetime,@close_timeSat),pickupSat = convert(datetime,@pickupSat)
  where hlab_num = @hlabnum


end"

/

select 
hlab_num hlabnumber
,coalesce(convert(varchar(19),open_timeMWF,120),'1900-01-01 00:00:00') opentimemwf 
,coalesce(convert(varchar(19),open_timeTTHS,120),'1900-01-01 00:00:00') opentimetths 
,coalesce(convert(varchar(19),opensun,120),'1900-01-01 00:00:00')opensun
,coalesce(convert(varchar(19),pickupMWF,120),'1900-01-01 00:00:00')pickupMWF
,coalesce(convert(varchar(19),close_timeMWF,120),'1900-01-01 00:00:00') closetimemwf
,coalesce(convert(varchar(19),close_timeTTHS,120),'1900-01-01 00:00:00') closetimetths 
,coalesce(convert(varchar(19),closesun,120),'1900-01-01 00:00:00') closesun
,coalesce(convert(varchar(19),pickupTTH,120),'1900-01-01 00:00:00')pickupTTH 
,coalesce(convert(varchar(19),open_timeSat,120),'1900-01-01 00:00:00') opentimesat 
,coalesce(convert(varchar(19),close_timeSat,120),'1900-01-01 00:00:00') closetimesat
,coalesce(convert(varchar(19),pickupSat,120),'1900-01-01 00:00:00')pickupSat 
from more_account_info
  where hlab_num = 'B153880';
  
  select *
  from more_account_info
  where hlab_num = 'B153880';

