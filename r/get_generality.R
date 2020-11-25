get_generality<- function(patents){

  # Get citing patents
  patents<- get_citing(patents)

  # Select only distinct pairs of appln ids
  patents <- distinct(patents[,c(1,4)])

  print("Forward citations extracted")

  # Group forward citations by original patent and summarize them in a list
  patents<- patents %>%
    group_by(cited_appln_id) %>%
    summarize(citing_appln_id = list(citing_appln_id))

  # Create sub-strings
  tls224_appln_cpc$cpc_class_symbol <- substring(tls224_appln_cpc$cpc_class_symbol, 1,3)

  # Select only unique application-CPC pairs
  tls224_appln_cpc<- distinct(tls224_appln_cpc)

  print("Generality computation initiated")

  # Compute generality
  patents$generality<- sapply(patents$citing_appln_id, function(x) compute_generality(x), simplify = 'vector')

  return(patents)

}
