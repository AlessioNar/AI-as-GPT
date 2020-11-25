get_citing<- function(seed_patents){

  seed_patents <- inner_join(seed_patents, tls211_pat_publn, by = ("appln_id" = "appln_id"))

  seed_patents <- distinct(seed_patents[,c(1:2)])

  citations<- tls212_citation[,c(1, 5, 6)]

  citing_pat <- inner_join(seed_patents, citations[,c(1,2)], by=c("pat_publn_id" = "cited_pat_publn_id"))

  names(citing_pat) <- c("cited_appln_id", "cited_pat_publn_id", "citing_pat_publn_id")

  citing_appln <- inner_join(seed_patents, citations[c(1,3)], by=c("appln_id" = "cited_appln_id"))

  names(citing_appln) <- c("cited_appln_id", "cited_pat_publn_id", "citing_pat_publn_id")

  citing <- rbind(citing_appln, citing_pat)

  citing <- distinct(citing)

  citing <- left_join(citing, tls211_pat_publn[,c(1,6)], by = c("citing_pat_publn_id" = "pat_publn_id"))

  names(citing) <- c("cited_appln_id", "cited_pat_publn_id", "citing_pat_publn_id", "citing_appln_id")

  return(citing)

}
