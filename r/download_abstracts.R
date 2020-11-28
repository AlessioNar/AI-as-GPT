library(dplyr)
library(tibble)
library(Rops)
library(readr)

load("data/tls240_ai_wipo.rda")

ai_patents<- data.frame(appln_id = tls240_ai_wipo$ai_appln)

tls201_appln <- read_csv("data/patstat_merged/ai_patents/tls201_appln.csv")

ai_patents <- inner_join(ai_patents, tls201_appln[,c(1,7)], by = "appln_id")

rm(tls201_appln)

# Split the dataset in groups of 100
abstract_chunks<- c(split(ai_patents$appln_nr_epodoc, (as.numeric(row.names(ai_patents))-1) %/% 100))

# Create empty dataframe called abstract
abstracts <- data.frame()

# Generate access token
access_token <- create_access_token(consumer_key, consumer_secret_key)

# Store current time
time <- Sys.time()

# Query the OPS API 100 chunks at the time
for (i in 652:length(abstract_chunks)){

  # Check if the session is expired
  if(Sys.time() > (time + 600)){
    # Generate access token
    access_token <- create_access_token(consumer_key, consumer_secret_key)

    # Store current time
    time <- Sys.time()
  }

  # Make request to OPS API and store df in temp_abstracts
  temp_abstracts<- get_abstract(abstract_chunks[[i]], type = "app", format = "epodoc", access_token)

  # Bind new dataframe to old dataframe
  abstracts<- rbind(abstracts, temp_abstracts)

  # Print i for debug
  print(i)

  # Pause to avoid rate limiting
  Sys.sleep(11)
}

save(abstracts, file = 'abstracts')

#651 error: need to verify
