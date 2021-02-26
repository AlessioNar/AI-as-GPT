
get_network_evolution<- function(tech_class_year){

  new_connections <- data.frame()

  min_year <- min(tech_class_year$appln_filing_year)
  max_year <- max(tech_class_year$appln_filing_year)

  for(i in min_year:max_year)
  {
    # Select only pairs of the current year
    temp <- tech_class_year[tech_class_year$appln_filing_year <= i,]

    # Get the technology projection
    graph <- get_technology_projection(temp)

    n_edges <-  gsize(graph)
    n_nodes <-  gorder(graph)
    triangles<- sum(count_triangles(graph)/3)
    avg_weighted_degree <- mean(graph.strength(graph, mode = 'total', weights = E(graph)$weight))
    density <- edge_density(graph)
    transitivity <- transitivity(graph, type = 'global')

    # Obtain degree, betweenness and closeness centralization
    centralities<- centralization(graph)

      if(i == min_year)
      {
        new_edges <- 0
        edge_growth <- 0
        new_nodes <- 0
        nodes_growth <- 0
        avg_weight_growth <- 0
        triangles_growth <- 0
      }
      else
      {

        new_edges <- length(E(difference(graph, old_graph)))
        edge_growth <- (n_edges - gsize(old_graph))/gsize(old_graph)

        new_nodes <- n_nodes - gorder(old_graph)
        nodes_growth <-  (n_nodes - gorder(old_graph))/gorder(old_graph)

        intersected <- intersection(graph, old_graph, keep.all.vertices = FALSE)
        avg_weight_growth <- mean((E(intersected)$weight_1 - E(intersected)$weight_2)/E(intersected)$weight_2)

        triangles_growth<- (sum(count_triangles(graph)/3) - sum(count_triangles(old_graph)/3))/sum(count_triangles(old_graph)/3)

      }

    temp_year <- data.frame(year = i, n_edges = n_edges, n_nodes = n_nodes,
                            degree = centralities$degree,
                            betweenness = centralities$betweenness,
                            closeness = centralities$closeness,

                            new_edges = new_edges, edge_growth = edge_growth,
                            new_nodes = new_nodes, nodes_growth = nodes_growth,

                            avg_weight_growth = avg_weight_growth,
                            triangles = triangles,
                            avg_weighted_degree = avg_weighted_degree,
                            triangles_growth = triangles_growth,
                            density = density,
                            transitivity = transitivity)

    new_connections <- rbind(new_connections, temp_year)
    old_graph <- graph
  }

  return(new_connections)

}

