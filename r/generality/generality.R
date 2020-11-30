# function to compute generality
generality<- function(citing_patents, cpc_table){

  # unlist citing patents
  citing_patents<- data.frame(appln_id = unlist(citing_patents))

  # Select CPC symbols associated with citing patents
  appln_cpc<- inner_join(citing_patents, cpc_table, by = "appln_id")

  # Count number of occurrences for each symbol
  cpc_counts <- appln_cpc %>%
                  group_by(cpc_class_symbol) %>%
                    count()

  # Compute generality
  generality<- 1-sum((cpc_counts$n/sum(cpc_counts$n))^2)

  return(generality)
}

