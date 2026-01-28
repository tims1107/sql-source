select count(1) from korus_printer;

delete korus_printer;

--------------------------------------------------------
--  DDL for Table DW_ODS_ACTIVITY
--------------------------------------------------------

  CREATE TABLE "IH_DW"."DW_ODS_ACTIVITY" 
   (	"REQUISITION_ID" VARCHAR2(50 BYTE), 
	"LAST_UPDATED_DATE" TIMESTAMP (6), 
	"LAB_ORDER_FK" NUMBER
   ) 

   COMMENT ON COLUMN "IH_DW"."DW_ODS_ACTIVITY"."REQUISITION_ID" IS 'Unique';
  
--------------------------------------------------------
--  DDL for Index UDX_DWOA_OFK
--------------------------------------------------------

  CREATE INDEX "IH_DW"."UDX_DWOA_OFK" ON "IH_DW"."DW_ODS_ACTIVITY" ("LAB_ORDER_FK") 
  PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS NOLOGGING 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "DWX" ;
--------------------------------------------------------
--  DDL for Index UDX_DWOA_REQID
--------------------------------------------------------

  CREATE UNIQUE INDEX "IH_DW"."UDX_DWOA_REQID" ON "IH_DW"."DW_ODS_ACTIVITY" ("REQUISITION_ID") 
  PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "DWX" ;
--------------------------------------------------------
--  DDL for Index IDX_DWOA_LUDT
--------------------------------------------------------

  CREATE INDEX "IH_DW"."IDX_DWOA_LUDT" ON "IH_DW"."DW_ODS_ACTIVITY" ("LAST_UPDATED_DATE") 
  PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "DWX" ;
--------------------------------------------------------
--  Ref Constraints for Table DW_ODS_ACTIVITY
--------------------------------------------------------

  ALTER TABLE "IH_DW"."DW_ODS_ACTIVITY" ADD CONSTRAINT "FK_DOACT_DIM_LAB_ORDER" FOREIGN KEY ("LAB_ORDER_FK")
	  REFERENCES "IH_DW"."DIM_LAB_ORDER" ("LAB_ORDER_PK") DISABLE;
      
 select * from ih_dw.dw_ods_activity
 where last_updated_date > sysdate - 1;
