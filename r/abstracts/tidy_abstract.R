
tls211_pat_publn <- read_csv("data/patstat_merged/ai_patents/tls211_pat_publn.csv",
                             col_types = cols(.default = 'c'))

tls211_pat_publn$docdb_id <- paste0(tls211_pat_publn$publn_auth,
                                    tls211_pat_publn$publn_nr,
                                    tls211_pat_publn$publn_kind)

abstracts <- left_join(abstracts, tls211_pat_publn, by = 'docdb_id')

abstracts<- abstracts[!duplicated(abstracts$appln_id),]
abstracts <- data.frame(appln_id = abstracts[['appln_id']], abstract = abstracts[['abstract']])

save(abstracts, file = 'abstracts_cleaned.rda')


