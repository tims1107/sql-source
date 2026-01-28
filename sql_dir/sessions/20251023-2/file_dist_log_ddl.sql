-- DDL script for file_dist_log table
-- This table logs file distribution operations

-- Create sequence for primary key
CREATE SEQUENCE staterpt_owner.file_dist_log_seq
    START WITH 1
    INCREMENT BY 1
    NOCACHE
    NOCYCLE;

-- Create the file_dist_log table
CREATE TABLE staterpt_owner.file_dist_log (
    file_dist_log_id NUMBER(19) NOT NULL,
    file_name VARCHAR2(256) NOT NULL,
    file_content CLOB NOT NULL,
    created_at TIMESTAMP NOT NULL,
    created_by VARCHAR2(128) NOT NULL,
    status NUMBER(5) NOT NULL,
    updated_at TIMESTAMP,
    updated_by VARCHAR2(128),
    CONSTRAINT pk_file_dist_log PRIMARY KEY (file_dist_log_id)
);

-- Create indexes for better query performance
CREATE INDEX idx_file_dist_log_file_name ON staterpt_owner.file_dist_log(file_name);
CREATE INDEX idx_file_dist_log_status ON staterpt_owner.file_dist_log(status);
CREATE INDEX idx_file_dist_log_created_at ON staterpt_owner.file_dist_log(created_at);
CREATE INDEX idx_file_dist_log_created_by ON staterpt_owner.file_dist_log(created_by);

-- Add comments for documentation
COMMENT ON TABLE staterpt_owner.file_dist_log IS 'Logs file distribution operations and file contents';
COMMENT ON COLUMN staterpt_owner.file_dist_log.file_dist_log_id IS 'Primary key - unique identifier for each log entry';
COMMENT ON COLUMN staterpt_owner.file_dist_log.file_name IS 'Name of the distributed file';
COMMENT ON COLUMN staterpt_owner.file_dist_log.file_content IS 'Content of the distributed file';
COMMENT ON COLUMN staterpt_owner.file_dist_log.created_at IS 'Timestamp when the log entry was created';
COMMENT ON COLUMN staterpt_owner.file_dist_log.created_by IS 'User or system that created the log entry';
COMMENT ON COLUMN staterpt_owner.file_dist_log.status IS 'Status of the file distribution (0=pending, 1=success, 2=error)';
COMMENT ON COLUMN staterpt_owner.file_dist_log.updated_at IS 'Timestamp when the log entry was last updated';
COMMENT ON COLUMN staterpt_owner.file_dist_log.updated_by IS 'User or system that last updated the log entry';
