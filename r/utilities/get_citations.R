get_citations<- function(conn, table)
{

  dbWriteTable(conn, name = 'tmp', table, overwrite = TRUE)

  tmp <- dbGetQuery(conn, 'SELECT pat_publn_id, appln_id
                    FROM tls211_pat_publn
                    WHERE appln_id IN (SELECT appln_id
                                      FROM tmp);')

  dbWriteTable(conn, name = 'tmp', tmp, overwrite = TRUE)

  # Get table containing citations of AI
  temp_citation<- dbGetQuery(conn, 'SELECT pat_publn_id AS citing_pat_publn_id, cited_appln_id, cited_pat_publn_id
                              FROM tls212_citation
                              WHERE cited_appln_id IN (SELECT appln_id
                                                      FROM tmp)
                              OR cited_pat_publn_id IN (SELECT pat_publn_id
                                                        FROM tmp);')

  # Select only distinct values
  temp_citation <- distinct(temp_citation)

  dbWriteTable(conn, name = 'tmp', temp_citation, overwrite = TRUE)

  # Get appln_id of citing patents # this query is wrong but I don't know why
  temp_citation<- dbGetQuery(conn, 'SELECT citing_pat_publn_id, appln_id AS citing_appln_id, cited_appln_id, cited_pat_publn_id
                                    FROM tmp
                                    INNER JOIN (SELECT pat_publn_id, appln_id
                                                FROM tls211_pat_publn) AS pat_pub
                                    ON tmp.citing_pat_publn_id = pat_pub.pat_publn_id;')

  # Drop remote table to optimize space
  dbExecute(conn, 'DROP TABLE tmp;')

  # Store in final df the obs that have already an appln_id associated
  citation<- temp_citation[temp_citation$cited_appln_id > 0,]

  # filter in temp df those that need another join
  temp_citation<- temp_citation[temp_citation$cited_appln_id == 0,]

  # Remove column containing zeros
  temp_citation$cited_appln_id <- NULL

  dbWriteTable(conn, name = 'tmp', temp_citation, overwrite = TRUE)

  # Get table containing matched publication ids
  temp_citation<- dbGetQuery(conn,
      'SELECT citing_pat_publn_id, citing_appln_id, pat_pub.appln_id AS cited_appln_id, cited_pat_publn_id
      FROM tmp
      INNER JOIN (SELECT pat_publn_id, appln_id
                    FROM tls211_pat_publn) AS pat_pub
      ON tmp.cited_pat_publn_id = pat_pub.pat_publn_id;')

  # Drop table to free up space in server
  dbExecute(conn, 'DROP TABLE tmp;')

  # Bind df together and filter for unique values
  citation <- rbind(citation, temp_citation)
  citation<- distinct(citation)

  return(citation)

}




