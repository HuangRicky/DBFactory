library(DBFactory)
DBFactory::set_default_dbobj("LOCALMYSQL")
DBFactory::set_default_dbobj("LOCALEXPRESS")
dbobj <- DBFactory:::.DBFactoryEnv$default_dbobj

run_query('select 123', dbobj=dbobj)

# pool also works.
dbobj$ispool <- T
run_query('select 1234', dbobj=dbobj)


# don't need to provide the dbobj.
run_query('select 123')

# see MySQL:
DBFactory::set_default_dbobj("LOCALMYSQL")
run_query('select * from teaching.Table1')

# see MSSQL:
DBFactory::set_default_dbobj("LOCALEXPRESS")
run_query('select * from TEACHING.dbo.Test1')

