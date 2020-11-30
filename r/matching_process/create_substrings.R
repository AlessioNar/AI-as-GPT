create_substrings <- function(cpc_table, num_char){

  # Select only first eight characters of cpc code
  cpc_table$cpc_class_symbol <- substr(x = cpc_table$cpc_class_symbol, start = 1, stop = num_char)

  # Select only distinct pairs
  cpc_table <- distinct(cpc_table)

  return(cpc_table)

}
