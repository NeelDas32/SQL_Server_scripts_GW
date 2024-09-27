use DBName
go

-- UserInfo Reload
set identity_insert dbo.UserInfo on;

-- clear data in production table, reload from Linked Server
truncate table UserInfo;
insert into UserInfo
(SystemId,
UpdateCount,
UpdateUser,
UpdateTimestamp,
XmlContent,
MiniXmlContent)
select SystemId,
UpdateCount,
UpdateUser,
UpdateTimestamp,
XmlContent,
MiniXmlContent
-- Linked Server 
from [ServerName.ISCSWS.NET].DBName.dbo.UserInfo;

set identity_insert dbo.UserInfo off;
 
-- UserInfoLookup Reload

-- clear data in production table, reload from Linked Server
truncate table UserInfoLookup;
insert into UserInfoLookup
(SystemId,
LookupKey,
LookupValue,
Preview)
select SystemId,
LookupKey,
LookupValue,
Preview
-- Linked Server 
from [SererName.ISCSWS.NET].DBName.dbo.UserInfoLookup;

