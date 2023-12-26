#!/bin/bash

# Copying Tomkins parameters from:
# https://answersresearchjournal.org/analysis-chimpanzee-trace-read-data-sets/
if [ ! $1 ]; then
	echo "Usage: $0 <zero-padded-trace-set>"
	exit
fi

DIR="trace.$1"

if [ ! -d $DIR ]; then
	echo "Directory ${DIR} doesn't exist!"
	exit
fi

# Check for query slices!
QUERY="${DIR}/slices.$1.fa"

if [ ! -f $QUERY ]; then
	echo "ERROR: Could not find slices file. Need to choose_random_slices perhaps?"
	exit
fi

# Just in case we accidentally attempt to overwrite previous results
OUTFILE="${DIR}/hits.hg19.$1.csv"
if [ -f $OUTFILE ]; then
	echo "ERROR: Do you really mean to overwrite the previous results?"
	exit
fi

blastn -task blastn -evalue 0.1 -word_size 11 -max_target_seqs 1 -max_hsps 1 \
	-outfmt "10 qseqid qstart qend sseqid sstart send mismatch gapopen pident nident length qlen evalue" \
	-dust no -soft_masking false -perc_identity 50 -gapopen 3 -gapextend 3 \
	-query $QUERY -db /home/glenn/genome/hg19/hg19 -num_threads 3 -out $OUTFILE
