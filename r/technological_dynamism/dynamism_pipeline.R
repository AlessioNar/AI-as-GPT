library(RSQLite)
library(dplyr)
library(ggplot2)
library(xtable)

load('data/data_gathering/ai_patents.rda')
source('r/technological_dynamism/plot_dynamism.R')

conn <- dbConnect(SQLite(), 'data/patstat_def/patstat.db')

# Get total number of PCT patents per year
pct_patents<- dbGetQuery(conn, "SELECT appln_filing_year, COUNT(DISTINCT appln_id)
                                        FROM tls201_appln
                                        WHERE appln_auth = 'WO'
                                        AND appln_filing_year BETWEEN 1995 AND 2017
                                        GROUP BY appln_filing_year;")

dbWriteTable(conn, name = 'tmp_ai', ai_patents)

# Get number of AI patents per year
ai_patents <- dbGetQuery(conn, "SELECT a.appln_filing_year, COUNT(DISTINCT ai.appln_id)
                                      FROM tmp_ai AS ai
                                      INNER JOIN tls201_appln as a
                                      ON ai.appln_id = a.appln_id
                                      GROUP BY a.appln_filing_year")

dbExecute(conn, 'DROP TABLE tmp_ai')

dbDisconnect(conn)

names(ai_patents) <- c('year', 'ai_patents')
names(pct_patents) <- c('year', 'pct_patents')

n_patents <- inner_join(ai_patents, pct_patents, by = 'year')

n_patents<- n_patents %>%
  mutate(perc = (ai_patents/pct_patents)*100, ratio = ai_patents/pct_patents)


plot_dynamism(n_patents, column = 'ai_patents', caption = 'Number of AI patents')
plot_dynamism(n_patents, column = 'pct_patents', caption = 'Number of PCT patents')
plot_dynamism(n_patents, column = 'perc', caption = '% of PCT patents that use AI technologies')
plot_dynamism(n_patents, column = 'ratio', caption = 'Ratio of PCT patents that use AI technologies')

print(xtable(n_patents, caption = 'Technological dynamism',
             align = 'rrrrrr', digits = 3), include.rownames=FALSE, file = 'tables/tech_dynamism.tex')


n_patents <- n_patents[,c('year', 'ai_patents', 'pct_patents')]

n_patents <- melt(n_patents)

ggplot() +
  geom_line(n_patents, mapping = aes(x = year, y = value, color = variable, group = variable)) +
  theme(axis.text.x=element_text(angle=45, hjust=1), axis.text.y=element_text(angle=45, hjust=1)) +
  scale_y_continuous(name = '') +
  scale_x_discrete(name = 'Year')
