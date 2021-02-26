
plot_measures <- function(dataframe, column, y_axis)
{
  temp <- as.data.frame(cbind(dataframe$year, dataframe[,column]))
  names(temp) <- c('year','cpc')

  ggplot() +
    geom_line(temp, mapping = aes(x = year, y = cpc)) +
    theme(axis.text.x = element_text(angle=45, hjust=1)) +
    scale_y_continuous(name = y_axis) +
    scale_x_continuous(name = 'Year')

    print(xtable(temp, caption = paste0('Evolution of ', tolower(y_axis)),
               align = 'rrr', digits = 3), include.rownames = TRUE,
        file = paste0('tables/network/', column,'.tex'))

}

