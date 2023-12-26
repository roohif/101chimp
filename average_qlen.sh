#!/bin/bash

for idx in $( seq -f "%03g" 1 101 )
do

	DIR="trace.${idx}"

	# Get some basic info from the databases
	blastdbcmd -list ${DIR} -list_outfmt "%t,%l,%n"

done > qlen.csv

