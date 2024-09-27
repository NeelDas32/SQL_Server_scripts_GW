select a.name,b.permission_name 
from sys.server_principals a,sys.server_permissions b,sys.server_principals c
where a.principal_id= b.grantee_principal_id and b.grantor_principal_id=c.principal_id

Select * 
From sys.server_permissions 
Where grantor_principal_id = (Select principal_id 
From sys.server_principals 
Where Name = N'sa')

Select * 
From sys.server_permissions 
Where grantee_principal_id = (Select principal_id 
From sys.server_principals 
Where Name = N'ISCSUS\sqlserver')

