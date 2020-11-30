library(dplyr)
library(harmonizer)
library(lubridate)

# Load seed table and select ai patents
load('data/tls240_ai_wipo.rda')
ai_patents <- data.frame(appln_id = tls240_ai_wipo$ai_appln)

# remove unused table
rm(tls240_ai_wipo)

# Load tables
tls206_person <- read_csv('data/patstat_merged/ai_patents/tls206_person.csv')
tls207_pers_appln <- read_csv('data/patstat_merged/ai_patents/tls207_pers_appln.csv')

# Create df containing person information
persons <- left_join(tls207_pers_appln, tls206_person[, c('person_id', 'person_ctry_code', 'psn_name', 'psn_sector','han_name')], by ="person_id")

applicants <- persons[persons$applt_seq_nr > 0,]
inventors <- persons[persons$invt_seq_nr > 0,]

rm(persons)
rm(tls206_person)
rm(tls207_pers_appln)

# Select applicants
applicants$han_name <- applicants$han_name %>%
                          harmonize()

#create list of stop symbols
stopsymbols <- c('COR', 'LL', 'IN', 'A', 'UK', 'PL', 'TECH', 'LT', 'CORP', 'GMB',
                 'B', 'C', "JP", 'CO', 'LTD', 'L', 'ELECT', 'GROUP', 'LICENSIN',
                 'INT', 'USA', 'FR', 'ASIA', 'EUROPE', 'CHINA', 'INVESTMENT',
                 'SA', 'CHEM', 'L', 'IND', 'K', 'ELEC', 'INNOVATE',
                 'DEVICE', 'WORLD', 'INC', 'INTELLECTUAL PROPERTY & STANDARDS',
                 '&', 'N', 'S', 'COMPUTER ENTERTAINMENT')

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


# Create df of applicants containing name and sector
applicants <- applicants %>%
                  group_by(appln_id) %>%
                    # nest them in a list
                      summarise(applt_name = list(harm_name),
                                  psn_sector = list(psn_sector))

# Join applicants with baseline dataframe
ai_patents <- left_join(ai_patents, applicants_test, by = 'appln_id')


# Repeat the same procedure with inventors, this time storing PATSTAT harmonized name
# And nationality
inventors <- inventors[,c('appln_id', 'psn_name', 'person_ctry_code')] %>%
                group_by(appln_id) %>%
                      summarise(inventors = list(psn_name), inv_ctry = list(person_ctry_code))

# Join inventors with baseline dataframe
ai_patents <- left_join(ai_patents, inventors, by = 'appln_id')

tls201_appln <- read_csv('data/patstat_merged/ai_patents/tls201_appln.csv')

ai_patents <- left_join(ai_patents, tls201_appln[,c('appln_id', 'appln_filing_year')], by = 'appln_id')

save(ai_patents, file = 'data/ai_patents_persons.rda')

