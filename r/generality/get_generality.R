# This function is the  'gatekeeper' of generality computation

get_generality<- function(citations, what, weighted = FALSE){

  # select unique citing technological classes
  citing_id <- data.frame(appln_id = unique(citations$CITING_APPLN_ID))

  # Restore previous data struture
  citations <- citations %>%
                      group_by(CITED_APPLN_ID) %>%
                        summarize(CITING_APPLN_ID = list(CITING_APPLN_ID))


  if (what == 'ipc' | what == 'cpc'){

    # get technological codes for citing applications
    tech_class<- get_tech_class(patents = citing_id, type = what)

    names(tech_class) <- c('APPLN_ID', 'TECH_CLASS')

    # Create sub-strings
    tech_class$TECH_CLASS <- substring(tech_class$TECH_CLASS, 1, 4)

    # Select only unique application-classification pairs
    tech_class<- distinct(tech_class)

    # Detect number of cores available
    no_cores <- detectCores() - 1

    # Compute generality
    citations$generality<- mcmapply(function(x, y) generality(cited = x, citing = y, tech_class = tech_class),
                               x = citations$CITED_APPLN_ID, y = citations$CITING_APPLN_ID, SIMPLIFY = 'vector',
                               mc.cores = no_cores, mc.cleanup = TRUE)

  }

  if(what == 'tech_field'){

    # get technological codes for citing applications
    tech_class<- get_tech_class(patents = citing_id, type = what)

    # Detect number of cores available
    no_cores <- detectCores() - 1

    # Compute generality
    citations$generality<- mcmapply(function(x, y) generality(cited = x, citing = y, tech_class = tech_class, weighted = weighted),
                               x = citations$CITED_APPLN_ID, y = citations$CITING_APPLN_ID, SIMPLIFY = 'vector',
                               mc.cores = no_cores, mc.cleanup = TRUE)
  }

  if(what == 'nace'){

    # get technological codes for citing applications
    citing_nace<- get_nace2(appln_id = citing_id)

    # Detect number of cores available
    no_cores <- detectCores() - 1

    # Compute generality
    citations$generality<- mcmapply(function(x, y) generality(cited = x, citing = y, tech_class = citing_nace),
                                    x = citations$CITED_APPLN_ID, y = citations$CITING_APPLN_ID, SIMPLIFY = 'vector',
                                    mc.cores = no_cores, mc.cleanup = TRUE)

  }

  return(citations)
}
