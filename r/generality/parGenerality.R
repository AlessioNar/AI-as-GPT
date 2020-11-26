
parGenerality<- function(patents, cpc_table){

  # Detect number of cores available
  no_cores <- detectCores() - 1

  # Start cluster
  cl <- makeCluster(no_cores)

  # Export functions and variables
  clusterExport(cl = cl, varlist = c("generality", "inner_join", "group_by", "%>%", "count"))
  clusterExport(cl = cl, varlist = c("cpc_table"), envir = environment())

  # Compute generality
  patents$generality<- parSapply(cl = cl, patents$citing_appln_id, function(x) generality(x, cpc_table), simplify = 'vector')

  stopCluster(cl)

  return(patents)

}



