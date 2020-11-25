library(parallel)

# Make cluster of cores
cl<- makeCluster(spec = 4)

# Export segment_cpc function
parallel::clusterExport(cl = cl, varlist = c('segment_cpc'),
                        envir = .GlobalEnv)

# I parallelize the function to improve efficiency
WIPO_PATENTS$seg_cpc<- parLapply(cl, WIPO_PATENTS$cpc,
                                           segment_cpc)

# I parallelize the function to improve efficiency
AI_PATENTS$seg_cpc <- parLapply(cl, AI_PATENTS$cpc,
                                      segment_cpc)

# Stop cluster
stopCluster(cl)

save(WIPO_PATENTS, file = 'WIPO_PATENTS_CPC_SEGMENTED.rda')
save(AI_PATENTS, file = 'AI_PATENTS_CPC_SEGMENTED.rda')

