prepare_matching <- function(citations)
{
  citations<- citations %>%
    group_by(cited_appln_id) %>%
    summarize(n_cit = length(citing_appln_id))

  tmp_year <- get_filing_year(citations[,1])

  citations$cited_appln_id <- as.integer(citations$cited_appln_id)

  citations <- inner_join(citations, tmp_year, by = c('cited_appln_id'='appln_id'))

  return(citations)

}
