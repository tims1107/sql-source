select * from westmore_account_info
where hlab_num = 'A108114';

update more_account_info
set open_timemwf = null, open_timetths = null
,close_timeMWF = null, close_timeTTHS = null,opensun = null,pickupmwf= null
where hlab_num = 'B153880';