library(RSQLite)
library(dplyr)
library(xtable)

source('r/pervasiveness/get_tech_variety.R')
source('r/utilities/get_tech_class.R')

load(file = 'data/data_gathering/ai_patents.rda')

conn <- dbConnect(SQLite(), 'data/patstat_def/patstat.db')

pct_patents<- dbGetQuery(conn, "SELECT appln_id
                                        FROM tls201_appln
                                        WHERE appln_auth = 'WO'
                                        AND appln_filing_year BETWEEN 1995 AND 2017;")

dbDisconnect(conn)

ai_ipc_variety<- get_tech_variety(ai_patents, 'ipc')

pct_ipc_variety <- get_tech_variety(pct_patents, type = 'ipc')

ipc_variety <- inner_join(ai_ipc_variety, pct_ipc_variety, by = 'appln_filing_year')

names(ipc_variety) <- c('appln_filing_year', 'ai', 'all')

ipc_variety$ratio <- (ipc_variety$ai/ipc_variety$all) * 100


ai_cpc_variety<- get_tech_variety(ai_patents, 'cpc')
pct_cpc_variety <- get_tech_variety(pct_patents, type = 'cpc')

cpc_variety <- inner_join(ai_cpc_variety, pct_cpc_variety, by = 'appln_filing_year')

names(cpc_variety) <- c('appln_filing_year', 'ai', 'all')

cpc_variety$ratio <- (cpc_variety$ai/cpc_variety$all) * 100


print(xtable(ipc_variety, caption = 'Variety of IPC technological classes',
             align = 'rrrrr', digits = 3), include.rownames=FALSE, file = 'tables/ipc_variety.tex')

print(xtable(cpc_variety, caption = 'Variety of CPC technological classes',
             align = 'rrrrr', digits = 3), include.rownames=FALSE, file = 'tables/cpc_variety.tex')


ipc_variety$class <- 'IPC'

cpc_variety$class <- 'CPC'

tech_variety<- rbind(ipc_variety, cpc_variety)

ggplot() +
  geom_line(tech_variety, mapping = aes(x = appln_filing_year, y = ratio, group = class, color = class)) +
  scale_y_continuous(name = '% of 4-digits classification codes') +
  scale_x_discrete(name = 'Year') +
  scale_color_discrete(name = 'Class. System') +
  theme(axis.text.x=element_text(angle=45, hjust=1))


