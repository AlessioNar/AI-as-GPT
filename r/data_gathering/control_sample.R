library(dplyr)
library(RSQLite)
library(MatchIt)

set.seed(1234)

source('r/utilities/get_filing_year.R')
source('r/data_gathering/prepare_matching.R')

load('data/generality/ai_citations.rda')

names(ai_citations) <- c('cited_appln_id', 'citing_appln_id')

ai_citations <- prepare_matching(ai_citations)

load('data/all_patents/citation_table.rda')

citation_table <- prepare_matching(citation_table)

# Remove AI patents from the remaining PCT patents
citation_table <- citation_table[!(citation_table$cited_appln_id %in% ai_citations$cited_appln_id),]

# I arrived here
matched <- data.frame()

for (i in 1995:2017)
{
  # Reduce matching to only patents of the same year
  temp_ai <- ai_citations[ai_citations$appln_filing_year == i,]
  temp_wipo <- citation_table[citation_table$appln_filing_year == i,]
  temp_ai$group <- TRUE
  temp_wipo$group <- FALSE

  temp_year <- rbind(temp_ai, temp_wipo)

  match.it <- matchit(group ~ n_cit, data = temp_year, method="nearest", ratio=1)
  df.match <- match.data(match.it)
  df.match <- df.match[,c('cited_appln_id', 'group','subclass')]

  n_ai <- nrow(temp_ai)

  temp_ai<- df.match[1:n_ai,]
  temp_wipo <- df.match[(n_ai +1):nrow(df.match),]

  temp_matched <- inner_join(temp_ai, temp_wipo, by = 'subclass')

  matched <- rbind(matched, temp_matched)

  print(i)
}

matched <- matched[,c('cited_appln_id.x', 'cited_appln_id.y')]

names(matched) <- c('ai_patents', 'control_patents')

load('data/all_patents/citation_table.rda')

control_citations <- citation_table[citation_table$cited_appln_id %in% matched$control_patents,]

save(control_citations, file = 'data/control_sample/control_matchit.rda')
