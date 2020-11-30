concatenate_cpc <- function(cpc_table, appln_table){

  # Concatenate cpc codes
  concat_table <- cpc_table %>%

                  group_by(appln_id) %>%

                  # Concatenation
                    mutate(cpc = paste(cpc_class_symbol, collapse = "")) %>%

                    # Keep only the two columns and eliminate duplicated rows
                        select(appln_id, cpc) %>%

                          distinct()

  # Join ai_appln table to retrieve the filing date
  concat_table <- left_join(concat_table, appln_table[,c('appln_id', 'appln_filing_date')], by = 'appln_id')


  return(concat_table)

}
