library(RSQLite)
library(dplyr)

source('r/utilities/get_citations.R')

conn <- dbConnect(SQLite(), 'data/patstat_def/patstat.db')

load('data/data_gathering/ai_patents.rda')

# Get citations table for AI and non-AI applications
ai_citations <- get_citations(conn, ai_patents)

dbDisconnect(conn)

# Select only two columns
ai_citations <- ai_citations[,c('cited_appln_id', 'citing_appln_id')]

# Filter for unique values
ai_citations <- distinct(ai_citations)

save(ai_citations, file = 'data/generality/ai_citations.rda')

