generality<- function(cited, citing, tech_class, weighted = FALSE){

  # Unlist citing patents
  citing <- unlist(citing)

  # If there is only one forward citation, then generality equals zero
  if(length(citing) == 1){
    gen <- 0
  } else{

  if(weighted == TRUE){
    names(tech_class) <- c('APPLN_ID', 'TECH_CLASS', 'WEIGHT')
    # Select technical fields associated with the citing patents
    tech_class <- tech_class[(tech_class$APPLN_ID %in% citing),]
  } else{

    names(tech_class) <- c('APPLN_ID', 'TECH_CLASS')
    # Select technology classifications associated with citing patents
    tech_class <- tech_class$TECH_CLASS[tech_class$APPLN_ID %in% citing]
  }

  # If there are no technology classifications associated with citing patents
  # then generality is not defined
  if(is_empty(tech_class)){
    gen = NA
  } else{

  s <- c()

  if(weighted == TRUE){
    # select unique technological fields
    n_tech_class <- unique(tech_class$TECH_CLASS)

    for (i in 1:length(n_tech_class)){

        N_ij <- sum((tech_class$TECH_CLASS %in% n_tech_class[i]) *
                    (tech_class$WEIGHT[tech_class$TECH_CLASS %in% n_tech_class[i]]))
        s[i]<- (N_ij/length(tech_class$TECH_CLASS))^2

    }


    gen <- 1-sum(s)
    # bias correction as proposed by Hall (2005)
    if(length(tech_class$TECH_CLASS) >= 2){
      gen <- gen * (length(tech_class$TECH_CLASS)/(length(tech_class$TECH_CLASS)-1))
    }

  } else{

  n_tech_class <- unique(tech_class)

  for (i in 1:length(n_tech_class)){
      N_ij <- sum(tech_class %in% n_tech_class[i])
      s[i]<- (N_ij/length(tech_class))^2
    }


        gen <- 1-sum(s)
        # bias correction as proposed by Hall (2005)
        if(length(tech_class) >= 2){
          gen <- gen * (length(tech_class)/(length(tech_class)-1))
        }

  }



}

}
  return(gen)
}

