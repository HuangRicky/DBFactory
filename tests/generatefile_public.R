if(F){
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

  # if you are installing from source, you can:
  jsonlite::write_json(sample_db_info, 'inst/extdata/dbdata.json', pretty=T, na='null')

  # if you already installed this package, you can use the following to write your file:
  nowlibpath <- paste0(.Library,'/DBFactory/extdata/dbdata.json')
  jsonlite::write_json(sample_db_info, nowlibpath, pretty=T, na='null')




  # check if you can find the file:
  system.file('extdata','dbdata.json', package='DBFactory', mustWork = F)

}

