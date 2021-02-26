library(dplyr)
library(reshape)
library(igraph)
library(tidyr)
library(RSQLite)
library(xtable)
library(ggplot2)

source('r/utilities/get_tech_class.R')
source('r/utilities/get_filing_year.R')
source('r/network_analysis/get_technology_projection.R')
source('r/network_analysis/get_tech_edgelist.R')
source('r/network_analysis/get_network_evolution.R')
source('r/network_analysis/centralization.R')
source('r/network_analysis/plot_network.R')


load(file = 'data/data_gathering/ai_patents.rda')

# Get network measures
cpc_edgelist <- get_tech_edgelist(ai_patents, type = 'cpc')

filing_year <- get_filing_year(ai_patents)

cpc_edgelist <- inner_join(cpc_edgelist, filing_year, by ='appln_id')

network_evolution<- get_network_evolution(cpc_year)

plot_measures(network_evolution, column = 'density', y_axis = 'Edge density')
plot_measures(network_evolution, column = 'transitivity', y_axis = 'Global transitivity')
plot_measures(network_evolution, column = 'degree', y_axis = 'Degree centralization')
plot_measures(network_evolution, column = 'betweenness', y_axis = 'Betweenness centralization')
plot_measures(network_evolution, column = 'closeness', y_axis = 'Closeness centralization')
plot_measures(network_evolution, column = 'new_edges', y_axis = 'New edges')
plot_measures(network_evolution, column = 'edge_growth', y_axis = 'New/existing edges ratio')
plot_measures(network_evolution, column = 'avg_weighted_degree', y_axis = 'Avg. weighted degree')
plot_measures(network_evolution, column = 'avg_weight_growth', y_axis = 'Avg. growth rate of edge weights')
plot_measures(network_evolution, column = 'new_nodes', y_axis = 'New nodes')
plot_measures(network_evolution, column = 'triangles', y_axis = 'N. triangles')
plot_measures(network_evolution, column = 'triangles_growth', y_axis = 'Triangles growth rate')
plot_measures(network_evolution, column = 'nodes_growth', y_axis = 'Nodes growth')
plot_measures(network_evolution, column = 'n_nodes', y_axis = 'N. nodes')
plot_measures(network_evolution, column = 'n_edges', y_axis = 'N. edges')
