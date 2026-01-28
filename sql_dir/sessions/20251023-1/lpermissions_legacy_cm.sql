-- Check if the table exists
USE CDBHLab
GO
SELECT TABLE_SCHEMA, TABLE_NAME 
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_NAME LIKE '%eastequipami_label%';

-- Check current user permissions
SELECT 
    p.permission_name,
    p.state_desc,
    pr.name AS principal_name
FROM sys.database_permissions p
LEFT JOIN sys.objects o ON p.major_id = o.object_id
LEFT JOIN sys.database_principals pr ON p.grantee_principal_id = pr.principal_id
WHERE o.name = 'westequipami_label';

-- Check what user the application is connecting as
SELECT USER_NAME() , DB_NAME() AS current_database;

-- Grant truncate permission to the application user
GRANT ALTER ON CDBHLab.dbo.eastequipami_label TO CM_OWNER;