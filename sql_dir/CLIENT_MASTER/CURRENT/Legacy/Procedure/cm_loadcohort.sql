CREATE PROCEDURE [dbo].[cm_loadcohort]
@hlabnum varchar(9),@facilitynum varchar(10),@annual varchar(16),@cohort varchar(16),@startdate varchar(20),@enddate varchar(20),@zone varchar(1)

 AS
 
  
 declare @sdate smalldatetime = ' '
 declare @edate smalldatetime = ' '
 declare @pre_exist int = 0
 
 select @pre_exist = count(*)
 from cm_cohort
 where hlab_num = @hlabnum
 

 if len(@startdate)  > 1
 set @sdate = convert(smalldatetime,@startdate,101)
 
 if len(@enddate) > 1
 set @edate = convert(smalldatetime,@enddate,101)
 
 if @pre_exist < 1
 begin
 insert into cm_cohort (hlab_num,facility_num,annual_month,cohort,startdate,enddate,location) values (@hlabnum,@facilitynum,@annual,@cohort,@sdate,@edate,@zone)
 end
 else
  update cm_cohort 
  set hlab_num = @hlabnum,facility_num = @facilitynum,annual_month = @annual,cohort = @cohort,startdate = @sdate,enddate = @edate,location = @zone
  where hlab_num = @hlabnum
  
/
    select * from cm_cohort;
/
DECLARE @hlabnum varchar(9)
DECLARE @facilitynum varchar(10)
DECLARE @annual varchar(16)
DECLARE @cohort varchar(16)
DECLARE @startdate varchar(20)
DECLARE @enddate varchar(20)
DECLARE @zone varchar(1)

SET @hlabnum = 'A100002'
SET @facilitynum = '11938'
SET @annual = ''
SET @cohort = ''
SET @startdate = ''
SET @enddate = ''
SET @zone = 'E'

cm_loadcohort @hlabnum, @facilitynum, @annual, @cohort, @startdate, @enddate, @zone