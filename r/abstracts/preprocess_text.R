
# Load required libraries
library(textstem)
library(textclean)
library(parallel)

# Load table containing titles
tls202_appln_title <- read_csv("data/patstat_merged/ai_patents/tls202_appln_title.csv")

# Convert appln_id to double
abstracts$appln_id <- as.double(abstracts$appln_id)

# Join tables
ai_patents <- left_join(tls202_appln_title, abstracts, by = 'appln_id')

lemmatize_big<- function(text){
  text <- text %>%
            tolower() %>%
              textclean::replace_contraction() %>%
                lemmatize_strings()
  return(text)
}

# Detect number of cores available
no_cores <- detectCores() - 1

# Start cluster
cl <- makeCluster(no_cores)

# Export functions and variables
clusterExport(cl = cl, varlist = c("lemmatize_big", "%>%", 'lemmatize_strings'))

# Lemmatize titles
ai_patents$appln_title<- parSapply(cl = cl, ai_patents$appln_title, function(x) lemmatize_big(x), simplify = 'vector')

# Lemmatize abstracts
ai_patents$abstract<- parSapply(cl = cl, ai_patents$abstract, function(x) lemmatize_big(x), simplify = 'vector')

stopCluster(cl)

# Remove names from vector
names(ai_patents$abstract) <- NULL

# Load AI index information
load(file = 'data/wipo_ai_index/AIApplication.rda')
load(file = 'data/wipo_ai_index/AIFunctional.rda')
load(file = 'data/wipo_ai_index/AIGeneral.rda')
load(file = 'data/wipo_ai_index/AITechniques.rda')

# Unlist keywords and filter for unique values
ai_application<- unique(unlist(AIApplication$Keywords))
ai_technique<- unique(unlist(AITechniques$Keywords))
ai_functional<- unique(unlist(AIFunctional$Keywords))
ai_general <- unique(unlist(AIGeneral$Keywords))

# paste them together and
keywords<- unique(c(ai_application, ai_technique, ai_functional, ai_general))

keywords <- unique(lemmatize_words(keywords))

# Check whether the patent can be considered AI or not
ai_patents$is_ai<- (grepl(x = ai_patents$appln_title, pattern = paste(keywords, collapse = '|'))) |
                               (grepl(x = ai_patents$abstract, pattern = paste(keywords, collapse = '|')))

# Check whether it mentions an AI technique
ai_patents$has_tech<- (grepl(x = ai_patents$appln_title, pattern = paste(ai_technique, collapse = '|'))) |
                      (grepl(x = ai_patents$abstract, pattern = paste(ai_technique, collapse = '|')))

# Same for functional application
ai_patents$has_func<- (grepl(x = ai_patents$appln_title, pattern = paste(ai_functional, collapse = '|'))) |
                               (grepl(x = ai_patents$abstract, pattern = paste(ai_functional, collapse = '|')))

# Same for application field
ai_patents$has_appln<- (grepl(x = ai_patents$appln_title, pattern = paste(ai_application, collapse = '|'))) |
                               (grepl(x = ai_patents$abstract, pattern = paste(ai_application, collapse = '|')))


length(which(ai_patents$has_tech == TRUE))
length(which(ai_patents$has_func == TRUE))
length(which(ai_patents$has_appln == TRUE))



