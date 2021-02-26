library(RSQLite)
library(dplyr)
library(tidyr)
library(parallel)
library(rlang)
library(ggplot2)
library(reshape)


# Load functions
source('r/generality/generality.R')
source('r/generality/get_generality.R')
source('r/generality/plot_generality.R')
source('r/utilities/get_tech_class.R')
source('r/utilities/get_nace2.R')
source('r/utilities/get_filing_year.R')

# Load citation tables
load('data/generality/ai_citations.rda')
load('data/control_sample/control_matchit.rda')
names(control_citations) <- c('CITING_APPLN_ID', 'CITED_APPLN_ID')

# Compute generality index for four classifications
ipc <- get_generality(ai_citations,  what = 'ipc')
cpc <- get_generality(ai_citations,  what = 'cpc')
tech_field <- get_generality(ai_citations,  what = 'tech_field')
nace <- get_generality(ai_citations,  what = 'nace')



# bind columns together
gen<- cbind(ipc[,1:3],cpc[,3], tech_field[,3], nace[,3])
rm(ipc, cpc, tech_field, nace)
names(gen) <- c('appln_id', 'citing','ipc', 'cpc', 'tech_field', 'nace')
# Get filing year
filing_year <- get_filing_year(as.data.frame(gen[,1]))
gen<- inner_join(gen, filing_year, by ='appln_id')

# Save file
save(gen, file = 'data/generality/ai_generality.rda')

# Replicate with control sample
ipc_cont <- get_generality(control_citations,  what = 'ipc')
cpc_cont <- get_generality(control_citations,  what = 'cpc')
tech_field_cont <- get_generality(control_citations,  what = 'tech_field')
nace_cont <- get_generality(control_citations,  what = 'nace')


gen_cont<- cbind(ipc_cont[,1:3],cpc_cont[,3], tech_field_cont[,3], nace_cont[,3])
rm(ipc_cont, cpc_cont, tech_field_cont, nace_cont)
names(gen_cont) <- c('appln_id', 'citing','ipc', 'cpc', 'tech_field', 'nace')

# Get filing year
filing_year <- get_filing_year(as.data.frame(gen_cont[,1]))
gen_cont$appln_id <- as.integer(gen_cont$appln_id)
gen_cont<- inner_join(gen_cont, filing_year, by ='appln_id')

# Save file
save(gen_cont, file = 'data/generality/cont_generality.rda')

df<- get_avg_gen(gen, 'ipc', rm.single = TRUE)
get_avg_gen(gen, 'cpc', rm.single = TRUE)
get_avg_gen(gen, 'tech_field', rm.single = TRUE)
get_avg_gen(gen, 'nace', rm.single = TRUE)

get_var_gen(gen)

draw_graph(gen, gen_cont, which = 'ipc', y_axis = 'IPC generality index', what = 'mean', rm.single = TRUE)
draw_graph(gen, gen_cont, 'cpc', y_axis = 'CPC generality index', what = 'mean', rm.single = TRUE)
draw_graph(gen, gen_cont, 'tech_field', y_axis = 'HJT generality index', what = 'mean', rm.single = TRUE)
draw_graph(gen, gen_cont, 'nace', y_axis = 'NACE v.2 generality index', 'mean', rm.single = TRUE)

draw_graph(gen,  y_axis = 'Standard Deviation', what = 'variability', rm.single = TRUE)


