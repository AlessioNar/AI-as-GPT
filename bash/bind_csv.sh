#!/bin/sh
file=$1
head -n1 $file > temp_file.csv
tail -n +2 $file | sort -u >> temp_file.csv
mv temp_file.csv $file

