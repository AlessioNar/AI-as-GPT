
get_applicants <- function(appln_ids){

  conn <- dbConnect(SQLite(), 'data/patstat_def/patstat.db')

  dbWriteTable(conn, value = appln_ids, name = 'temp_appln')

  pers_appln<- dbGetQuery(conn, 'SELECT appln_id, person_id
                                FROM tls207_pers_appln as pa
                                WHERE pa.appln_id IN (SELECT appln_id
                                                  FROM temp_appln)
                                AND applt_seq_nr > 0')


  dbExecute(conn, 'DROP TABLE temp_appln;')

  dbWriteTable(conn, name = 'temp_pers', pers_appln)

  applicants<- dbGetQuery(conn, 'SELECT *
                                FROM tls206_person as p
                                WHERE p.person_id IN (SELECT person_id
                                                      FROM temp_pers)')

  dbExecute(conn, 'DROP TABLE temp_pers;')

  dbDisconnect(conn)

  pers_appln <- inner_join(pers_appln, applicants, by = 'person_id')

  return(pers_appln)

}
