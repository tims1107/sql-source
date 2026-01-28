create table CLINIC_OPEN_CLOSE
(tableflag varchar2(1)
,hlabnumber varchar2(7)
,accountnumber varchar2(8)
,opentimemwf timestamp(6)
,closetimemwf timestamp(6)
,opentimetths timestamp(6)
,closetimetths timestamp(6)
,opentimesat timestamp(6)
,closetimesat timestamp(6)
,opensun timestamp(6)
,closesun timestamp(6)
,pickupMWF timestamp(6)
,pickuptth timestamp(6)
,pickupsat timestamp(6));

drop table clinic_open_close;
