-- SQL script to create the state_copy_config table and related objects in Oracle
-- This script follows functional programming principles by creating immutable objects
-- with clear constraints and relationships

-- Drop sequence if exists to avoid errors during re-execution
BEGIN
   EXECUTE IMMEDIATE 'DROP SEQUENCE state_copy_config_seq';
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE != -2289 THEN
         RAISE;
      END IF;
END;
/

-- Drop table if exists to avoid errors during re-execution
BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE state_copy_config';
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE != -942 THEN
         RAISE;
      END IF;
END;
/

-- Create sequence for ID generation
CREATE SEQUENCE state_copy_config_seq
  START WITH 1
  INCREMENT BY 1
  NOCACHE
  NOCYCLE;

-- Create the state_copy_config table
CREATE TABLE state_copy_config (
  id                  NUMBER(19)      NOT NULL,
  enabled             NUMBER(1)       NOT NULL,
  cron_expression     VARCHAR2(100)   NOT NULL,
  base_path           VARCHAR2(500)   NOT NULL,
  state_code          VARCHAR2(10)    NOT NULL,
  state_folder_path   VARCHAR2(500)   NOT NULL,
  file_pattern        VARCHAR2(500),
  custom_date         VARCHAR2(20),
  destination_base_path VARCHAR2(500) NOT NULL,
  preserve_structure  NUMBER(1)       NOT NULL,
  destination_path    VARCHAR2(500)   NOT NULL,
  created_date        TIMESTAMP       NOT NULL,
  last_updated_date   TIMESTAMP,
  created_by          VARCHAR2(100)   NOT NULL,
  last_updated_by     VARCHAR2(100),
  
  -- Primary key constraint
  CONSTRAINT state_copy_config_pk PRIMARY KEY (id),
  
  -- Unique constraint on state_code to ensure each state has only one configuration
  CONSTRAINT state_copy_config_uk_state UNIQUE (state_code)
);

ALTER TABLE state_copy_config DROP CONSTRAINT state_copy_config_uk_state;

-- Create index on enabled column for efficient queries of enabled configurations
CREATE INDEX state_copy_config_idx_enabled ON state_copy_config(enabled);

-- Create index on state_code for efficient lookups by state
CREATE INDEX state_copy_config_idx_state ON state_copy_config(state_code);

-- Create a trigger to automatically set the ID from the sequence
CREATE OR REPLACE TRIGGER state_copy_config_bir
BEFORE INSERT ON state_copy_config
FOR EACH ROW
BEGIN
  IF :new.id IS NULL THEN
    SELECT state_copy_config_seq.NEXTVAL INTO :new.id FROM dual;
  END IF;
  
  -- Set created_date if not provided
  IF :new.created_date IS NULL THEN
    :new.created_date := SYSTIMESTAMP;
  END IF;
END;
/

-- Create a trigger to automatically update last_updated_date on updates
CREATE OR REPLACE TRIGGER state_copy_config_bur
BEFORE UPDATE ON state_copy_config
FOR EACH ROW
BEGIN
  :new.last_updated_date := SYSTIMESTAMP;
END;
/

-- Comments for documentation
/
begin

COMMENT ON TABLE state_copy_config IS 'Configuration table for file transfer operations by state';
COMMENT ON COLUMN state_copy_config.id IS 'Primary key';
COMMENT ON COLUMN state_copy_config.enabled IS 'Flag indicating if this configuration is active (1) or inactive (0)';
COMMENT ON COLUMN state_copy_config.cron_expression IS 'Cron expression for scheduling file transfers';
COMMENT ON COLUMN state_copy_config.base_path IS 'Base path for source files';
COMMENT ON COLUMN state_copy_config.state_code IS 'State code identifier (e.g., NY, CA)';
COMMENT ON COLUMN state_copy_config.state_folder_path IS 'Folder path specific to this state';
COMMENT ON COLUMN state_copy_config.file_pattern IS 'Pattern to match files for transfer, may include date parameters';
COMMENT ON COLUMN state_copy_config.destination_base_path IS 'Base path for destination files';
COMMENT ON COLUMN state_copy_config.preserve_structure IS 'Flag indicating if directory structure should be preserved (1) or not (0)';
COMMENT ON COLUMN state_copy_config.destination_path IS 'Destination path specific to this state';
COMMENT ON COLUMN state_copy_config.created_date IS 'Timestamp when the record was created';
COMMENT ON COLUMN state_copy_config.last_updated_date IS 'Timestamp when the record was last updated';
COMMENT ON COLUMN state_copy_config.created_by IS 'User who created the record';
COMMENT ON COLUMN state_copy_config.last_updated_by IS 'User who last updated the record';
end;
/
 --Sample insert statement for initial configuration
 INSERT INTO state_copy_config (
   enabled, cron_expression, base_path, state_code, state_folder_path,
   file_pattern, custom_date,destination_base_path, preserve_structure, destination_path,
   created_by
 ) VALUES (
   1, '0 * * * * *', '\\\\njnas01\\commonfs\\johnshen\\test\\asr\\spectrahlab_external_interface_results\\',
   'NY', 'archive',
   '^(NY\\.HL7.*\\{date\\}.*)$', '20250711','\\\\njwrresult2p\\uphn_lite\\data', 
   1, 'test/out',
   'SYSTEM'
 );

-- Grant permissions as needed
 GRANT SELECT, INSERT, UPDATE, DELETE ON state_copy_config TO staterpt_user;
 GRANT SELECT ON state_copy_config_seq TO staterpt_user;

-- Commit changes
COMMIT;

UPDATE state_copy_config 
SET destination_path = 'test\\out'  -- Use backslashes for Windows paths
WHERE state_code IN ('CA', 'NY');

select * from state_copy_config;
update state_copy_config
set enabled = 1,state_code='CA',file_pattern='^(CA\\.HL7.*\\{date\\}.*)$'
where id = 2;



update state_copy_config
set state_folder_path='archive',destination_path='test/out',custom_date='20250712',cron_expression='0 * * * * *'
where id = 2;
