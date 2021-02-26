centralization<- function(graph){

  n_nodes <- gorder(graph)
  E(graph)$inv_weight <- 1/E(graph)$weight

  # Compute degree centralization
  max_weight_degree <- max(E(graph)$weight)
  node_degree <- strength(graph, weights = E(graph)$weight)
  max_degree <- (n_nodes-1) * (n_nodes-2) * max_weight_degree
  degree <- sum(max(node_degree)- node_degree)/max_degree

  max_weight <- max(E(graph)$inv_weight)

  # Compute betweenness centralization
  max_betweenness <- (((n_nodes^2) - 3*(n_nodes) + 2)/2)*(n_nodes - 1)*max_weight
  node_betweenness <- betweenness(graph, directed = FALSE, weights = E(graph)$inv_weight, normalize = FALSE)
  betweenness <- sum((max(node_betweenness) - node_betweenness))/max_betweenness

  # Compute closeness centralization
  max_closeness <- (((n_nodes^2) - (3*(n_nodes)) + 2)/(2*(n_nodes) - 3)) * max_weight
  node_closeness <- closeness(graph, weights = E(graph)$inv_weight, normalize = FALSE)
  closeness <- sum(max(node_closeness) - node_closeness)/max_closeness

  centrality_measures <- data.frame(degree = degree, betweenness = betweenness, closeness = closeness)

  return(centrality_measures)
}
