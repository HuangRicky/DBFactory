# DBFactory
R package to manage database connections

# Installation
To install this package, you can download or clone the file, R CMD INSTALL or use RStudio to open and install, or use devtools:
   
```
devtools::install_github("HuangRicky/DBFactory")
```

# Setting Up DB Information
You can create a Database Definition data.frame first:
```
  sample_db_info <- data.frame(name=c('DEV','PRD', 'XXX', 'LOCAL','LOCALMYSQL','LOCALEXPRESS','SB'),
                               type=c("sqlserver", 'oracle',"sqlserver",'sqlserver', 'mysql','sqlserver',
                                      'sybaseiq'),
                               connstring=c('', NA,NA,NA,NA,NA,NA),
                               server=c("serveraddress1", 'serveraddress2',
                                        'tcp:xxxxx.database.windows.net,1433','localhost,1433',
                                        'localhost','localhost,14433',
                                        'testserver;port=9903'),
                               initdb=c("A",NA,'XXX','XXX','TEACHING','TEACHING','SYBASEID'),
                               istrusted=c(T,F,F,F,F,F,F),
                               user=c("",'a1','XXX','xxx','user_1','user_1','user_2'),
                               pass=c("",NA,'','','','',''), stringsAsFactors = F)
```

If you download source code and install, you can run the following to write to your source package.
```
  jsonlite::write_json(sample_db_info, 'inst/extdata/dbdata.json', pretty=T, na='null')
```

If you install the package already, you can directly change the json file in your Library location:
```
  nowlibpath <- paste0(.Library,'/DBFactory/extdata/dbdata.json')
  jsonlite::write_json(sample_db_info, nowlibpath, pretty=T, na='null')
```

# Usage
```
library(DBFactory)
# to set default object:
set_default_dbobj("LOCALMYSQL")
set_default_dbobj("LOCALEXPRESS")

# see MySQL:
DBFactory::set_default_dbobj("LOCALMYSQL")
run_query('select * from teaching.Table1')

# see MSSQL:
DBFactory::set_default_dbobj("LOCALEXPRESS")
run_query('select * from TEACHING.dbo.Test1')

```
