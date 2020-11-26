#!/bin/sh

tail -n +2 table_list.txt | for i in $(cat); do bash ./bash/bind_csv.sh $i; done
