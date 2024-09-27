select * from GWRE_IT.dbo.IndexFrag (nolock)
where DB_NAME = 'preprod_cc'
and FRAG > 10 and PAGES > 300
and COMMAND is not null
order by TABLE_NAME, INDEX_NAME
