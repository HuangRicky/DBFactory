# this file is for S3 methods.

#' Internal runner method
#' @description no need to call directly
run <- function(x, ...){
  UseMethod('run', x)
}

run.default <- function(x, ...){
  cat("Not implemented! the ... is:\n")
  print(list(...))
}

run.sqlserver <- function(x, ...){
  # cat("this is sqlserver! the ... is:\n")
  #
  # print(list(...))
  #
  # print(class(x))

  constr <- get_connstr_template(x)
  # cat("constr is ", constr,'\n')
  query <- x$stmt

  if(x$keepcnxn & exists('sqlserver_cnxn', .DBFactoryEnv) & !is.null(.DBFactoryEnv$sqlserver_cnxn)){
    channel <- .DBFactoryEnv$sqlserver_cnxn
    d <- DBI::dbGetQuery(channel,query)
    return(d)
  }

  if(x$ispool == F && x$is_odbc_exist == T){
    channel <- DBI::dbConnect(odbc::odbc(), .connection_string = constr)

    d <- DBI::dbGetQuery(channel,query)
    # disconnect it right away:
    if(!x$keepcnxn){
      DBI::dbDisconnect(channel)
    } else {
      assign('sqlserver_cnxn',channel,.DBFactoryEnv)
    }
  } else {
    pool <- DBFactory_getsetpool(constr)
    d <- pool::dbGetQuery(pool, query)
  }

  # finally return result
  d
}

run.mysql <- function(x, ...){
  # cat("this is mysql! the ... is:\n")
  #
  # print(list(...))
  #
  # print(class(x))

  constr <- get_connstr_template(x)
  # cat("constr is ", constr,'\n')
  query <- x$stmt

  if(x$keepcnxn & exists('mysql_cnxn', .DBFactoryEnv) & !is.null(.DBFactoryEnv$mysql_cnxn)){
    channel <- .DBFactoryEnv$mysql_cnxn
    d <- DBI::dbGetQuery(channel,query)
    return(d)
  }


  if(x$ispool == F && x$is_odbc_exist == T){
    channel <- DBI::dbConnect(odbc::odbc(), .connection_string = constr)

    d <- DBI::dbGetQuery(channel,query)
    # disconnect it right away:
    if(!x$keepcnxn){
      DBI::dbDisconnect(channel)
    } else {
      assign('mysql_cnxn',channel,.DBFactoryEnv)
    }
  } else {
    pool <- DBFactory_getsetpool(constr)
    d <- pool::dbGetQuery(pool, query)
  }

  # finally return result
  d
}

run.oracle <- function(x, ...){
  library(ROracle)
  query <- x$stmt

  if(x$keepcnxn & exists('oracle_cnxn', .DBFactoryEnv) & !is.null(.DBFactoryEnv$oracle_cnxn)){
    channel <- .DBFactoryEnv$oracle_cnxn
    d <- DBI::dbGetQuery(channel,query)
    return(d)
  }
  if(x$ispool){
    pool <- DBFactory_getsetpool_oracle(x$server, x$user, x$pass)
    d <- pool::dbGetQuery(pool, query)
  } else {
    channel <- dbConnect(DBI::dbDriver("Oracle"), dbname=x$server, username=x$user, password=x$pass)

    d <- dbGetQuery(channel, query)
    if(!x$keepcnxn){
      rtn <- ROracle::dbDisconnect(channel)
      if(!rtn){
        stop("cannot close Oracle Connection! Dangerous")
      }
    } else {
      assign('oracle_cnxn',channel,.DBFactoryEnv)
    }
  }
  return(d)
}

