select * from eastequipami_label
where printername = 'Bowling Green';

/

SELECT 
    name,
    size/128.0 AS CurrentSizeMB,
    size/128.0 - CAST(FILEPROPERTY(name, 'SpaceUsed') AS INT)/128.0 AS FreeSpaceMB
FROM sys.database_files
WHERE type = 1  -- Log files

/

BACKUP LOG CDBHLab TO DISK = 'C:\Backups\CDBHLab_Log.trn'

/

-- Detailed log file information for CDBHLab database
USE CDBHLab
GO
SELECT 
    name AS LogFileName,
    size/128.0 AS CurrentSizeMB,
    size/128.0 - CAST(FILEPROPERTY(name, 'SpaceUsed') AS INT)/128.0 AS FreeSpaceMB,
    CAST(FILEPROPERTY(name, 'SpaceUsed') AS INT)*100/size AS PercentUsed
FROM sys.database_files
WHERE type = 1  -- Log files only

/

-- Show currently active transactions
SELECT 
    s.session_id,
    s.login_name,
    s.program_name,
    s.host_name,
    t.transaction_id,
    t.name AS transaction_name,
    t.transaction_begin_time,
    DATEDIFF(second, t.transaction_begin_time, GETDATE()) AS duration_seconds,
    t.transaction_type,
    t.transaction_state
FROM sys.dm_tran_active_transactions t
INNER JOIN sys.dm_tran_session_transactions st ON t.transaction_id = st.transaction_id
INNER JOIN sys.dm_exec_sessions s ON st.session_id = s.session_id
WHERE s.is_user_process = 1
ORDER BY t.transaction_begin_time

/

-- Create a monitoring query to run repeatedly
USE CDBHLab
GO
SELECT 
    GETDATE() AS CheckTime,
    DB_NAME() AS DatabaseName,
    cntr_value/1024.0 AS LogSizeMB
FROM sys.dm_os_performance_counters 
WHERE counter_name = 'Log File(s) Size (KB)'
    AND instance_name = 'CDBHLab'
    
/

-- Check log record details (SQL Server 2016+)
SELECT 
    operation,
    context,
    COUNT(*) as record_count,
    SUM(log_record_length) as total_log_bytes
FROM sys.fn_dblog(NULL, NULL)
WHERE operation IN ('LOP_DELETE_ROWS', 'LOP_INSERT_ROWS', 'LOP_MODIFY_ROW')
GROUP BY operation, context
ORDER BY total_log_bytes DESC

/

-- Show active connections and their current commands
SELECT 
    s.session_id,
    s.login_name,
    s.program_name,
    s.host_name,
    s.login_time,
    s.last_request_start_time,
    s.status,
    r.command,
    r.database_id,
    DB_NAME(r.database_id) AS database_name,
    t.text AS current_sql
FROM sys.dm_exec_sessions s
LEFT JOIN sys.dm_exec_requests r ON s.session_id = r.session_id
OUTER APPLY sys.dm_exec_sql_text(r.sql_handle) t
WHERE s.is_user_process = 1
    AND s.database_id = DB_ID('CDBHLab')
ORDER BY s.last_request_start_time DESC