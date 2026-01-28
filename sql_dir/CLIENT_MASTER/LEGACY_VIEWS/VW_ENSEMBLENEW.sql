
-- vw_ensemblenew
create view vw_ensemblenew
as
/

UNION
SELECT DISTINCT 
	'1' code, f.facility_num, f.hlab_num, 'S' as "location", ltrim((NVL(facility_pref, '') + ' ' + f.facility_name)) facility_name, NVL(country, '') country, fmc_number, 
	int_ext_study, order_system, type_of_service, account_category, corporate_acronym, NVL(corporate_group_name, '') corporate_group_name, account_status, 
	NVL(primary_account, '') primary_account, NVL(alt_acct_num, '') alt_acct_num, NVL(cid, '') spectra_cid, isnull(korus_cid, '') korus_cid, account_type, 
	korus_upload_date, korus_live_date,
	(SELECT max(date_change) FROM southfacility_change c WHERE c.hlab_num = f.hlab_num) date_change, f.phone, f.phone_comments
FROM southfacility f 
	LEFT JOIN southfacility_change c ON f.hlab_num = c.hlab_num 
	INNER JOIN southadd_info a ON f.hlab_num = a.hlab_num
WHERE account_status IN ('Active', 'In progress', '2 Wk Transient', 'Pre Transfer') 
	--AND account_type IN ('SPECTRA EAST', 'SPECTRA WEST', 'SPECTRA SOUTH', 'STUDY', 'IN-HOUSE SOUTH')
	AND int_ext_study = 'E'
UNION

SELECT DISTINCT 
	'1' code, f.facility_num, f.hlab_num, 'W' as "location", ltrim((isnull(facility_pref, '') + ' ' + f.facility_name)) facility_name, isnull(country, '') country, fmc_number, 
	int_ext_study, order_system, type_of_service, account_category, corporate_acronym, isnull(corporate_group_name, '') corporate_group_name, account_status, 
	ISNULL(primary_account, '') primary_account, isnull(alt_acct_num, '') alt_acct_num, isnull(cid, '') spectra_cid, isnull(korus_cid, '') korus_cid, account_type, 
	korus_upload_date, korus_live_date,
	(SELECT max(date_change) FROM westfacility_change c WHERE c.hlab_num = f.hlab_num) date_change, f.phone, f.phone_comments
FROM westfacility f 
	LEFT JOIN westfacility_change c ON f.hlab_num = c.hlab_num 
	INNER JOIN westadd_info a ON f.hlab_num = a.hlab_num
WHERE account_type IN ('SPECTRA EAST', 'SPECTRA WEST', 'SPECTRA SOUTH', 'STUDY', 'IN-HOUSE WEST') 
	--AND account_status IN ('Active', 'In progress', '2 Wk Transient', 'Pre Transfer') 
	AND int_ext_study = 'I'
UNION
SELECT DISTINCT 
	'1' code, f.facility_num, f.hlab_num, 'W' as "location", ltrim((isnull(facility_pref, '') + ' ' + f.facility_name)) facility_name, NVL(country, '') country, fmc_number, 
	int_ext_study, order_system, type_of_service, account_category, corporate_acronym, NVL(corporate_group_name, '') corporate_group_name, account_status, 
	NVL(primary_account, '') primary_account, NVL(alt_acct_num, '') alt_acct_num, NVL(cid, '') spectra_cid, NVL(korus_cid, '') korus_cid, account_type, 
	korus_upload_date, korus_live_date,
	(SELECT max(date_change) FROM westfacility_change c WHERE c.hlab_num = f.hlab_num) date_change, f.phone, f.phone_comments
FROM westfacility f 
	LEFT JOIN westfacility_change c ON f.hlab_num = c.hlab_num 
	INNER JOIN westadd_info a ON f.hlab_num = a.hlab_num
WHERE account_status IN ('Active', 'In progress', '2 Wk Transient', 'Pre Transfer') 
	--AND account_type IN ('SPECTRA EAST', 'SPECTRA WEST', 'SPECTRA SOUTH', 'STUDY', 'IN-HOUSE WEST')
	AND int_ext_study = 'E'

