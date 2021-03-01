library(RSQLite)
library(harmonizer)
library(dplyr)
library(ggplot2)

source('r/utilities/get_filing_year.R')
source('r/applicants/get_applicants.R')
source('r/applicants/asymmetrical_class.R')

load(file = 'data/data_gathering/ai_patents.rda')

applicants<- get_applicants(ai_patents)


# Select applicants
applicants$han_name <- applicants$han_name %>%
                        harmonize()

stopwords <- read.csv(file = 'data/applicants/stopwords.csv')

#create list of stop symbols
stopsymbols <- stopwords$stopwords

#add regex
stopsymbols<- paste0(' ', stopsymbols, '$')


# Store the harmonized names in a temporary variable
applicants$harm_name <- applicants$han_name

#loop through the stopword list five times
for(times in 1:10){
  # loop through stopword list
  for(i in 1:length(stopsymbols)){
    # delete matching patterns
    applicants$harm_name <- gsub(stopsymbols[i], '', applicants$harm_name)
  }
  print(times)
}

applicants <- applicants[,c('appln_id', 'harm_name', 'psn_sector')]

# Keep only rows containing one harmonized name per appln_id
applicants <- applicants %>%
                  distinct(appln_id, harm_name, .keep_all = TRUE)

length(unique(applicants$harm_name))

# Get filing year
year <- get_filing_year(appln_id = data.frame(appln_id = applicants[,'appln_id']))

# Convert into integer to allow joining tables
applicants$appln_id <- as.integer(applicants$appln_id)

applicants <- inner_join(applicants, year, by = 'appln_id')

# Count number of applications by filing year and applicant
applicant_count<- applicants %>%
                    group_by(harm_name, appln_filing_year) %>%
                          count()


# Divide in asymmetrical classes
applicant_count<- applicant_count %>%
      group_by(appln_filing_year) %>%
        asymmetrical_class()


yearly_applicant <- applicant_count %>%
                      group_by(group, appln_filing_year) %>%
                          mutate(group_total = sum(n)) %>%
                            select(group, group_total, appln_filing_year) %>%
                                distinct()


ggplot(yearly_applicant, aes(fill = factor(group), x = appln_filing_year, y = group_total)) +
  geom_bar(position = 'dodge', stat = 'identity') +
  scale_x_discrete(name = 'Application filing year') +
  scale_y_continuous(name = 'Number of patents') +
  scale_fill_discrete(name = "Class") +
  theme(axis.text.x=element_text(angle=45, hjust=1))

yearly_applicant <- yearly_applicant %>%
                      group_by(appln_filing_year) %>%
                        mutate(perc = group_total/sum(group_total))


ggplot(yearly_applicant, aes(fill = factor(group), x = appln_filing_year, y = perc)) +
  geom_bar(position = 'dodge', stat = 'identity') +
  scale_x_discrete(name = 'Year') +
  scale_y_continuous(name = '% of patents filed') +
  scale_fill_discrete(name = "Class") +
  theme(axis.text.x=element_text(angle=45, hjust=1))

print(xtable(t(table(applicant_count$group, applicant_count$appln_filing_year))), include.rownames=FALSE, file = 'tables/applt_year.tex')

table(applicants$psn_sector)

applicants$psn_sector[applicants$psn_sector == 'GOV NON-PROFIT UNIVERSITY'] <- 'UNIVERSITY'
applicants$psn_sector[applicants$psn_sector == 'COMPANY GOV NON-PROFIT UNIVERSITY'] <- 'UNIVERSITY'
applicants$psn_sector[applicants$psn_sector == 'COMPANY UNIVERSITY'] <- 'UNIVERSITY'
applicants$psn_sector[applicants$psn_sector == 'COMPANY HOSPITAL'] <- 'HOSPITAL'
applicants$psn_sector[applicants$psn_sector == 'COMPANY GOV NON-PROFIT'] <- 'GOV NON-PROFIT'

yearly_sector<- applicants %>%
    group_by(psn_sector, appln_filing_year) %>%
      count() %>%
      ungroup()

ggplot(yearly_sector, aes(fill = factor(psn_sector), x = appln_filing_year, y = n)) +
  geom_bar(position = 'dodge', stat = 'identity') +
  scale_x_discrete(name = 'Year') +
  scale_y_continuous(name = 'n of patents') +
  scale_fill_discrete(name = "Class") +
  theme(axis.text.x=element_text(angle=45, hjust=1))

yearly_sector <- yearly_sector %>%
  group_by(appln_filing_year) %>%
  mutate(perc = n/sum(n))

ggplot(yearly_sector, aes(group = factor(psn_sector), x = appln_filing_year, y = perc * 100, color = factor(psn_sector))) +
  geom_line() +
  scale_x_discrete(name = 'Year') +
  scale_y_continuous(name = '% of patents') +
  scale_color_discrete(name = "Sector") +
  theme(axis.text.x=element_text(angle=45, hjust=1))

