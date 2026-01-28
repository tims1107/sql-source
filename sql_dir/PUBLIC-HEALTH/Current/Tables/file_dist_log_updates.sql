
drop table file_dist_log;

create table file_dist_log
(
    file_dist_log_id number not null,
    file_name varchar2(256) not null,
    file_content clob ,
    created_At timestamp not null,
    created_by varchar2(128) not null,
    status smallint not null,
    updated_at timestamp,
    updated_by varchar2(128)
);

ALTER TABLE FILE_DIST_LOG 
MODIFY FILE_CONTENT NULL;

CREATE UNIQUE INDEX idx_file_dist_log_unique_id 
ON file_dist_log (file_dist_log_id);

/

create table elr_distribution
(
   elr_id number not null,
   file_dist_log_id_fk number not null,
   created_At timestamp not null,
   created_by varchar2(128) not null,
   updated_at timestamp,
   updated_by varchar2(128)
);

/

-- Create sequence for file_dist_log_id
CREATE SEQUENCE file_dist_log_seq
    START WITH 1
    INCREMENT BY 1
    NOCACHE
    NOCYCLE;

-- Create the file_dist_log table
CREATE TABLE file_dist_log (
    file_dist_log_id NUMBER NOT NULL,
    file_name VARCHAR2(256) NOT NULL,
    file_content CLOB NOT NULL,
    created_at TIMESTAMP NOT NULL,
    created_by VARCHAR2(128) NOT NULL,
    status SMALLINT NOT NULL,
    updated_at TIMESTAMP,
    updated_by VARCHAR2(128),
    CONSTRAINT pk_file_dist_log PRIMARY KEY (file_dist_log_id)
);

-- Create trigger to auto-increment file_dist_log_id on insert
CREATE OR REPLACE TRIGGER trg_file_dist_log_insert
BEFORE INSERT ON file_dist_log
FOR EACH ROW
BEGIN
    IF :new.file_dist_log_id IS NULL THEN
        SELECT file_dist_log_seq.NEXTVAL
        INTO :new.file_dist_log_id
        FROM dual;
    END IF;
    
    -- Set created_at to current timestamp if not provided
    IF :new.created_at IS NULL THEN
        :new.created_at := SYSTIMESTAMP;
    END IF;
END;
/

-- Add comments to table and columns
COMMENT ON TABLE file_dist_log IS 'Logs file distribution operations';
COMMENT ON COLUMN file_dist_log.file_dist_log_id IS 'Primary key';
COMMENT ON COLUMN file_dist_log.file_name IS 'Name of the distributed file';
COMMENT ON COLUMN file_dist_log.file_content IS 'Content of the file';
COMMENT ON COLUMN file_dist_log.created_at IS 'Timestamp when the record was created';
COMMENT ON COLUMN file_dist_log.created_by IS 'User who created the record';
COMMENT ON COLUMN file_dist_log.status IS 'Status of the file distribution (0=pending, 1=success, 2=error)';
COMMENT ON COLUMN file_dist_log.updated_at IS 'Timestamp when the record was last updated';
COMMENT ON COLUMN file_dist_log.updated_by IS 'User who last updated the record';

select * from staterpt_owner.file_dist_log
where file_content is not null
and regexp_like(file_content,'^(MSH|FHS).+$')
and created_at > sysdate - .5
and regexp_like(file_name,'(hl7)')
order by file_name;

select * from staterpt_owner.file_dist_log
--where file_name = 'SPECTRAEAST.31D0961672.20250806001123.hl7'
order by created_at desc;

    