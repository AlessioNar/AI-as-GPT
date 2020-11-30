# Load required libraries
library(dplyr)
library(readr)
library(RSQLite)

# Load virgin tables
wipo_appln <- read_csv("data/patstat_merged/wipo_patents/tls201_appln.csv")
wipo_cpc <- read_csv("data/patstat_merged/wipo_patents/tls224_appln_cpc.csv")

ai_appln <- read_csv("data/patstat_merged/ai_patents/tls201_appln.csv")
ai_cpc <- read_csv("data/patstat_merged/ai_patents/tls224_appln_cpc.csv")

# Load AI appln
load(file = 'data/ai_patents_classified.rda')
ai_patents <- data.frame(appln_id = ai_patents[['appln_id']])

ai_cpc = left_join(ai_patents, ai_cpc, by = c('appln_id'))
rm(ai_patents)

# Step A: first 8 characters
wipo_cpc <- create_substrings(wipo_cpc, num_char = 8)
ai_cpc <- create_substrings(ai_cpc, num_char = 8)

# Remove AI patents from Wipo patents
wipo_cpc <- wipo_cpc[!(wipo_cpc$appln_id %in% ai_cpc$appln_id),]

# Concatenate cpc class symbols
wipo_concat <- concatenate_cpc(wipo_cpc, wipo_appln)
ai_concat <- concatenate_cpc(ai_cpc, ai_appln)

# perform matching
perfect_8 <- matching_algorithm(ai_concat, wipo_concat)

perfect <- data.frame()

# bind dataframe
perfect <- rbind(perfect, perfect_8)

save(perfect, file = 'data/perfect.rda')

# Step B first 4 characters

# Remove already matched patents
wipo_cpc <- wipo_cpc[!(wipo_cpc$appln_id %in% perfect$wipo_appln),]
ai_cpc <- ai_cpc[!(ai_cpc$appln_id %in% perfect$ai_appln),]

# Create substrings
ai_cpc <- create_substrings(ai_cpc, num_char = 4)
wipo_cpc <- create_substrings(wipo_cpc, num_char = 4)

# Concatenate cpc class symbols
ai_concat <- concatenate_cpc(ai_cpc, ai_appln)
wipo_concat <- concatenate_cpc(wipo_cpc, wipo_appln)
rm(perfect4)

# perform matching (similar algorithm but done in SQLITE, since R
# Can't handle in-memory)
# Need at least 120 GB of free space to store temp data
perfect_4 <- matching_algorithm_SQLITE(ai_concat, wipo_concat)

# If you have enough ram to allocate 10 GB in-memory use this command
# perfect_4 <- matching_algorithm(ai_concat, wipo_concat)

# bind dataframe
perfect <- rbind(perfect, perfect_4)

perfect <- distinct(perfect)

save(perfect, file = 'data/perfect.rda')

# Remove already matched patents
wipo_cpc <- wipo_cpc[!(wipo_cpc$appln_id %in% perfect$wipo_appln),]
wipo_appln <- wipo_appln[!(wipo_appln$appln_id %in% perfect$wipo_appln),]


ai_cpc <- ai_cpc[!(ai_cpc$appln_id %in% perfect$ai_appln),]
ai_appln <- ai_appln[!(ai_appln$appln_id %in% perfect$ai_appln),]

# Step C first 3 characters

# Create substrings
ai_cpc <- create_substrings(ai_cpc, num_char = 3)
wipo_cpc <- create_substrings(wipo_cpc, num_char = 3)

# Concatenate cpc class symbols
ai_concat <- concatenate_cpc(ai_cpc, ai_appln)
wipo_concat <- concatenate_cpc(wipo_cpc, wipo_appln)

wipo_concat <- wipo_concat[wipo_concat$cpc %in% ai_concat$cpc,]

save(wipo_concat, file ='wipo_concat.rda')

# perform matching
perfect_3 <- matching_algorithm_SQLITE(ai_concat, wipo_concat)

# bind dataframe
perfect <- rbind(perfect, perfect_3)

save(perfect, file = 'data/perfect.rda')


# Remove already matched patents
wipo_concat <- wipo_concat[!(wipo_concat$appln_id %in% perfect$wipo_appln),]
ai_concat <- ai_concat[!(ai_concat$appln_id %in% perfect$ai_appln),]

# Check if they are unique
length(unique(perfect$ai_appln))
length(unique(perfect$wipo_appln))

# Store in dataframe and save files
tls240_ai_wipo = data.frame(ai_appln = perfect$ai_appln, wipo_appln = perfect$wipo_appln)
save(tls240_ai_wipo, file = 'data/tls240_ai_wipo.rda')