UNION
SELECT DISTINCT 
	'1' code, f.facility_num, f.hlab_num, 'E' location, ltrim((NVL(facility_pref, '') + ' ' + f.facility_name)) facility_name, NVL(country, '') country, NVL(fmc_number, '') 
	fmc_number, int_ext_study, NVL(order_system, '') order_system, NVL(type_of_service, '') type_of_service, NVL(account_category, '') account_category, 
	NVL(corporate_acronym, '') corporate_acronym, NVL(corporate_group_name, '') corporate_group_name, account_status, NVL(primary_account, '') 
	primary_account, NVL(alt_acct_num, '') alt_acct_num, NVL(cid, '') spectra_cid, NVL(korus_cid, '') korus_cid, account_type, korus_upload_date, korus_live_date,
	(SELECT max(date_change) FROM facility_change c WHERE c.hlab_num = f.hlab_num) date_change, f.phone, f.phone_comments
FROM facility f 
LEFT JOIN facility_change c ON f.hlab_num = c.hlab_num 
	INNER JOIN eastadd_info a ON f.hlab_num = a.hlab_num
WHERE account_type IN ('SPECTRA EAST', 'SPECTRA WEST', 'SPECTRA SOUTH', 'STUDY', 'IN-HOUSE EAST');
	--AND account_status IN ('Active', 'In progress', '2 Wk Transient', 'Pre Transfer') 
  
/

/

SELECT DISTINCT 
	'1' code, f.facility_num, f.hlab_num, 'S' as "location", ltrim((NVL(facility_pref, '') + ' ' + f.facility_name)) facility_name, NVL(country, '') country, fmc_number, 
	int_ext_study, order_system, type_of_service, account_category, corporate_acronym, NVL(corporate_group_name, '') corporate_group_name, account_status, 
	NVL(primary_account, '') primary_account, NVL(alt_acct_num, '') alt_acct_num, NVL(cid, '') spectra_cid, NVL(korus_cid, '') korus_cid, account_type, 
	korus_upload_date, korus_live_date,
	(SELECT max(date_change) FROM southfacility_change c WHERE c.hlab_num = f.hlab_num) date_change, f.phone, f.phone_comments
FROM southfacility f 
	LEFT JOIN southfacility_change c ON f.hlab_num = c.hlab_num 
	INNER JOIN southadd_info a ON f.hlab_num = a.hlab_num
WHERE account_type IN ('SPECTRA EAST', 'SPECTRA WEST', 'SPECTRA SOUTH', 'STUDY', 'IN-HOUSE SOUTH') 
	--AND account_status IN ('Active', 'In progress', '2 Wk Transient', 'Pre Transfer') 
	AND int_ext_study = 'I';
  
  /
  
  "



"


CREATE VIEW [dbo].[vw_PLAC]
AS
SELECT DISTINCT 
    f.hlab_num, f.facility_num, f.facility_name, f.phone, f.fax, f.facility_state, f.zip AS facility_zip, f.order_system, f.account_type, f.type_of_service, f.int_ext_study, 
    f.fmc_number, f.account_category, 'E' AS location, f.account_status, a.clinical_rep, a.cs_rep, a.custom_paging_notes, a.alert_notes alert_call_notes, 
    t .tzname AS time_zone/* a.time_zone */ , b.Bus_Unit, b.Region, m.open_timeMWF, m.open_timeTTHS, m.open_timeSat, m.close_timeMWF, m.close_timeTTHS, 
    m.close_timeSat, m.opensun, m.closesun, h.phone1, h.phone2, h.phone3, h.phone4, h.phone5, h.phone6, h.phone7, h.phone8, h.phone9, h.phone10, h.phone11, 
    h.phone12, h.phone13, h.comments1, h.comments2, h.comments3, h.comments4, h.comments5, h.comments6, h.comments7, h.comments8, h.comments9, 
    h.comments10, h.comments11, h.comments12, h.comments13,a.corporate_acronym,a.corporate_group_name
FROM
	dbo.facility AS f 
	INNER JOIN dbo.eastadd_info AS a ON f.hlab_num = a.hlab_num 
	LEFT OUTER JOIN dbo.more_account_info AS m ON f.hlab_num = m.hlab_num 
	LEFT OUTER JOIN dbo.BusUnitRegionAreaNameNum AS b ON m.bus_unit = b.bus_unit_num AND m.region = b.region_num and m.area=b.area_num
	LEFT OUTER JOIN eastafterhourscontact h ON f.hlab_num = h.hlab_num 
	LEFT OUTER JOIN us_zip_tz t ON substring(f.zip, 1, 5) = t .zip_code
