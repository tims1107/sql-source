-- PROCEDURES
-- get sql server procedure objects

select name,object_definition(object_id),p.*
from sys.procedures p
where name like 'cm%'
order by modify_date desc;

select name,object_definition(object_id),p.*
from sys.views p
where name like 'vw_p%'
order by create_date desc;

select hlab_num,custom_paging_notes,alert_call_notes from vw_plac
where hlab_num = 'A101789';

select * from sys.procedures;

use cdbhlab;

select t.* from sys.all_objects o
join sys.procedures t ON t.object_id = o.object_id
where o.type = 'U'
and o.name like 'cm%';

select name,create_date,modify_date
from sys.procedures p
where name like 'cm%'
order by create_date desc;

use cdbhlab;

use sts;

-- TABLES
-- get sql server table information
SELECT so.name,sc.name column_name, st.name + '(' + cast(sc.max_length as varchar) + ')' var_type,st.is_nullable
FROM sys.all_objects so
JOIN sys.columns sc ON sc.object_id = so.object_id
join sys.types st ON st.user_type_id = sc.user_type_id
where sc.name like 'cs_rep%';
--where so.name like 'facility'
and type = 'U';

select hlab_num,korus_live_date, len(korus_live_date) from eastadd_info
order by 2 desc;

select clinical_rep,sales_rep,cs_rep,count(*) over (partition by null) from eastadd_info
--where hlab_num = 'A111660'
where len(cs_rep) > 0
and cs_rep not like 'NONE';

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


select hlab_num hlabnumber,facility_num accountnumber
,alert_printer alerprinter
,alert_fax alertfax 
,plac_reportable placreportable 
,create_ts createts
,create_user createuser
,update_ts updatets
,update_user updateuser
from plac_printers;
where plac_reportable = 'Y'
order by update_ts desc;

SELECT *
FROM sys.all_objects so
where type = 'U'
order by name;
--group by type,type_desc
JOIN sys.columns sc ON sc.object_id = so.object_id
join sys.types st ON st.user_type_id = sc.user_type_id

select sa.*from southfacility s
join southadd_info sa ON sa.hlab_num = s.hlab_num
where s.hlab_num = 'A119929';

use cdbhlab;
use sts;

select * from facility
where hlab_num = 'A119929';

select * from eastadd_info
where hlab_num = 'A115019';

-- VIEWS
-- get sql server view information.

select name,object_definition(object_id),p.*
from sys.views p
where name like 'v%'
order by create_date desc;

--***************************************************

select * from southfacility
where hlab_num = 'A101372';

select * from
(select hlab_num,'eastadd_info' lab,alert_notes from eastadd_info a
union all
select hlab_num,'southadd_info' lab,alert_notes from southadd_info a) t1
where hlab_num = 'A101372';

select * from
(select hlab_num,'eastadd_info' lab,comments from facility a
union all
select hlab_num,'southadd_info' lab,comments from southfacility a) t1
where hlab_num = 'A101372';

select * from southfacility_change
where hlab_num = 'A101372';

/


select name,create_date,modify_date
from sys.tables p
where name like 'cm_%'
order by create_date desc;



select * from sys.tables
where name like 'cl%'
order by name;

/
"CREATE PROCEDURE [dbo].[cm_AddNewFacility]
@FacilityNumber varchar(8), @zone varchar(2), @FacilityPref varchar(8), @Facilityname varchar(50), @Phone varchar(20), @Fax varchar(20),
@PatientCount int, @Address1 varchar(100), @Address2 varchar(100), @City varchar(30), @State varchar(2), @Zip varchar(10),
@Country varchar(20), @CountryCode varchar(15), @TLA varchar(3), @EW char(1), @IntExtS char(1), @PhoneComments varchar(400),
@AccountType varchar(15), @PrimaryAcc varchar(7), @PrimaryName varchar(50), @CourAccount bit, @CourierArea varchar(30), 
@SpecDel varchar(20), @PriorityCall bit, @Hemo int, @PD int, @TypeServ varchar(15), @AccStatus varchar(15), @OrderSystem varchar(50),
@comments varchar(4000), @AMIDatabase varchar(50), @AMIMarket varchar(30), @PatientReport varchar(40), @AccCategory varchar(30),
@FMCNumber varchar(8), @CID varchar(3), @HlabNum varchar(7) out, @User varchar(15), @courshipnum varchar(12), @koruscid varchar(3), @homehemo int,
@altacctnum varchar(10),@courservice bit, @eta varchar(8),@email varchar(75),@customernum varchar(9),@isPrimary varchar(1)
 AS
 declare @emailname varchar(50)
 declare @emailtitle varchar(50)
 declare @modcount int
     
  
