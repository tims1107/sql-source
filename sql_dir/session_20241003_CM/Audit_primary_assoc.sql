select 
fac.tableflag,
fac.HLAB_NUM,
fac.FACILITY_NUM,
fac.FACILITY_PREF,
fac.FACILITY_NAME,
fac.FMC_NUMBER,
fac.E_W_FLAG,
fac.INT_EXT_STUDY,
fac.CID,
fac.TLA,
fac.ADDRESS1,
fac.ADDRESS2,
fac.CITY,
fac.FACILITY_STATE,
fac.ZIP,
fac.COUNTRY,
fac.COUNTRY_CODE,
fac.PHONE,
fac.FAX,
fac.PHONE_COMMENTS,
fac.ACCOUNT_STATUS,
fac.ACCOUNT_TYPE,
fac.ACCOUNT_CATEGORY,
fac.TYPE_OF_SERVICE,
fac.PRIMARY_ACCOUNT,
fac.PRIMARY_NAME,
fac.PRIORITY_CALL,
fac.ORDER_SYSTEM,
fac.AMI_DATABASE,
fac.AMI_MARKET,
fac.PATIENT_REPORT,
fac.PATIENT_COUNT,
fac.HEMO_COUNT,
fac.PD_COUNT,
fac.COUR_ACCOUNT,
fac.COURIER_AREA,
fac.SPECIMEN_DEL,
fac.COMMENTS,
fac.COUR_SHIP_NUM,
fac.KORUS_CID,
fac.HH_COUNT,
fac.ALT_ACCT_NUM,
fac.COUR_SERVICE,
fac.ETA,
addinfo.SALES_REP,
addinfo.CLINICAL_REP,
addinfo.CS_REP,
addinfo.SALES_TER,
addinfo.CORPORATE_ACRONYM,
addinfo.CORPORATE_GROUP_NAME,
addinfo.FMC_RELATIONSHIP,
addinfo.FIRST_DATE,
addinfo.DISCONT_DATE,
addinfo.COMMENTS_REASON,
addinfo.COMMENTS_LOSTTO,
addinfo.STAR_REPORT,
addinfo.CQI_REPORT,
addinfo.PHYS_ADD1,
addinfo.PHYS_ADD2,
addinfo.PHYS_CITY,
addinfo.PHYS_STATE,
addinfo.PHYS_ZIP,
addinfo.PHYS_COUNTRY,
addinfo.PHYS_COUNTRY_CODE,
addinfo.ALERT_NOTES,
addinfo.KIT_COMMENTS,
addinfo.CUSTOM_PAGING_NOTES,
moreinfo.med_dir,
moreinfo.clinic_mgr

from
(select 'E'tableflag , f.* from facility f
union all
select 'S'tableflag , f.* from southfacility f
union all
select 'W'tableflag , f.* from westfacility f) fac
join
(select 'E'tableflag , f.* from eastadd_info f
union all
select 'S'tableflag , f.* from southadd_info f
union all
select 'W' tableflag , f.* from westadd_info f) 
addinfo ON addinfo.hlab_num = fac.hlab_num and addinfo.tableflag = fac.tableflag
join
(select 'E'tableflag , f.* from more_account_info f
union all
select 'S'tableflag , f.* from westmore_account_info f
union all
select 'W' tableflag , f.* from westmore_account_info f) moreinfo
ON moreinfo.hlab_num = fac.hlab_num and moreinfo.tableflag = fac.tableflag