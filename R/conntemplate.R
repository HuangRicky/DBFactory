# this file is for connstring template.

#' get connection string template
#' @description no need to export.
#' @export
get_connstr_template <- function(x, ...){
  # x is a list.
  UseMethod('get_connstr_template', x)
}
get_connstr_template.default <- function(x, ...){
  stop("Not implemented conn str template")
}
get_connstr_template.sqlserver <- function(x, ...){
  # prefer odbc
  if(!is.null(x$connstring) && !is.na(x$connstring) && (trimws(x$connstring)!='')){
    return(x$connstring)
  }
  pref <- x$preferred

  if(x$is_odbc_exist){
    driverlist <- odbc::odbcListDrivers()
    if (any('ODBC Driver 17 for SQL Server' %in% driverlist$name) ) {
      mydrv <- 'ODBC Driver 17 for SQL Server'
    } else if (any('ODBC Driver 13 for SQL Server' %in% driverlist$name) ) {
      mydrv <- 'ODBC Driver 13 for SQL Server'
    } else if (any('ODBC Driver 11 for SQL Server' %in% driverlist$name) ) {
      mydrv <- 'ODBC Driver 11 for SQL Server'
    } else {
      mydrv <- 'SQL Server'
    }
  } else {
    if(is.null(pref)){
      mydrv <- 'SQL Server'
    } else {
      mydrv <- paste0('ODBC Driver 17 for SQL Server')
    }
  }
  initstr <- ifelse(is.null(x$InitDB), '', paste0('DataBase=',x$InitDB,';'))
  userpassstr <- ifelse(is.null(x$User) || is.na(x$User) || x$User == '', 'Trusted_Connection=yes;',
                        paste0('uid=',x$User,';pwd=',x$Password,';'))
  constr <- paste('DRIVER={',mydrv,'};SERVER={',x$DatabaseServer,'};',initstr,userpassstr,sep='')
  constr

}

get_connstr_template.mysql <- function(x, ...){
  # prefer odbc
  if(!is.null(x$connstring) && !is.na(x$connstring) && (trimws(x$connstring)!='')){
    return(x$connstring)
  }
  pref <- x$preferred

  if(x$is_odbc_exist){
    driverlist <- odbc::odbcListDrivers()
    if (any('MySQL ODBC 8.0 ANSI Driver' %in% driverlist$name) ) {
      mydrv <- 'MySQL ODBC 8.0 ANSI Driver'

    } else {
      mydrv <- 'SQL Server'
    }
  } else {
    if(is.null(pref)){
      mydrv <- 'SQL Server'
    } else {
      mydrv <- paste0('MySQL ODBC 8.0 ANSI Driver')
    }
  }
  # Server=myServerAddress;Port=1234;Database=myDataBase;Uid=myUsername;Pwd=myPassword;
  initstr <- ifelse(is.null(x$InitDB), '', paste0('DataBase=',x$InitDB,';'))
  userpassstr <- paste0('Uid=',x$User,';Pwd=',x$Password,';')
  constr <- paste('DRIVER={',mydrv,'};Server={',x$DatabaseServer,'};Port=3306;',initstr,userpassstr,sep='')
  constr

}


get_connstr_template.sybaseiq <- function(x, ...){
  # prefer odbc
  if(!is.null(x$connstring) && !is.na(x$connstring) && (trimws(x$connstring)!='')){
    return(x$connstring)
  }


  if(x$is_odbc_exist){
    driverlist <- odbc::odbcListDrivers()
    if (any('Sybase IQ' %in% driverlist$name) ) {
      mydrv <- 'Sybase IQ'

    } else {
      mydrv <- 'Sybase IQ'
    }
  } else {
    if(is.null(pref)){
      mydrv <- 'Sybase IQ'
    } else {
      mydrv <- paste0('Sybase IQ')
    }
  }

  constr <- paste('Driver={',mydrv,'};CommLinks=SharedMemory,TCPIP{host=',x$DatabaseServer,'};ServerName=',x$InitDB,';UID=',x$User,';PWD=',x$Password,';',sep="")
  constr

}