declare @ewfacility varchar(6)
--declare @hlnum varchar(7)
set @ewfacility = (select substring(@FacilityNumber,2,7))
--set @ewfacility=(@ewfacility + 1)
set @HlabNum = ('B' + @ewfacility)	--changed for A to B 11/13/2014
set @modcount = (@hemo + @pd + @homehemo)

set @emailname = 'Name'
set @emailtitle = 'Title'


if (@zone = 'E')
begin
insert into hlabfacility(hlab_num, facility_num, zone, ew_number) values(@hlabnum, @hlabnum,'E', @ewfacility) --change @facilitynumber to @hlabnum 9/16/2014

insert into facility(hlab_num, facility_num, facility_pref, facility_name, fmc_number, e_w_flag, int_ext_study, cid,  tla,  address1,address2, city, facility_state,
zip,country, country_code,phone, fax, phone_comments, account_status, account_type, account_category,type_of_service, primary_account,
primary_name,priority_call, order_system, ami_database,ami_market,patient_report,patient_count, hemo_count, pd_count, cour_account, courier_area,
specimen_del,comments, cour_ship_num, korus_cid, hh_count, alt_acct_num, cour_service, eta) values
(@HlabNum,@HlabNum,@FacilityPref, rtrim(@Facilityname), @FMCNumber,@EW,@IntExtS, @CID,@TLA, --change @facilitynumber to @hlabnum 9/16/2014
@Address1,@Address2, @City, @State, @Zip,@Country, @CountryCode, @Phone, @Fax, @PhoneComments, @AccStatus, 
@AccountType,@AccCategory, @TypeServ, upper(@PrimaryAcc), @PrimaryName,@PriorityCall,   @OrderSystem,  @AMIDatabase, @AMIMarket,
@PatientReport,  @modcount,  @Hemo , @PD, @CourAccount, @CourierArea, @SpecDel, @comments, @courshipnum, @koruscid, @homehemo, @altacctnum, @courservice,@eta)   

insert into facility_change(facility_num, facility_name, who_change, date_change, comments,hlab_num) values(@hlabnum, rtrim(@facilityname), 
@user, getdate(), 'Added',@hlabnum)
select @HlabNum

if(@isPrimary = 'Y')
begin
 insert into customer_num(customer_num,cust_hlab_num,e_w) values (@customernum,@customernum,null)
end

insert into customer_num(customer_num,cust_hlab_num,e_w) values (@customernum,@hlabnum,@zone)
insert eastemail (hlab_num,name,title,email) values (@hlabnum,@emailname,@emailtitle,@email)

end
else if (@zone = 'W')
begin
insert into hlabfacility(hlab_num, facility_num, zone, ew_number) values(@hlabnum, @hlabnum,'E', @ewfacility) --change @facilitynumber to @hlabnum 9/16/2014

