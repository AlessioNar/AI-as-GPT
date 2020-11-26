

setwd('./data/patstat_raw/wipo_patents')

directories_name<- dir()

new_folders <- gsub('.zip', '', directories_name)

for (i in 1:length(directories_name)){
  #system(paste0('bash -c \"mkdir ', new_folders[i], '\"'))
  system(paste0('bash -c \"unzip ', directories_name[i], ' -d ', new_folders[i], '\"'))

}

setwd("C:/Users/aless/Desktop/Developer/MyThesis")
table_list<- read.table('./bash/table_list.txt')

setwd('./data/patstat_raw/wipo_patents')





for (i in 1:nrow(table_list)){

  address<- system(paste0('bash -c "find -type f -name ', table_list[i,]), intern = TRUE)

  system(paste0('bash -c \"head -n1 ', address[1], ' > ', table_list[i,], '\"'))

    for (l in 1:length(address)){

      system(paste0('bash -c \"tail -n +2 ', address[l], ' >> ', table_list[i,]))

    }

    print(table_list[i,])
}

for (i in 1:nrow(table_list)){

  system(paste0('bash -c \"./bash/bind_csv.sh ./data/patstat_merged/wipo_patents/', table_list[i,], '"'))
  print(table_list[i,])
}

