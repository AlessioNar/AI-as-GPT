# Top 1%
asymmetrical_class<- function(test){

  test<- test %>%
      arrange(desc(n))

  test$group <- NA
  top_1<- round((nrow(test) / 100)* 1, 0)

  test$group[1:top_1] <- "Top 1%"

  top_10<- round((nrow(test) / 100)* 9, 0)

  test$group[(top_1+1):(top_1 + 1 + top_10)] <- "90%-99%"

  top_50<- round((nrow(test) / 100)* 40, 0)

  test$group[(top_1 + top_10 +1):nrow(test)] <- "0%-90%"

  return(test)

}