insert into westfacility(hlab_num, facility_num, facility_pref, facility_name, fmc_number, e_w_flag, int_ext_study, cid,  tla,  address1,address2, city, facility_state,
zip,country, country_code,phone, fax, phone_comments, account_status, account_type, account_category,type_of_service, primary_account,
primary_name,priority_call, order_system, ami_database,ami_market,patient_report,patient_count, hemo_count, pd_count, cour_account, courier_area,
specimen_del,comments, cour_ship_num, korus_cid, hh_count, alt_acct_num, cour_service, eta) values(@HlabNum,@HlabNum,@FacilityPref, rtrim(@Facilityname), @FMCNumber,@EW,@IntExtS, @CID,@TLA, --change @facilitynumber to @hlabnum 9/16/2014
@Address1,@Address2, @City, @State, @Zip,@Country, @CountryCode, @Phone, @Fax, @PhoneComments, @AccStatus, 
@AccountType,@AccCategory, @TypeServ, upper(@PrimaryAcc), @PrimaryName,@PriorityCall,   @OrderSystem,  @AMIDatabase, @AMIMarket,
@PatientReport,  @PatientCount,  @Hemo , @PD, @CourAccount, @CourierArea, @SpecDel, @comments, @courshipnum, @koruscid, @homehemo, @altacctnum, @courservice,@eta)   

insert into facility_change(facility_num, facility_name, who_change, date_change, comments,hlab_num) values(@hlabnum, rtrim(@facilityname), 
@user, getdate(), 'Added',@hlabnum)
select @HlabNum

if(@isPrimary = 'Y')
begin
 insert into customer_num(customer_num,cust_hlab_num,e_w) values (@customernum,@customernum,null)
end

insert into customer_num(customer_num,cust_hlab_num,e_w) values (@customernum,@hlabnum,@zone)
insert eastemail (hlab_num,name,title,email) values (@hlabnum,@emailname,@emailtitle,@email)

end
else if (@zone = 'S')
begin
insert into hlabfacility(hlab_num, facility_num, zone, ew_number) values(@hlabnum, @hlabnum,'E', @ewfacility) --change @facilitynumber to @hlabnum 9/16/2014

insert into southfacility(hlab_num, facility_num, facility_pref, facility_name, fmc_number, e_w_flag, int_ext_study, cid,  tla,  address1,address2, city, facility_state,
zip,country, country_code,phone, fax, phone_comments, account_status, account_type, account_category,type_of_service, primary_account,
primary_name,priority_call, order_system, ami_database,ami_market,patient_report,patient_count, hemo_count, pd_count, cour_account, courier_area,
specimen_del,comments, cour_ship_num, korus_cid, hh_count, alt_acct_num, cour_service, eta) values
(@HlabNum,@HlabNum,@FacilityPref, rtrim(@Facilityname), @FMCNumber,@EW,@IntExtS, @CID,@TLA, --change @facilitynumber to @hlabnum 9/16/2014
@Address1,@Address2, @City, @State, @Zip,@Country, @CountryCode, @Phone, @Fax, @PhoneComments, @AccStatus, 
@AccountType,@AccCategory, @TypeServ, upper(@PrimaryAcc), @PrimaryName,@PriorityCall,   @OrderSystem,  @AMIDatabase, @AMIMarket,
@PatientReport,  @modcount,  @Hemo , @PD, @CourAccount, @CourierArea, @SpecDel, @comments, @courshipnum, @koruscid, @homehemo, @altacctnum, @courservice,@eta)   

insert into facility_change(facility_num, facility_name, who_change, date_change, comments,hlab_num) values(@hlabnum, rtrim(@facilityname), 
@user, getdate(), 'Added',@hlabnum)
select @HlabNum

if(@isPrimary = 'Y')
begin
 insert into customer_num(customer_num,cust_hlab_num,e_w) values (@customernum,@customernum,null)
end

insert into customer_num(customer_num,cust_hlab_num,e_w) values (@customernum,@hlabnum,@zone)
insert eastemail (hlab_num,name,title,email) values (@hlabnum,@emailname,@emailtitle,@email)

