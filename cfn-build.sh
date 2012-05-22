#!/bin/bash

CONFIG=$1
NAME=`basename "$CONFIG" .m4`
OUTPUTFILE=$NAME-`date "+%Y%m%d%H%M"`.template.json

m4 -I features -I configs $CONFIG template.json.m4 > $OUTPUTFILE
