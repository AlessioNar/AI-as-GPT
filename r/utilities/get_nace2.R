get_nace2 <- function(appln_id){

  load(file = 'data/cpc_codes/ipc_nace2.rda')

  # get technological codes for citing applications
  cit_tech<- get_tech_class(patents = appln_id, type = 'ipc')

  # Take out the concordances with more than 4-digits
  special <- ipc_nace_concordance[!nchar(ipc_nace_concordance$IPCV2015) == 4,]

  matches <- data.frame()

  for(i in 1:nrow(special)){

    # Select the patents matching these special concordances
    temp_match<- cit_tech[grep(special$IPCV2015[i], cit_tech$ipc_class_symbol),]

    if(nrow(temp_match) > 0){
      temp_match$NACE2 <- special$NACE2[i]
      matches <- rbind(matches, temp_match)
    }
  }

  # Take these pairs out of the main dataframe
  cit_tech<- cit_tech[!(cit_tech$ipc_class_symbol %in% matches$ipc_class_symbol),]

  cit_tech$ipc_class_symbol <- substring(cit_tech$ipc_class_symbol, 1, 4)

  # Join tables by 4-digits IPC
  cit_tech<- inner_join(cit_tech,ipc_nace_concordance[,c(1,2)], by = c('ipc_class_symbol'='IPCV2015'))

  # Match concordance table
  cit_tech <- rbind(cit_tech, matches)

  # Remove IPC column
  cit_tech$ipc_class_symbol <- NULL
  cit_tech <- distinct(cit_tech)
  return(cit_tech)

}