end"
/
"CREATE PROCEDURE [dbo].[cm_AddInfo]
@facilitynumber varchar(8), @zone varchar(2),@hlabnum varchar(7),  @add1 varchar(100),@add2 varchar(100),@city varchar(30), 
@state varchar(2),@zip varchar(15), @country varchar(20), @countrycode varchar(15), @supplydepot varchar(20), @autosap bit, 
@corp_acronym varchar(20),@corporate_group_name varchar(50),@sales_rep varchar(20),@clinical_rep varchar(20),@fmcrelationship varchar(50),@med_dir varchar(400),
@clinic_mgr varchar(400),@admin varchar(40)
 AS
	if (@zone='E')
	BEGIN
  
		insert into eastadd_info(facility_num, phys_add1, phys_add2, phys_city, phys_state, phys_zip, phys_country, phys_country_code,
		supply_depot, auto_sap, hlab_num,corporate_acronym,corporate_group_name,sales_rep,clinical_rep,fmc_relationship) 
    values(@facilitynumber, @add1,@add2,@city,@state,@zip, @country, @countrycode,
		@supplydepot, @autosap, @hlabnum,isnull(nullif(@corp_acronym,''),''),isnull(nullif(@corporate_group_name,''),''),@sales_rep,@clinical_rep,@fmcrelationship)
		--insert into more_account_info
		insert into more_account_info(facility_num, hlab_num,med_dir,clinic_mgr,admin) values(@facilitynumber, @hlabnum,@med_dir,@clinic_mgr,@admin)
		--insert into equipment
		insert into equipment(facility_num, hlab_num) values(@facilitynumber, @hlabnum)
		--insert into equip_detail
		insert into equip_detail(facility_num, hlab_num) values(@facilitynumber, @hlabnum)
		--insert into phone_lineInfo
		insert into eastphone_line_info(facility_num, hlab_num) values(@facilitynumber, @hlabnum) 
		--insert into ref_lab_info
		--insert into ref_lab_info(facility_num, hlab_num) values(@facilitynumber, @hlabnum)    --insert from reflab app
		--insert into more_countact_info
		insert into more_contact_info(facility_num, hlab_num) values(@facilitynumber, @hlabnum)
		--insert into bill info
		insert into eastbill_info(hlab_num, facility_num, add1, add2, city, state, zip, country,country_code) values(@hlabnum, @facilitynumber,
		@add1, @add2, @city, @state, @zip,@country, @countrycode)
		-- add study info
		declare @accounttype varchar(16)
		set @accounttype = (select account_type from facility where facility_num = @facilitynumber)
		if (@accounttype = 'STUDY')
			insert into eaststudyinfo(facility_num, hlab_num, study_add1, study_add2, study_city, study_state, study_zip, study_country, 
			study_country_code) values(@facilitynumber, @hlabnum,  @add1,@add2,@city,@state,@zip, @country, @countrycode)
		--insert into eastequipreportlabel_comments
		insert into eastequipreportlabel_comments(hlab_num, facility_num) values(@hlabnum, @facilitynumber)
		--insert ibto customizations tables
    insert into eastafterhourscontact (facility_num,hlab_num) values (@facilitynumber,@hlabnum)
		insert into easthard_copy(hlab_num) values(@hlabnum)
		insert into eastalert_exception(hlab_num) values(@hlabnum)
		insert into eastcopyto(hlab_num) values(@hlabnum)
		insert into eastspecial_instructions(hlab_num) values(@hlabnum)
	END
	
	ELSE IF (@zone='S')
	BEGIN 
		insert into southadd_info(facility_num, phys_add1, phys_add2, phys_city, phys_state, phys_zip, phys_country, phys_country_code,
		supply_depot, auto_sap, hlab_num,corporate_acronym,corporate_group_name,sales_rep,clinical_rep,fmc_relationship) 
    values(@facilitynumber, @add1,@add2,@city,@state,@zip, @country, @countrycode,
		@supplydepot, @autosap, @hlabnum,isnull(nullif(@corp_acronym,''),''),isnull(nullif(@corporate_group_name,''),''),@sales_rep,@clinical_rep,@fmcrelationship)
		--insert into more_account_info
		insert into westmore_account_info(facility_num, hlab_num,med_dir,clinic_mgr,admin) values(@facilitynumber, @hlabnum,@med_dir,@clinic_mgr,@admin)

		--insert into equipment
		insert into westequipment(facility_num, hlab_num) values(@facilitynumber, @hlabnum)
		--insert into equip_detail
		insert into westequip_detail(facility_num, hlab_num) values(@facilitynumber, @hlabnum)
		--insert into phone_lineInfo
		insert into westphone_line_info(facility_num, hlab_num) values(@facilitynumber, @hlabnum) 
		--insert into ref_lab_info
		--insert into westref_lab_info(facility_num, hlab_num) values(@facilitynumber, @hlabnum)		--insert from reflab app
		--insert into more_countact_info
		insert into westmore_contact_info(facility_num, hlab_num) values(@facilitynumber, @hlabnum)
		--insert into bill info
		insert into westbill_info(hlab_num, facility_num, add1, add2, city, state, zip, country,country_code) values(@hlabnum, @facilitynumber,
		@add1, @add2, @city, @state, @zip,@country, @countrycode)
		--insert into westequipreportlabel_comments
		insert into westequipreportlabel_comments(hlab_num, facility_num) values(@hlabnum, @facilitynumber)
    insert into  westafterhourscontact (facility_num,hlab_num) values (@facilitynumber,@hlabnum)
		--insert ibto customizations tables
		insert into southhard_copy(hlab_num) values(@hlabnum)
		insert into southalert_exception(hlab_num) values(@hlabnum)
		insert into southcopyto(hlab_num) values(@hlabnum)
		insert into southspecial_instructions(hlab_num) values(@hlabnum)
	END"




