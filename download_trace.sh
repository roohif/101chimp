#!/bin/bash

SITE="https://ftp.ncbi.nlm.nih.gov/pub/TraceDB/pan_troglodytes/"

for idx in $(seq -f "%03g" 1 101)
do
	# Create the directory if it doesn't exist
	DIR="trace.${idx}"
	if [ ! -d "$DIR" ]; then mkdir -v $DIR; fi

	# Gunzip ANY gzipped files if they are in the directory
	if [ -f ${DIR}/*.gz ]; then gunzip --verbose ${DIR}/*.gz; fi

	# Download the FASTA file
	FNAME="fasta.pan_troglodytes.${idx}"
	URL="${SITE}${FNAME}.gz"

	if [ ! -f "${DIR}/${FNAME}" ]; then
		wget -P $DIR $URL
		gunzip --verbose ${DIR}/${FNAME}.gz
	fi

	# Download the QUAL file
	QNAME="qual.pan_troglodytes.${idx}"
	URL="${SITE}${QNAME}.gz"

	if [ ! -f "${DIR}/${QNAME}" ]; then
		wget -P $DIR $URL
		gunzip --verbose ${DIR}/${QNAME}.gz
	fi

	# Run it through lucy to trim both ends
	TNAME="trimmed.fasta.pan_troglodytes.${idx}"
	if [ ! -f "${DIR}/${TNAME}" ]; then
		lucy -minimum 100 -output ${DIR}/trimmed.fasta.pan_troglodytes.${idx} ${DIR}/trimmed.qual.pan_troglodytes.${idx} \
			-xtra 8 ${DIR}/${FNAME} ${DIR}/${QNAME}

		# Lucy only _annotates_ the removable region. This step actually removes it
		awk -f /usr/local/bin/lucy-1.20p/zapping.awk ${DIR}/${TNAME} > "${DIR}/trace.${idx}.fasta"
	fi

	# Create the BLAST database
	if [ ! -f "${DIR}/trace.${idx}.nsq" ]; then
		makeblastdb -dbtype nucl -in ${DIR}/trace.${idx}.fasta -title ${DIR} -parse_seqids -out ${DIR}/${DIR}
	fi

	echo "${DIR} - Complete"

done

