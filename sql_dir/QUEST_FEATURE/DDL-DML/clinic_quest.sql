BEGIN
 
    DELETE CLINIC_QUEST;
    INSERT INTO CLINIC_QUEST(CLINICID,PAT_QUEST_ACCT_NUMBER,PAT_QUEST_ACCT_START_DATE,
        STAFF_QUEST_ACCT_NUMBER,STAFF_ACCT_START_DATE,ENV_QUEST_ACCT_NUMBER,
        ENV_ACCT_START_DATE,QUEST_PRIMARY_LAB_LOCATION,QUEST_ENV_LAB_LOCATION,
        SRC_UPDATED_DTM,ENSBL_UPDATED_DTM,CREATED_DTM)
    SELECT
        c.id,
        sqf.pat_quest_acct_number,
        sqf.pat_quest_acct_start_date,
        sqf.staff_quest_acct_number,
        sqf.staff_acct_start_date,
        sqf.env_quest_acct_number,
        sqf.env_acct_start_date,
        sqf.quest_primary_lab_location,
        sqf.quest_env_lab_location,
        sqf.src_updated_dtm,
        sqf.ensbl_updated_dtm,
        sqf.created_dtm
    FROM
        cm_owner.stg_quest_facility sqf
        inner join 
        (
            select max(created_dtm) created_dtm, fmc_facility_number
            from cm_owner.stg_quest_facility
            group by fmc_facility_number
        ) last_sqf on sqf.fmc_facility_number = last_sqf.fmc_facility_number and sqf.created_dtm = last_sqf.created_dtm
        inner join cm_owner.clinic c on sqf.fmc_facility_number = c.fmcnumber;
        COMMIT;
EXCEPTION
       WHEN OTHERS THEN
        DBMS_OUTPUT.put_line ('Error in refreshing table CLINIC_QUEST');
END;

/

select CLINICID
    ,PAT_QUEST_ACCT_NUMBER
    ,PAT_QUEST_ACCT_START_DATE
    ,STAFF_QUEST_ACCT_NUMBER
    ,STAFF_ACCT_START_DATE
    ,ENV_QUEST_ACCT_NUMBER
    ,ENV_ACCT_START_DATE
    ,QUEST_PRIMARY_LAB_LOCATION
    ,QUEST_ENV_LAB_LOCATION
    ,SRC_UPDATED_DTM
    ,ENSBL_UPDATED_DTM
    ,CREATED_DTM
from CLINIC_QUEST;

select * from stg_quest_facility;

--------------------------------------------------------
--  DDL for Table CLINIC_QUEST
--------------------------------------------------------

  CREATE TABLE "CM_OWNER"."CLINIC_QUEST" 
   (	"CLINICID" NUMBER, 
	"PAT_QUEST_ACCT_NUMBER" VARCHAR2(10 BYTE), 
	"PAT_QUEST_ACCT_START_DATE" DATE, 
	"STAFF_QUEST_ACCT_NUMBER" VARCHAR2(10 BYTE), 
	"STAFF_ACCT_START_DATE" DATE, 
	"ENV_QUEST_ACCT_NUMBER" VARCHAR2(10 BYTE), 
	"ENV_ACCT_START_DATE" DATE, 
	"QUEST_PRIMARY_LAB_LOCATION" VARCHAR2(3 BYTE), 
	"QUEST_ENV_LAB_LOCATION" VARCHAR2(3 BYTE), 
	"SRC_UPDATED_DTM" TIMESTAMP (6), 
	"ENSBL_UPDATED_DTM" TIMESTAMP (6), 
	"CREATED_DTM" TIMESTAMP (6) DEFAULT SYSTIMESTAMP
   ) SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 
 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "CM" ;
--------------------------------------------------------
--  DDL for Index SYS_C0019856
--------------------------------------------------------

  CREATE UNIQUE INDEX "CM_OWNER"."SYS_C0019856" ON "CM_OWNER"."CLINIC_QUEST" ("CLINICID") 
  PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "CM" ;
--------------------------------------------------------
--  Constraints for Table CLINIC_QUEST
--------------------------------------------------------

  ALTER TABLE "CM_OWNER"."CLINIC_QUEST" MODIFY ("CREATED_DTM" NOT NULL ENABLE);
  ALTER TABLE "CM_OWNER"."CLINIC_QUEST" ADD PRIMARY KEY ("CLINICID")
  USING INDEX PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "CM"  ENABLE;
  
  /
  
  select * from clinic_quest;
  
  select id,c.hlabnumber from clinic_quest q
  join clinic c ON c.id = q.clinicid;
  
  where clinicid IN
  (select id from clinic);

 