/

select ami_database,ami_market from facility
where priority_call = 1;

select * from customer_num
where customer_num = 'C010294';

/

select len(account_category) account_category,count(1) from facility
where len(account_category) = 0 or account_category is null
group by account_category;

select * from customer_num
where cust_hlab_num like 'B%';

select priority_call,count(1) from facility
group by priority_call;

select f.phone,f.fax,f.address1,a.phys_add1,len(country) country,len(country_code) country_code from facility f
join eastadd_info a ON a.hlab_num = f.hlab_num
;


SELECT st.*
FROM sys.all_objects so
JOIN sys.columns sc ON sc.object_id = so.object_id
join sys.types st ON st.user_type_id = sc.user_type_id;
--where so.name in ('customer_num');

select * from sys.procedures
order by modify_date desc;

select * from ami_database;

--WHERE so.type ='u'
--where so.name in ('add_account_info','alertcomments','bus_unit_code','BusUnitRegionArea','BusUnitRegionAreaNameNum','CDBRefLab','ClinicalSupport','comments_reason','Coordinator','copyto','corporate_info',
--'CorporateInfo','Cour_Depot','courier','courier_alter','courier_profile','Courier_schedule','CourierbyRoute','CourierHours','CS_rep','CustomAlerts','customer_num','CustomExceptions',
--'DayTranslateSpectraToCXT','eastadd_info','EastAddTransferWest','eastafterhourscontact','eastalert_exception','EastAssociateLoadtoDB','eastclient_rep','EastClinicalRep','eastcopyto',
--'eastdraw_data_comments','eastdrawdata','eastemail','eastequipami_label','eastequiphlab_report','eastequipprint_manager','eastequipreportlabel_comments','Easthard_copy','eastprintmgrload',
--'eastpriority_list','eastproblem_log','eastspecial_instructions','eaststudyinfo','facility','facility_change','facility_status','facility_transfer','FacilitywithoutSunCall','more_account_info',
--'more_contact_info','MoreBusUnitRegionArea','NationalAccounts','NationalAccountsIntExtStudy','NationalAccountsSouth','NationalAccountsSouthIntExtStudy','NationalAccountsWest',
--'NationalAccountsWestIntExtStudy','order_report_system','patient_change','patient_report','primaryaccounts','priority_list','Problem_desc','region_name','report_option','Sales_rep',
--'sales_ter','sh_addinfo','software','southadd_info','southalert_exception','southcopyto','southcs_rep','southfacility','southfacility_change','SouthFacility_courier','southhard_copy',
--'southmore_account_info','southpriority_list','southspecial_instructions','specimen_delivery','TransferMoreWest','type_of_service','westadd_info','westafterhourscontact','westalert_exception',
--'westclient_rep','WestClinSupp','westcopyto','westcs_rep','westemail','westequip_moredetail','westequipami_label','westequiphlab_report','westequipprint_manager','westfacility','westfacility_change',
--'westhard_copy','westmore_account_info','westmore_contact_info','westspecial_instructions')
--and so.name like '%equipami_label' or so.name like '%equiphlab_report' or so.name like '%equipprint_manager'
--and sc.name like 'fmc%' 
--and sc.name
--and modify_date > GETDATE() - 360
--group by so.name
ORDER BY so.name,sc.column_id;

