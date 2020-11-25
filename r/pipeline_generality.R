
# Load required libraries
library(dplyr)
library(tidyr)
library(readr)

# Create table containing matched patents
#tls240_ai_wipo <- data.frame(ai_appln = perfect$ai_appln, wipo_appln = perfect$wipo_appln)

# Save table into file
#save(tls240_ai_wipo, file = 'tls240_ai_wipo.rda')

# Load matching patents
load(file = "data/tls240_ai_wipo.rda")

# Split matching patents in two datasets
ai_patents <- data.frame(appln_id = tls240_ai_wipo$ai_appln)
nonai_patents <- data.frame(appln_id = tls240_ai_wipo$wipo_appln)

# Load csv files containing citation and publication information
tls212_citation<- read_csv(file = "data/patstat_merged/wipo_patents/tls212_citation.csv")
tls211_pat_publn<- read_csv(file = "data/patstat_merged/wipo_patents/tls211_pat_publn.csv")
tls224_appln_cpc<- read_csv(file = "data/patstat_merged/wipo_patents/tls224_appln_cpc.csv")

ai_patents_gen<- get_generality(ai_patents)
nonai_patents_gen<- get_generality(nonai_patents)



tls207_pers_appln<- read_csv(file = "data/patstat_merged/wipo_patents/tls207_pers_appln.csv")

# Select link pers appln AI
tls207_pers_appln_ai <- tls207_pers_appln[(tls207_pers_appln$appln_id %in% tls211_pat_publn_ai$appln_id) & (tls207_pers_appln$invt_seq_nr > 0),]

# Select link pers appln Wipo
tls207_pers_appln_wipo <- tls207_pers_appln[(tls207_pers_appln$appln_id %in% tls211_pat_publn_wipo$appln_id) & (tls207_pers_appln$invt_seq_nr > 0),]

# Select all applications of the inventors that cited an AI patent
derived_ai<- tls207_pers_appln[tls207_pers_appln$person_id %in% tls207_pers_appln_ai$person_id  & (tls207_pers_appln$invt_seq_nr > 0),]

# Select all applications of the inventors that cited a non-AI patent
derived_wipo <- tls207_pers_appln[tls207_pers_appln$person_id %in% tls207_pers_appln_wipo$person_id  & (tls207_pers_appln$invt_seq_nr > 0),]

# Count number of patents of each inventor
pers_patent_ai <- derived_ai %>%
                    group_by(person_id) %>%
                      count()

pers_patent_wipo <- derived_wipo %>%
                          group_by(person_id) %>%
                              count()


summary(pers_patent_ai$n)
sd(pers_patent_ai$n)

summary(pers_patent_wipo$n)
sd(pers_patent_wipo$n)

# Count number of inventors for each patent
patent_pers_ai <- derived_ai %>%
                    group_by(appln_id) %>%
                      count()

patent_pers_wipo <- derived_wipo %>%
                      group_by(appln_id) %>%
                          count()


summary(patent_pers_ai$n)
summary(patent_pers_wipo$n)



rm(tls207_pers_appln)

ai_patents <- data.frame(appln_id = tls240_ai_wipo$ai_appln)

ai_patents$citing_patent<- lapply(ai_patents$appln_id, function(x) citing_patent(x))

