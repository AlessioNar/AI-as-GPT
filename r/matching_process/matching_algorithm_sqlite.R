
matching_algorithm_SQLITE <- function(target, source){

  # Create empty dataframe
  perfect <- data.frame()

  # initialize iteration variable
  i <- 0

  # Loop: keep on matching until no matches are available
  while(nrow(target) != 0){

    # Connect to database
    conn <- dbConnect(RSQLite::SQLite(), "matching.db")

    # Write tables: ai_concat and wipo_concat
    dbWriteTable(conn, name = 'ai_concat', target)
    dbWriteTable(conn, name = 'wipo_concat', source)

    # To avoid hd issue, change the temp directory to the external hd
    #dbExecute(conn, "PRAGMA temp_store_directory='/media/prometeo/Elements/DATASETS'")

    # Run query
    merged <- dbGetQuery(conn,
              "SELECT ai.appln_id AS ai_appln, wipo.appln_id AS wipo_appln,
                MIN(ABS(julianday(ai.appln_filing_date) - julianday(wipo.appln_filing_date))) AS diff, ai.cpc AS cpc
                FROM ai_concat AS ai
                INNER JOIN wipo_concat AS wipo
                ON ai.cpc = wipo.cpc
                GROUP BY ai.appln_id")

    save(merged, file = 'temp_merged.rda')

    # Drop existing tables
    dbExecute(conn,
              "DROP TABLE ai_concat")
    dbExecute(conn,
              "DROP TABLE wipo_concat")

    # Close connection
    dbDisconnect(conn)

    # keep only the target patents that have a match
    target <- target[target$appln_id %in% merged$ai_appln,]

    # Retrieve the patents that have no duplicates
    nodupl <- merged[

      # wipo is not duplicated
      (!(merged$wipo_appln %in% merged$wipo_appln[duplicated(merged$wipo_appln)])) &
        # ai is not duplicated
        (!(merged$ai_appln %in% merged$ai_appln[duplicated(merged$ai_appln)]))
      ,]

    # store them in a temporary dataframe
    temp_perfect <- nodupl

    # bind dataframes together
    perfect <- rbind(perfect, temp_perfect)

    # Remove
    merged <- merged[!(merged$ai_appln %in% perfect$ai_appln |
                         merged$wipo_appln %in% perfect$wipo_appln),]

    # case 2: wipo is duplicated, ai is not

    wipodupl <- merged[(
      # wipo is duplicated
      (merged$wipo_appln %in% merged$wipo_appln[duplicated(merged$wipo_appln)]) &
        # ai is not duplicated
        (!(merged$ai_appln %in% merged$ai_appln[duplicated(merged$ai_appln)]))
    ),]

    # choose the one with minimal time difference
    wipodupl <- wipodupl %>%
      group_by(wipo_appln) %>%
      slice_min(order_by = diff)

    # Store the AI patent that have associated only one wipo appln
    temp_perfect <- wipodupl[!(wipodupl$wipo_appln %in% wipodupl$wipo_appln[duplicated(wipodupl$wipo_appln)]),]

    # Bind dataframes together
    perfect <- rbind(perfect, temp_perfect)

    # if they have an equal duplicate
    wipodupl <- wipodupl[(wipodupl$wipo_appln %in% wipodupl$wipo_appln[duplicated(wipodupl$wipo_appln)]),]

    # choose a random duplicate
    temp_perfect <- wipodupl[!duplicated(wipodupl$wipo_appln),]

    # Bind dataframes together
    perfect <- rbind(perfect, temp_perfect)

    # remove already matched wipo_patents
    source <- source[!(source$appln_id %in% perfect$wipo_appln),]

    # remove already matched ai_patents
    target <- target[!(target$appln_id %in% perfect$ai_appln),]

    # In case of errors, store the temporary result in a file
    save(perfect, file = 'perfect_sqlite.rda')

    # Add one iteration
    i <- i + 1

    # Print values to user
    print(paste("Iteration number:", i))
    print(paste("Perfect matches:", nrow(perfect)))
    print(paste("Applications to be matched:", nrow(target)))
  }

  return(perfect)
}
