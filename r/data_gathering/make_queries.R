library(RSQLite)
library(readr)
library(dplyr)

query_codes<- read_csv('data/data_gathering/query_codes.csv')
keywords<- read_csv('data/data_gathering/keywords.csv')

query1 <- query_codes$class_code[query_codes$group == 'CPC1']

final_query <- ''

for (i in 1:length(query1))
{

  temp_query <- paste0("cpc.cpc_class_symbol LIKE '", query1[i])

  if(i < length(query1))
  {
    temp_query <- paste0(temp_query, "%' OR ")
  }
  else
  {
    temp_query <- paste0(temp_query, "%';")
  }

  final_query <- paste0(final_query, temp_query)
}

query1 <- paste0("SELECT DISTINCT cpc.appln_id FROM tls224_appln_cpc AS cpc WHERE (a.appln_auth = 'WO') AND (a.appln_filing_year BETWEEN 1995 AND 2017) AND ", final_query)

fileConn<-file("sql/query1.sql")
writeLines(query1, fileConn)
close(fileConn)


query2 <- keywords$words[keywords$group == 'KEY2']

final_query <- ''
for(i in 1:length(query2))
{
  temp_query <- paste0('"', query2[i], '"')
  if(i < length(query2))
  {
    temp_query <- paste0(temp_query, " OR ")
  }
  final_query <- paste0(final_query, temp_query)
}

print(final_query)

query2 <- paste0("SELECT DISTINCT ab.appln_id FROM tls203_appln_abstr as ab INNER JOIN tls201_appln as a ON ab.appln_id = a.appln_id INNER JOIN tls202_appln_title as t ON a.appln_id = t.appln_id WHERE a.appln_auth = 'WO' AND a.appln_filing_year BETWEEN 1995 AND 2017 AND (CONTAINS(ab.appln_abstract, '", final_query, "') OR CONTAINS(t.appln_title, '", final_query, "'));")

fileConn<-file("sql/query2.sql")
writeLines(query2, fileConn)
close(fileConn)


query3 <- keywords$words[keywords$group == 'KEY3']

keyword_query <- ''
for(i in 1:length(query3))
{
  temp_query <- paste0('"', query3[i], '"')
  if(i < length(query3))
  {
    temp_query <- paste0(temp_query, " OR ")
  }
  keyword_query <- paste0(keyword_query, temp_query)
}

query3 <- query_codes$class_code[query_codes$group == 'CPC3']

cpc_query <- ''

for (i in 1:length(query3))
{

  temp_query <- paste0("cpc.cpc_class_symbol LIKE '", query3[i])

  if(i < length(query3))
  {
    temp_query <- paste0(temp_query, "%' OR ")
  }
  else
  {
    temp_query <- paste0(temp_query, "%'")
  }

  cpc_query <- paste0(cpc_query, temp_query)
}

query3 <- query_codes$class_code[query_codes$group == 'IPC3']

ipc_query <- ''

for (i in 1:length(query3))
{

  temp_query <- paste0("ipc.ipc_class_symbol LIKE '", query3[i])

  if(i < length(query3))
  {
    temp_query <- paste0(temp_query, "%' OR ")
  }
  else
  {
    temp_query <- paste0(temp_query, "%'")
  }

  ipc_query <- paste0(ipc_query, temp_query)
}


query3 <- paste0("SELECT DISTINCT ab.appln_id FROM tls203_appln_abstr as ab INNER JOIN tls201_appln as a ON ab.appln_id = a.appln_id INNER JOIN tls202_appln_title as t ON a.appln_id = t.appln_id INNER JOIN tls224_appln_cpc AS cpc ON ab.appln_id = cpc.appln_id INNER JOIN tls209appln_ipc AS ipc ON ab.appln_id = ipc.appln_id WHERE (a.appln_auth = 'WO') AND (a.appln_filing_year BETWEEN 1995 AND 2017) AND ((", cpc_query,") OR (", ipc_query,")) AND (CONTAINS(ab.appln_abstract, '", keyword_query, "') OR CONTAINS(t.appln_title, '", keyword_query, "'));")

fileConn<-file("sql/query3.sql")
writeLines(query3, fileConn)
close(fileConn)

conn <- dbConnect(SQLite(), 'data/patstat_def/patstat.db')

result_query1<- dbGetQuery(conn, query1)
result_query2<- dbGetQuery(conn, query2)
result_query3<- dbGetQuery(conn, query3)

names(result_query1) <- 'appln_id'
names(result_query2) <- 'appln_id'
names(result_query3) <- 'appln_id'

ai_patents <- rbind(result_query1, result_query2, result_query3)

ai_patents <- distinct(ai_patents)

save(ai_patents, 'data/data_gathering/ai_patents.rda')
