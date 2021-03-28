library(RSQLite)
library(dplyr)

conn <- dbConnect(SQLite(), 'data/patstat_def/patstat.db')

dbListTables(conn)

temp_citing <- data.frame(appln_id = unique(ai_citations$CITING_APPLN_ID))

# Obtain the pat_publn_id of citing patents
dbWriteTable(conn, name = 'temp_citing', temp_citing, overwrite = TRUE)

temp_citing<- dbGetQuery(conn, 'SELECT tmp.appln_id AS appln_id, pp.pat_publn_id AS pat_publn_id
                                  FROM temp_citing AS tmp
                                  JOIN tls211_pat_publn AS pp
                                  ON tmp.appln_id = pp.appln_id')

# Get all citations received by AI-citing patents
dbWriteTable(conn, name = 'temp_citing', temp_citing, overwrite = TRUE)

temp_citing<- dbGetQuery(conn, 'SELECT cited_appln_id, cited_pat_publn_id
                                FROM tls212_citation
                                WHERE pat_publn_id IN (SELECT pat_publn_id
                                                        FROM temp_citing)')

temp_citing <- distinct(temp_citing)

control_appln <- temp_citing[temp_citing$cited_appln_id > 0,]
temp_citing <- temp_citing[temp_citing$cited_pat_publn_id > 0,]

# Convert all citations that use pat_publn_id to appln id
dbWriteTable(conn, name = 'temp_citing', temp_citing, overwrite = TRUE)


temp_citing<- dbGetQuery(conn, 'SELECT tmp.cited_pat_publn_id AS pat_publn_id, pp.appln_id AS appln_id
                                  FROM temp_citing AS tmp
                                  JOIN tls211_pat_publn AS pp
                                  ON tmp.cited_pat_publn_id = pp.pat_publn_id')

names(control_appln) <- c('appln_id', 'pat_publn_id')

control <- rbind(control_appln, temp_citing)

# Remove all AI applications from the control sample
control <- control[!(control$appln_id %in% ai_citations$CITED_APPLN_ID),]

control <- data.frame(appln_id = control$appln_id)

control <- unique(control)

dbDisconnect(conn)

save(control, file = 'data/control_sample/control.rda')

dbWriteTable(conn, name = 'control', control, overwrite = TRUE)

dbExecute(conn, 'CREATE TABLE temp AS
                SELECT *
                FROM tls212_citation
                WHERE cited_appln_id > 0;')

citing_appln_id<- dbGetQuery(conn, 'SELECT cit.pat_publn_id as citing_pat_publn, c.appln_id as cited_appln_id
                  FROM control as c
                  INNER JOIN temp as cit
                  ON c.appln_id = cit.cited_appln_id;')

save(citing_appln_id, file = 'data/control_sample/citing_appln_id.rda')

dbExecute(conn,'DROP TABLE temp;')

pat_publn<- dbGetQuery(conn, 'SELECT pp.pat_publn_id as pat_publn_id, c.appln_id as cited_appln_id
                  FROM control as c
                  INNER JOIN tls211_pat_publn as pp
                  ON c.appln_id = pp.appln_id;')

dbWriteTable(conn, name = 'publn_control', pat_publn)

dbExecute(conn, 'CREATE TABLE temp AS
                SELECT *
                FROM tls212_citation
                WHERE cited_pat_publn_id > 0;')

citing_pat_publn<- dbGetQuery(conn, '
CREATE TABLE control_pat_publn AS
SELECT pat_publn_id as citing_pat_publn, cited_pat_publn_id, cited_appln_id
                                      FROM temp
                                      WHERE cited_pat_publn_id IN (SELECT pat_publn_id
                                                                  FROM publn_control);')

citing_pat_publn <- dbGetQuery(conn, 'SELECT * FROM control_pat_publn')
tls211_pat_publn<- dbGetQuery(conn, 'SELECT pat_publn_id, appln_id
                                            FROM tls211_pat_publn')

citing_pat_publn <- inner_join(citing_pat_publn, tls211_pat_publn,
                               by = c('cited_pat_publn_id' = 'pat_publn_id'))

citing_pat_publn <- citing_pat_publn[,c(1,3)]

names(citing_pat_publn) <- c('citing_pat_publn_id', 'cited_appln_id')
names(citing_appln_id) <- c('citing_pat_publn_id', 'cited_appln_id')

save(citing_pat_publn, file = 'data/control_sample/citing_pat_publn.rda')

citing_pat_publn$citing_pat_publn_id <- as.integer(citing_pat_publn$citing_pat_publn_id)
citing_pat_publn$cited_appln_id <- as.integer(citing_pat_publn$cited_appln_id)

rm(citing_appln_id)

tls211_pat_publn$pat_publn_id <- as.integer(tls211_pat_publn$pat_publn_id)
tls211_pat_publn$appln_id <- as.integer(tls211_pat_publn$appln_id)

citing_pat_publn <- distinct(citing_pat_publn)

citing_pat_publn <- inner_join(citing_pat_publn, tls211_pat_publn, by = c('citing_pat_publn_id'='pat_publn_id'))

citing_pat_publn <- citing_pat_publn[,c('appln_id', 'cited_appln_id')]
names(citing_pat_publn) <- c('citing_appln_id', 'cited_appln_id')

citing_pat_publn <- rbind(citing_pat_publn, citing_appln_id)
control_citations <- citing_pat_publn

save(control_citations, file = 'data/control_sample/control_citations.rda')

control_citations <- control_citations %>%
                        group_by(cited_appln_id) %>%
                        summarize(citing_appln_id = list(citing_appln_id))

