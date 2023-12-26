#!/bin/bash

# Look through all the BLAST csv files, and try to find
# where a result from hg19 has *MORE* identical nucleotides
# than the corresponding result from panTro7.

for idx in $( seq -f "%03g" 5 5 100 )
do
	# Have a look in the directory for BOTH files
	DIR=trace.${idx}
	DB=trace.${idx}/trace.${idx}
	HG_FILE=hits.hg19.${idx}.csv
	PT_FILE=hits.panTro7.${idx}.csv

	# If they are both there, then we can do a comparison
	if [ -f ${DIR}/${HG_FILE} ] && [ -f ${DIR}/${PT_FILE} ]; then

		>&2 echo "Examining: $DIR"

		declare -A hg19=()
		declare -A pt7=()

		# Read in the hg19 file
		while read -r line
		do
			qseqid=`echo $line | cut -d',' -f 1`
			hg19["${qseqid}"]=$line

		done < ${DIR}/${HG_FILE}
		>&2 echo "Read ${#hg19[@]} records from ${DIR}/${HG_FILE}"

		# Read in the panTro7 file
		while read -r line
		do
			qseqid=`echo $line | cut -d',' -f 1`
			pt7["${qseqid}"]=$line

		done < ${DIR}/${PT_FILE}
		>&2 echo "Read ${#pt7[@]} records from ${DIR}/${PT_FILE}"

		# Loop through and if there are any results where the hg19
		# nident is GREATER THAN the pt7 nident, then print it out
		for key in "${!hg19[@]}"
		do
			hg19nident=`echo ${hg19[$key]} | cut -d, -f 10`

			if [[ ! -v pt7[$key] ]]; then
				continue # Key doesn't exist
			fi

			pt7nident=`echo ${pt7[$key]} | cut -d, -f 10`

			if [ "$hg19nident" -gt "$pt7nident" ]; then

				outfile="${key//[\:]/-}"
				{ # Open a shell so all this output goes to one file
					entry="gnl|${key//[\:]/\|}"
					blastdbcmd -db $DB -entry $entry

					# Get the hg19 sequence
					sseqid=`echo ${hg19[$key]} | cut -d, -f 4`
					sstart=`echo ${hg19[$key]} | cut -d, -f 5`
					send=`echo ${hg19[$key]} | cut -d, -f 6`

					minus=""
					if [ "$sstart" -gt "$send" ]; then
						minus="-strand minus"
						temp=$sstart
						sstart=$send
						send=$temp
					fi

					blastdbcmd -db /home/glenn/genome/hg19/hg19 -entry $sseqid -range ${sstart}-${send} $minus

					# Get the panTro7 sequence
					sseqid=`echo ${pt7[$key]} | cut -d, -f 4`
					sstart=`echo ${pt7[$key]} | cut -d, -f 5`
					send=`echo ${pt7[$key]} | cut -d, -f 6`

					minus=""
					if [ "$sstart" -gt "$send" ]; then
						minus="-strand minus"
						temp=$sstart
						sstart=$send
						send=$temp
					fi

					blastdbcmd -db /home/glenn/genome/panTro7/panTro7 -entry $sseqid -range ${sstart}-${send} $minus

				} > muscle/$outfile.fa

				>&2 echo "${key} >>> (hg19 = ${hg19nident} vs pt7 = ${pt7nident})"
			fi

		done

	fi

done
