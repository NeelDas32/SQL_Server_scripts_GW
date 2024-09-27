select mirroring_partner_name,mirroring_witness_name, 
mirroring_state_desc,mirroring_witness_state_desc, 
database_id, mirroring_connection_timeout, *
from sys.database_mirroring (nolock)
where mirroring_partner_name is not null

-- select * from sys.databases

select d.name, m.mirroring_witness_state_desc, m.mirroring_connection_timeout
from sys.database_mirroring m (nolock)
join sys.databases d on d.database_id = m.database_id

-- SELECT role_desc, state_desc, * FROM sys.database_mirroring_endpoints

/*
alter database prodSPPC_dw set partner timeout 90
alter database prodFICOH_dw set partner timeout 90
alter database prodMMIC_dw set partner timeout 90
alter database prodDMIC_dw set partner timeout 90
*/