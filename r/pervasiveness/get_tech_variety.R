get_tech_variety<- function(appln_id, type){

  tech_table<- get_tech_class(patents = appln_id, type = type)

  names(tech_table) <- c('appln_id', 'tech_code')

  tech_table$tech_code <- substring(tech_table$tech_code, 1, 4)

  tech_table <- distinct(tech_table)

  conn <- dbConnect(SQLite(), 'data/patstat_def/patstat.db')

  dbWriteTable(conn, name = 'tmp', tech_table)

  year<- dbGetQuery(conn, 'SELECT appln_id, appln_filing_year
                      FROM tls201_appln
                      WHERE appln_id in (SELECT appln_id
                                          FROM tmp)')

  dbExecute(conn, 'DROP TABLE tmp;')

  dbDisconnect(conn)

  tech_table <- inner_join(tech_table, year, by = 'appln_id')

  tech_table <- tech_table %>%
    group_by(appln_filing_year) %>%
    count(tech_code)

  tech_table <- tech_table[tech_table$n > 1,]

  tech_variety<- tech_table %>%
    group_by(appln_filing_year) %>%
    count()

  return(tech_variety)

}
