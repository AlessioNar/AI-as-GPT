library(tidyr)

# Create applicants dataframe
APPLICANTS <- AI_PATENTS %>%
                select(appln_id, applt_name,
                       appln_filing_year) %>%
                  unnest(applt_name) %>%
                    group_by(appln_filing_year, applt_name) %>%
                      count()

# Write df in csv file for web application
write.csv(APPLICANTS, file = './data/applicants/applicants_year.csv',
          row.names = FALSE)


assign_groups<- function(year){

  groupA <- c(1995:1999)
  groupB <- c(2000:2004)
  groupC <- c(2005:2009)
  groupD <- c(2010:2014)
  groupE <- c(2015:2019)

  if(year %in% groupA){
    group <- 'A'
  }
  if(year %in% groupB){
    group <- 'B'
  }
  if(year %in% groupC){
    group <- 'C'
  }
  if(year %in% groupD){
    group <- 'D'
  }
  if(year %in% groupE){
    group <- 'E'
  }
  return(group)
}

APPLICANTS <- APPLICANTS %>%
                mutate(group = assign_groups(appln_filing_year))



# Create applicants dataframe
APPLICANTS <- AI_PATENTS %>%
    select(appln_id, applt_name,
          appln_filing_year) %>%
            unnest(applt_name) %>%
                group_by(appln_filing_year) %>%
                  mutate(group = assign_groups(appln_filing_year)) %>%
                    ungroup() %>%
                      group_by(group, applt_name) %>%
                        count()

summary_table<- function(df, group){

    df <- df[df$group == group,]

        df<- df[,2] %>%
                  select(applt_name) %>%
                      count()

      df$class<- as.character(lapply(df$n, applt_class))

      return(df)
}

applt_A <- summary_table(APPLICANTS, 'A')
table(applt_A$class)

applt_B <- summary_table(APPLICANTS, 'B')
table(applt_B$class)

applt_C <- summary_table(APPLICANTS, 'C')
table(applt_C$class)

applt_D <- summary_table(APPLICANTS, 'D')
table(applt_D$class, )

applt_E <- summary_table(APPLICANTS, 'E')
table(applt_E$class)

data.frame(#A = unclass(table(applt_A$class)),
           B = unclass(table(applt_B$class)),
           C = unclass(table(applt_C$class)), D = unclass(table(applt_D$class)),
           E = unclass(table(applt_E$class)))


ggplot(applt_count) +
    geom_line(mapping = aes(x = n, y = nn))

applt_class<- function(n){
  if (n == 1){
    class <- 'single'
  }
  if (n > 1 & n < 6){
    class <- 'barely active'
  }
  if (n > 5 & n < 51){
    class <- 'active'
  }
  if (n > 50 & n < 500){
    class <- 'very active'
  }
  if (n > 501 & n < 5000){
    class <- 'extremely active'
  }
  return(class)
}

table(applt_A$class)
table(applt_E$class)


summary(applt_B$n)
summary(applt_C$n)
summary(applt_D$n)
summary(applt_E$n)

mean(applt_A$n)
mean(applt_B$n)
mean(applt_C$n)
mean(applt_D$n)
mean(applt_E$n)

var(applt_A$n)
var(applt_B$n)
var(applt_C$n)
var(applt_D$n)
var(applt_E$n)