run.sybaseiq <- function(x, ...){

  #
  # print(list(...))
  #
  # print(class(x))

  constr <- get_connstr_template(x)
  # cat("constr is ", constr,'\n')
  query <- x$stmt

  if(x$keepcnxn & exists('sybaseiq_cnxn', .DBFactoryEnv) & !is.null(.DBFactoryEnv$sybaseiq_cnxn)){
    channel <- .DBFactoryEnv$sybaseiq_cnxn
    d <- DBI::dbGetQuery(channel,query)
    return(d)
  }


  if(x$ispool == F && x$is_odbc_exist == T){
    channel <- DBI::dbConnect(odbc::odbc(), .connection_string = constr)

    # the old RODBC should work. haven't tested odbc.
    # channel <- odbcDriverConnect(connstr)
    # d <- sqlQuery(channel,query=paste(query,sep=""),stringsAsFactors=options$stringsAsFactors,believeNRows=F)
    # odbcClose(channel)

    d <- DBI::dbGetQuery(channel,query)
    # disconnect it right away:
    if(!x$keepcnxn){
      DBI::dbDisconnect(channel)
    } else {
      assign('sybaseiq_cnxn',channel,.DBFactoryEnv)
    }
  } else {
    pool <- DBFactory_getsetpool(constr)
    d <- pool::dbGetQuery(pool, query)
  }

  # finally return result
  d
}


#' Main Run query function
#' @description main function
#' @param stmt statement to call
#' @param dbobj dbobj, default to NULL will use default one
#' @param keepcnxn default to F, whether keep cnxn open.
#' @return a result data.frame
#' @export
run_query <- function(stmt, dbobj=NULL, keepcnxn=F){
  if(is.null(dbobj)) dbobj <- .DBFactoryEnv$default_dbobj
  if('character' %in% class(dbobj)){
    # parse it from a string.
    dbobj <- parse_dbobj(dbobj)
  }
  # dbobj <- list()
  # attr(dbobj, 'class') <- 'sqlserver'
  dbobj$stmt <- stmt
  if(is.null(dbobj$ispool) || is.na(dbobj$ispool) || dbobj$ispool == '') dbobj$ispool <- F

  dbobj$is_odbc_exist <- 'odbc'%in%installed.packages()[, 1]
  dbobj$keepcnxn <- keepcnxn
  # then you can parse it here.
  run(dbobj)
}

#' disconnect the connection saved in env
#' @param type type of connection. sqlserver, mysql, sybaseiq, oracle
#' @export
DBFactory_disconnect <- function(type='sqlserver', returnerr=F){
  cnxnname <- paste0(type, '_cnxn')
  if(exists(cnxnname,.DBFactoryEnv) && !is.null(get(cnxnname,.DBFactoryEnv))){
    channel <- get(cnxnname,.DBFactoryEnv)
    r <- tryCatch(DBI::dbDisconnect(channel),error=function(e){
      if(returnerr){
        message(e)
      }
      as.character(e)
    })
    return(r)
  } else {
    # doesn't need to return anything.
    if(returnerr){
      warning(paste0("No connection available: ", cnxnname))
    }
  }
  invisible()
}

#' Get or Set Pool connection
#' @param constr connection string
#' @return a pool driver
#' @export
DBFactory_getsetpool = function(constr){
  if(!is.null(.DBFactoryEnv$pooldriver)) return(.DBFactoryEnv$pooldriver)

  #otherwise, create it and maintain it.
  assign('pooldriver', pool::dbPool(drv=odbc::odbc(),
                                    .connection_string = constr),
         pos =.DBFactoryEnv)
  invisible(.DBFactoryEnv$pooldriver)
}


#' Get or Set Pool connection Oracle version
#' @param constr connection string
#' @return a pool driver
#' @export
DBFactory_getsetpool_oracle = function(dbname,username,password){
  if(!is.null(.DBFactoryEnv$pooldriver)) return(.DBFactoryEnv$pooldriver)

  #otherwise, create it and maintain it.
  assign('pooldriver', pool::dbPool(drv=DBI::dbDriver('Oracle'),
                                    dbname=dbname,
                                    username=username,
                                    password=password),
         pos =.DBFactoryEnv)
  invisible(.DBFactoryEnv$pooldriver)
}

#' Close pool connection
#' @param returnerr whether to return error message
#' @export
DBFactory_closepool <- function(returnerr=T){
  tryCatch({
    pool::poolClose(.DBFactoryEnv$pooldriver)
    assign('pooldriver',value = NULL,pos = .DBFactoryEnv)
  }, error=function(e){
    if(returnerr) {
      message(e)
    }
    as.character(e)
  })
}

