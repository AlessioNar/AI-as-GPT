#!/bin/sh

DIRECTORY=$1
FOLDERS=$2

dir $DIRECTORY*.zip | for i in $(cat); do unzip $i $DIRECTORY; done

unzip $DIRECTORY $NAME



