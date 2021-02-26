
get_tech_class <- function(patents, type){

  names(patents) <- 'appln_id'

	conn <- dbConnect(SQLite(), 'data/patstat_def/patstat.db')

		dbWriteTable(conn, value = patents, name = 'temp_appln', overwrite = TRUE)

		if (type == 'cpc'){
			tech_table<- dbGetQuery(conn, 'SELECT *
        			          FROM tls224_appln_cpc
        			          WHERE appln_id IN (SELECT appln_id
        			                            FROM temp_appln);')
		}
		if (type == 'ipc'){
			tech_table<- dbGetQuery(conn, 'SELECT ipc.appln_id AS appln_id, ipc.ipc_class_symbol AS ipc_class_symbol
        			          FROM tls209_appln_ipc AS ipc
        			          INNER JOIN temp_appln AS tmp
        			          ON ipc.appln_id = tmp.appln_id;')
		}
		if (type == 'tech_field'){
		  tech_table<- dbGetQuery(conn, 'SELECT *
        			          FROM tls230_appln_techn_field
        			          WHERE appln_id IN (SELECT appln_id
        			                            FROM temp_appln);')

		  tech_table[,1:2] <- apply(tech_table[,1:2], 2, as.integer)
		  tech_table$weight<- as.double(tech_table$weight)
		}

		dbExecute(conn, 'DROP TABLE temp_appln;')

	dbDisconnect(conn)

	return(tech_table)

}

