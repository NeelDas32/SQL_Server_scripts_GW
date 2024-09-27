SELECT prin.[name] [User], sec.state_desc + ' ' + sec.permission_name [Permission] 
FROM [sys].[database_permissions] sec 
  JOIN [sys].[database_principals] prin 
    ON sec.[grantee_principal_id] = prin.[principal_id] 
WHERE sec.class = 0 
ORDER BY [User], [Permission];