WHERE (LEFT(f.facility_num, 1) <> '?')
UNION
SELECT DISTINCT 
    f.hlab_num, f.facility_num, f.facility_name, f.phone, f.fax, f.facility_state, f.zip AS facility_zip, f.order_system, f.account_type, f.type_of_service, f.int_ext_study, 
    f.fmc_number, f.account_category, 'W' AS location, f.account_status, a.clinical_rep, a.cs_rep, a.custom_paging_notes, a.alert_notes alert_call_notes, 
    t .tzname AS time_zone/* a.time_zone */ , b.Bus_Unit, b.Region, m.open_timeMWF, m.open_timeTTHS, m.open_timeSat, m.close_timeMWF, m.close_timeTTHS, 
    m.close_timeSat, m.opensun, m.closesun, h.phone1, h.phone2, h.phone3, h.phone4, h.phone5, h.phone6, h.phone7, h.phone8, h.phone9, h.phone10, h.phone11, 
    h.phone12, h.phone13, h.comments1, h.comments2, h.comments3, h.comments4, h.comments5, h.comments6, h.comments7, h.comments8, h.comments9, 
    h.comments10, h.comments11, h.comments12, h.comments13,a.corporate_acronym,a.corporate_group_name
FROM 
	dbo.westfacility AS f 
	INNER JOIN dbo.westadd_info AS a ON f.hlab_num = a.hlab_num 
	LEFT OUTER JOIN dbo.westmore_account_info AS m ON f.hlab_num = m.hlab_num 
	LEFT OUTER JOIN dbo.BusUnitRegionAreaNameNum AS b ON m.bus_unit = b.bus_unit_num AND m.region = b.region_num and m.area=b.area_num
	LEFT OUTER JOIN westafterhourscontact h ON f.hlab_num = h.hlab_num 
	LEFT OUTER JOIN us_zip_tz t ON substring(f.zip, 1, 5) = t .zip_code
WHERE (LEFT(f.facility_num, 1) <> '?')
UNION
SELECT DISTINCT 
    f.hlab_num, f.facility_num, f.facility_name, f.phone, f.fax, f.facility_state, f.zip AS facility_zip, f.order_system, f.account_type, f.type_of_service, f.int_ext_study, 
    f.fmc_number, f.account_category, 'S' AS location, f.account_status, a.clinical_rep, a.cs_rep, a.custom_paging_notes, a.alert_notes alert_call_notes, 
    t .tzname AS time_zone/* a.time_zone */ , b.Bus_Unit, b.Region, m.open_timeMWF, m.open_timeTTHS, m.open_timeSat, m.close_timeMWF, m.close_timeTTHS, 
    m.close_timeSat, m.opensun, m.closesun, h.phone1, h.phone2, h.phone3, h.phone4, h.phone5, h.phone6, h.phone7, h.phone8, h.phone9, h.phone10, h.phone11, 
    h.phone12, h.phone13, h.comments1, h.comments2, h.comments3, h.comments4, h.comments5, h.comments6, h.comments7, h.comments8, h.comments9, 
    h.comments10, h.comments11, h.comments12, h.comments13,a.corporate_acronym,a.corporate_group_name
FROM dbo.southfacility AS f 
	INNER JOIN dbo.southadd_info AS a ON f.hlab_num = a.hlab_num 
	LEFT OUTER JOIN dbo.westmore_account_info AS m ON f.hlab_num = m.hlab_num 
	LEFT OUTER JOIN dbo.BusUnitRegionAreaNameNum AS b ON m.bus_unit = b.bus_unit_num AND m.region = b.region_num and m.area=b.area_num
	LEFT OUTER JOIN westafterhourscontact h ON f.hlab_num = h.hlab_num 
	LEFT OUTER JOIN us_zip_tz t ON substring(f.zip, 1, 5) = t .zip_code
WHERE     (LEFT(f.facility_num, 1) <> '?')
"

/

select * from cm_change_queue
order by cmpostdate desc;

select * from clinic_change_history
order by effdate;

select * from vw_upd_addinfo
where clinicid = 200405;

select * from gen_audit
where tab = 'CLINIC'
and col = 'HLABNUMBER'
where pk = 200405;