select hlab_num,admin from more_account_info
where len(admin) > 1;



select hlab_num,fmc_number,tableflag,count(1) from
(select hlab_num,'E' tableflag,f.fmc_number from facility f
union all
select hlab_num, 'S' tableflag,f.fmc_number from southfacility f
union all
select hlab_num, 'W' tableflag,f.fmc_number from westfacility f) t1
where fmc_number is null
group by hlab_num,fmc_number,tableflag;

select len(fmc_number), fmc_number from southfacility
where len(fmc_number) = 0
and hlab_num = 'A200121';

select len(sp_text),sp_text from 
(select object_definition (OBJECT_ID(name)) sp_text from
(SELECT name
FROM sys.all_objects so
where type_desc like 'SQL_STORED_PROCEDURE'
and name like 'p_%') t1) t2
where sp_text like '%fmc_number%'
;



ORDER BY so.name,sc.column_id;

select * from priority_list;


select * from nationalaccounts;

select * from southmore_account_info;

select * from DayTranslateSpectraToCXT;

select * from EastAssociateLoadtoDB;

select * from order_report_system;

select * from patient_report;

select * from print_option;

select * from priority_list;


SELECT sc.*
FROM sys.all_objects so
JOIN sys.columns sc ON sc.object_id = so.object_id
where so.name like 'facility';

select schema_name(schema_id) as cdbhlab
,name
from sys.objects
where type = 'V'
order by name;

select * from vw_plac_priority;



select object_definition(object_id('p_AddBilling'));

select * from accountcategory;
select * from accounttype;
select * from type_of_service;
select * from order_report_system;
select * from priority_list; -- lookup
select * from eastpriority_list;
select * from southpriority_list;
select * from westpriority_list;
select * from eastspecial_instructions
where hlab_num = 'A119095';

select * from specimen_delivery;

select * from facility_transfer
where transfer_reason like '%South%';

select * from eastadd_info
where hlab_num = 'A119095';

select * from facility
where hlab_num = 'A119095';

select * from clinicalsupport;
select * from sales_rep;
select * from customalerts;
select * from customexceptions;

select * from more_account_info;
select * from easthard_copy where hard_copy is not null;

select * from 


select * from facility;

insert into accountcategory values ('TS','Testing Cat');
insert into accounttype values ('Test Type');
insert into type_of_service values ('TESTING');
insert into order_report_system values ('Test Ordering System');
insert into priority_list values ('Test Priority List');
insert into clinicalsupport values ('Tim Smithers',null);
insert into cour_depot values ('3232','Tim','Tim',null);

select * from patient_report;

select * from courier;
update courier
set cour_courier_area = 'BALTIMORE'
where cour_code = '4140';

select * from busunitregionarea;







select * from facility where int_ext_study = 'I'
and fmc_number is null;

select * from more_account_info;

select * from EASTEQUIPAMI_LABEL;
select * from eastequiphlab_report;
select * from EASTEQUIPPRINT_MANAGER;

select * from eastequiphlab_reportload;

select * from westhard_copy
where hlab_num = 'A105653';





select * from clinic_support;

select * from more_account_info
where hlab_num = 'A103440';

select type_of_service from westfacility
group by type_of_service;

select * from eastemail;


select * from add_account_info;
select * from westadd_account_info;

select * from westadd_info;
select * from eastadd_info;

select * from l_westfacility;



select * from sysobjects
where type = 'v';

select * from sys.types;

select * from sys.columns
where object_id = 10483116;

select * from more_account_info
where hlab_num = 'A115391';
/

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