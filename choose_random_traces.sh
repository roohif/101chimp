#!/bin/bash

IDX=$1
DB="trace.${IDX}/trace.${IDX}"
SLICES=1000

# Get a list of all the slices from the archive
blastdbcmd -db $DB -entry all -outfmt %i | shuf | head --lines=$SLICES | {
	readarray entries

	for entry in ${entries[@]}
	do
		blastdbcmd -db $DB -entry $entry
	done
} > trace.${IDX}/slices.${IDX}.fa
