# Load required libraries
library(dplyr)
library(readr)
library(RSQLite)

# Load virgin tables
wipo_appln <- read_csv("wipo_appln.csv")
wipo_cpc <- read_csv("wipo_cpc.csv")

ai_appln <- read_csv("ai_appln.csv")
ai_cpc <- read_csv("ai_cpc.csv")

# Step A: first 8 characters
wipo_cpc <- create_substrings(wipo_cpc, num_char = 8)
ai_cpc <- create_substrings(ai_cpc, num_char = 8)

# Remove AI patents from Wipo patents
wipo_cpc <- wipo_cpc[!(wipo_cpc$appln_id %in% ai_cpc$appln_id),]
wipo_concat <- wipo_concat[!(wipo_concat$appln_id %in% ai_concat$appln_id),]

# Concatenate cpc class symbols
wipo_concat <- concatenate_cpc(wipo_cpc, wipo_appln)
ai_concat <- concatenate_cpc(ai_cpc, ai_appln)

# perform matching
perfect_8 <- matching_algorithm_SQLITE(ai_concat, wipo_concat)

# bind dataframe
perfect <- rbind(perfect, perfect_8)

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

# perform matching
perfect_4 <- matching_algorithm_SQLITE(ai_concat, wipo_concat)

# bind dataframe
perfect <- rbind(perfect, perfect_4)

# Remove already matched patents
wipo_cpc <- wipo_cpc[!(wipo_cpc$appln_id %in% perfect$wipo_appln),]
ai_cpc <- ai_cpc[!(ai_cpc$appln_id %in% perfect$ai_appln),]

# Step C first 3 characters

# Create substrings
ai_cpc <- create_substrings(ai_cpc, num_char = 3)
wipo_cpc <- create_substrings(wipo_cpc, num_char = 3)

# Concatenate cpc class symbols
ai_concat <- concatenate_cpc(ai_cpc, ai_appln)
wipo_concat <- concatenate_cpc(wipo_cpc, wipo_appln)

# perform matching
perfect_3 <- matching_algorithm_SQLITE(ai_concat, wipo_concat)

# bind dataframe
perfect <- rbind(perfect, perfect_3)

# Remove already matched patents
wipo_cpc <- wipo_cpc[!(wipo_cpc$appln_id %in% perfect$wipo_appln),]
ai_cpc <- ai_cpc[!(ai_cpc$appln_id %in% perfect$ai_appln),]

# Step D: first 1 character
wipo_cpc <- create_substrings(wipo_cpc, num_char = 1)
ai_cpc <- create_substrings(ai_cpc, num_char = 1)

# Concatenate cpc class symbols
wipo_concat <- concatenate_cpc(wipo_cpc, wipo_appln)
ai_concat <- concatenate_cpc(ai_cpc, ai_appln)

# Perform matching
perfect_1 <- matching_algorithm_SQLITE(target = ai_concat, source = wipo_concat)

# Bind dataframe
perfect <- rbind(perfect, perfect_1)

# Remove already matched patents
ai_concat <- ai_concat[!(ai_concat$appln_id %in% perfect$ai_appln),]
wipo_concat <- wipo_concat[!(wipo_concat$appln_id %in% perfect$wipo_appln),]

# Check if they are unique
length(unique(perfect$ai_appln))
length(unique(perfect$wipo_appln))

# Save files
save(perfect, file = 'perfect.rda')
save(ai_concat, file = 'ai_concat.rda')
save(wipo_concat, file = 'wipo_concat.rda')


# Store unmatched cpc class symbol
unique_cpc <- unique(ai_concat$cpc)

# For each of the cpc class symbol
for (i in 1:length(unique_cpc)){

  # Compute the approximate string distance with each wipo patent
  wipo_concat[[unique_cpc[i]]] <- unlist(lapply(wipo_concat$cpc, function(x) as.integer(adist(unique_cpc[i], x))))

  print(i)

}

# Create empty dataframe
temp_perfect <- data.frame()

# Loop through the ai concat
for (i in 1:nrow(ai_concat)){

  # Select the wipo patents with minimum distance
  temp_subset <- wipo_concat[wipo_concat[[ai_concat$cpc[i]]] == min(wipo_concat[[ai_concat$cpc[i]]]),]

  # Compute the time difference between the subset and the ai patent
  temp_subset$diff <- abs(temp_subset$appln_filing_date - ai_concat$appln_filing_date[i])

  # Create temporary dataframe containing the ai patent and the wipo patent with minimum time difference
  temp_perfect<- data.frame(ai_appln = ai_concat$appln_id[i], wipo_appln = temp_subset$appln_id[which.min(temp_subset$diff)])

  # bind dataframes together
  temp_perfect <- rbind(temp_perfect, temp_perfect)

  # Remove the wipo patent assigned to the ai patent
  wipo_concat <- wipo_concat[!(wipo_concat$appln_id %in% temp_perfect$wipo_appln),]

  # Print i for debug
  print(i)
}

perfect <- rbind(perfect, temp_perfect)

save(perfect, file = 'perfect.rda')



