plot_dynamism <- function(patents, column, caption)
{
  ggplot() +
    geom_line(patents, mapping = aes(x = year, y = patents[,column], group = 1), fill = 'red') +
    theme(axis.text.x=element_text(angle=45, hjust=1), axis.text.y=element_text(angle=45, hjust=1)) +
    scale_y_continuous(name = caption) +
    scale_x_discrete(name = 'Year')

}

