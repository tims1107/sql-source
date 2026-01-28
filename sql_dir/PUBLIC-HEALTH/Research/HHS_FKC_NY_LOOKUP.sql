select created_dtm from HHS_FKC_NY_LOOKUP
order by created_dtm desc;

-- Find objects that depend on this table
SELECT owner, name, type, referenced_owner, referenced_name, referenced_type
FROM dba_dependencies 
WHERE referenced_name = 'HHS_FKC_NY_LOOKUP'
ORDER BY owner, name, type;

-- Search across all possible database objects
SELECT 'VIEW' as object_type, owner, object_name, NULL as line_number, 
       SUBSTR(text, 1, 100) as text_snippet
FROM dba_views 
WHERE UPPER(text) LIKE '%HHS_FKC_NY_LOOKUP%'

UNION ALL

SELECT 'PL/SQL' as object_type, owner, name as object_name, line as line_number,
       SUBSTR(text, 1, 100) as text_snippet
FROM dba_source 
WHERE UPPER(text) LIKE '%HHS_FKC_NY_LOOKUP%'

UNION ALL

SELECT 'TRIGGER' as object_type, owner, trigger_name as object_name, NULL as line_number,
       SUBSTR(trigger_body, 1, 100) as text_snippet
FROM dba_triggers 
WHERE UPPER(trigger_body) LIKE '%HHS_FKC_NY_LOOKUP%'

ORDER BY object_type, owner, object_name;
/

-- Detailed session info including SQL being executed
SELECT 
    s.sid,
    s.serial#,
    s.username,
    s.schemaname,
    s.osuser,
    s.machine,
    s.program,
    s.status,
    s.logon_time,
    s.last_call_et/60 as idle_minutes,
    sq.sql_text
FROM v$session s
LEFT JOIN v$sql sq ON s.sql_id = sq.sql_id
WHERE s.username = 'STATERPT_OWNER'
   OR s.schemaname = 'STATERPT_OWNER'
ORDER BY s.logon_time DESC;