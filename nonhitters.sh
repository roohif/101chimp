#!/bin/bash

# Collect a list of "non-hitters" and then create a fasta file from them

for idx in $( seq -f "%03g" 5 5 100 )
do
	DIR=trace.${idx}
	PT_FILE=${DIR}/hits.panTro7.${idx}.csv
	SLICES_FILE=${DIR}/slices.${idx}.fa

	# If both files exist, then read them both in
	if [ -f ${PT_FILE} ] && [ -f ${SLICES_FILE} ]; then

		# echo "${DIR}: both files exist"

		hits=($( awk -F',' '{ print $1 }' $PT_FILE ))
		queries=($( awk '{ if ($1 ~ /^>/) { print substr($1, 2) } }' $SLICES_FILE ))

		nonhitters=()
		for q in "${queries[@]}"; do

			found=false
			for h in "${hits[@]}"; do
				if [[ $q == $h ]]; then found=true; fi
			done

			if [[ $found == false ]]; then nonhitters+=($q); fi
		done

		if [[ ${#nonhitters[@]} -gt 0 ]]; then
			DB=${DIR}/trace.${idx}
			for n in "${nonhitters[@]}"; do
				# "fix" the entry format
				entry="gnl|${n//[\:]/\|}"
				blastdbcmd -db $DB -entry $entry
			done
		fi


	fi

done > nonhitters.fa

