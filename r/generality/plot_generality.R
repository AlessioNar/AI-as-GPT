
get_avg_gen<- function(generality_df, which, rm.single = FALSE){

  if(rm.single == TRUE){
    generality_df$n_cit <- sapply(generality_df$citing, function(x) length(unlist(x)))
    generality_df <- generality_df[generality_df$n_cit > 1,]
  }

  avg_gen <- generality_df %>%
    group_by(appln_filing_year) %>%
    summarize(
      #min = min(!!sym(which), na.rm =TRUE),
      second_quantile = quantile(!!sym(which), na.rm = TRUE, 0.25),
      median = median(!!sym(which), na.rm = TRUE),
      mean = mean(!!sym(which), na.rm = TRUE),
      fourth_quantile = quantile(!!sym(which), na.rm = TRUE, 0.75)) %>%
    #max = max(!!sym(which), na.rm =TRUE))
    ungroup() %>%
    as.data.frame()
  return(avg_gen)
}

get_var_gen <- function(generality_df, rm.single = FALSE){

  if(rm.single == TRUE){
    generality_df$n_cit <- sapply(generality_df$citing, function(x) length(unlist(x)))
    generality_df <- generality_df[generality_df$n_cit > 1,]
  }

  var_gen <- generality_df %>%
    group_by(appln_filing_year) %>%
    summarize(ipc = sd(ipc, na.rm = TRUE),
              cpc = sd(cpc, na.rm = TRUE),
              tech_field = sd(tech_field, na.rm = TRUE),
              nace = sd(nace, na.rm = TRUE),) %>%
    ungroup() %>%
    as.data.frame()

  return(var_gen)
}

# How do I summarize the results?
draw_graph<- function(gen, cont, which, y_axis, what, rm.single = FALSE){

  if(what == 'mean'){

    df <- get_avg_gen(gen, which, rm.single = rm.single)
    cont <- get_avg_gen(cont, which, rm.single = rm.single)
    df<- data.frame(appln_filing_year = df$appln_filing_year, mean = df$mean, median = df$median)
    cont<- data.frame(appln_filing_year = cont$appln_filing_year, mean = cont$mean, median = cont$median)
    df$group <- 'AI'
    cont$group <- 'Control'
    df <- rbind(df, cont)
    df <- as.data.frame(melt(df, c('appln_filing_year', 'group')))
    df$group <- as.factor(df$group)
    df$variable <- as.factor(df$variable)

    ggplot(df, aes(x = appln_filing_year, y = value, color = group, linetype = variable, group = paste0(group, variable))) +
      geom_line()+
      scale_color_discrete(name = 'Group') +
      scale_x_discrete(name = 'Year') +
      scale_y_continuous(name = y_axis) +
      scale_linetype_discrete(name = 'Measure', labels =c('Mean', "Median")) +
      theme(axis.text.x = element_text(angle=45, hjust=1))


  } else if(what == 'variability'){

    df <- get_var_gen(gen, rm.single = rm.single)
    df <- melt(df, 'appln_filing_year')

    ggplot() +
      geom_line(df, mapping = aes(x = appln_filing_year, y = value, group = variable, color = variable)) +
      scale_y_continuous(name = y_axis) +
      scale_color_discrete(name = '' , label = c('IPC', "CPC", 'HJT', 'NACE v.2')) +
      scale_x_discrete(name = 'Year') +

      theme(axis.text.x = element_text(angle=45, hjust=1))
  }

}

