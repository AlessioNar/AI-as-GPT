# Function that creates a technological projection from an edgelist

get_technology_projection<- function(edgelist){

  edgelist$appln_filing_year <- NULL

  graph<- graph_from_data_frame(edgelist, directed = TRUE)

  V(graph)$type[V(graph)$name %in% edgelist$appln_id] <- TRUE
  V(graph)$type[!(V(graph)$name %in% edgelist$appln_id)] <- FALSE

  tech_graph<- bipartite_projection(graph, which = "false", multiplicity = TRUE)

  return(tech_graph)
}
