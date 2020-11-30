forward_citations<- function(patents){

  # Get citing patents
  patents<- get_citing(patents)

  # Select only distinct pairs of appln ids
  patents <- distinct(patents[,c(1,4)])

  # Group forward citations by original patent and summarize them in a list
  patents<- patents %>%
              group_by(cited_appln_id) %>%
                summarize(citing_appln_id = list(citing_appln_id))

  return(patents)
}
