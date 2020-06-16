#' Get DB definition file
#' @description read in definition file. default to package file
#' @export
get_db_def <- function(fn=NULL, assign_env=T){
  if(is.null(fn)){
    fn <- system.file('extdata','dbdata.json', package='DBFactory', mustWork = F)
  }
  db_def <- jsonlite::fromJSON(fn)
  if(assign_env){
    assign(x = 'db_def',value = db_def,pos = .DBFactoryEnv)
  }
  db_def
}

#' Parse DB from definition file
#' @description parse a string DB name
#' @param db database server nickname
#' @return dbobj
#' @export
parse_dbobj <- function(db='DEV'){
  db_def <- .DBFactoryEnv$db_def
  dbitem <- db_def[db_def$name == db, ]
  if(nrow(dbitem)==0) return (NULL)
  l <- list(name = dbitem$name, type=dbitem$type, DatabaseServer=dbitem$server, InitDB=dbitem$initdb, IsTrusted=dbitem$istrusted, User=dbitem$user , Password=dbitem$pass, constr=dbitem$connstring)
  attr(l, 'class') <- dbitem$type
  l
}

#' Set up default dbobj
#' @description set default connection
#' @param db database server nickname
#' @export
set_default_dbobj <- function(db='DEV'){
  assign(x = 'default_dbobj',value = parse_dbobj(db), pos = .DBFactoryEnv)
}
