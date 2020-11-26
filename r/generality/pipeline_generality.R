
# Load required libraries
library(dplyr)
library(tidyr)
library(readr)
library(parallel)

# Load matching patents
load(file = "data/tls240_ai_wipo.rda")

# Split matching patents in two datasets
ai_patents <- data.frame(appln_id = tls240_ai_wipo$ai_appln)
nonai_patents <- data.frame(appln_id = tls240_ai_wipo$wipo_appln)

# Load csv files containing citation and publication information
tls212_citation<- read_csv(file = "data/patstat_merged/wipo_patents/tls212_citation.csv")
tls211_pat_publn<- read_csv(file = "data/patstat_merged/wipo_patents/tls211_pat_publn.csv")

# Identify forward citations
ai_patents<- forward_citations(ai_patents)
nonai_patents<- forward_citations(nonai_patents)

# Remove tables to free up space
rm(tls212_citation)
rm(tls211_pat_publn)

# Read table containing application-CPC association
tls224_appln_cpc<- read_csv(file = "data/patstat_merged/wipo_patents/tls224_appln_cpc.csv")

# Create sub-strings
tls224_appln_cpc$cpc_class_symbol <- substring(tls224_appln_cpc$cpc_class_symbol, 1,3)

# Select only unique application-CPC pairs
tls224_appln_cpc<- distinct(tls224_appln_cpc)

# subset the tls224_appln_cpc table to reduce occupied memory space
ai_cpc<- tls224_appln_cpc[tls224_appln_cpc$appln_id %in% unlist(ai_patents$citing_appln_id),]
nonai_cpc<- tls224_appln_cpc[tls224_appln_cpc$appln_id %in% unlist(nonai_patents$citing_appln_id),]

# remove tls224_appln_cpc to free up space
rm(tls224_appln_cpc)

# Compute generality index using custom parallel function (it may take a while)
ai_patents<- parGenerality(patents = ai_patents, cpc_table = ai_cpc)
nonai_patents<- parGenerality(patents = nonai_patents, cpc_table = nonai_cpc)

# Compute summary statistics
summary(ai_patents$generality)
summary(nonai_patents$generality)
