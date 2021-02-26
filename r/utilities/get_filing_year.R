get_filing_year<- function(appln_id){

  names(appln_id) <- 'appln_id'

  appln_id$appln_id <- as.integer(appln_id$appln_id)

  conn <- dbConnect(SQLite(), 'data/patstat_def/patstat.db')

  dbWriteTable(conn, name = 'tmp', appln_id, overwrite = TRUE)

  year<- dbGetQuery(conn, 'SELECT appln_id, appln_filing_year
                      FROM tls201_appln
                      WHERE appln_id in (SELECT appln_id
                                          FROM tmp)')

  dbExecute(conn, 'DROP TABLE tmp;')

  dbDisconnect(conn)

  year$appln_id <- as.integer(year$appln_id)

  return(year)
}

