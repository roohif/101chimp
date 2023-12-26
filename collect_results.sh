#!/bin/bash

# Are we collecting a subset of results, or all of them?
declare -a SETLIST
if [ $1 ]; then
	# Comma separated list of sets
	IFS=',' read -ra SETLIST <<< "$1"
fi

# CSV Headers
echo "trace,nident,length,qlen,count,pident,jtpident,avglength,avgqlen,qcov"

# Collect results for both hg19 and panTro7
for idx in $( seq -f "%03g" 1 101 )
do
	# If we are only look at specific sets, then check the SETLIST
	if [ $SETLIST ]; then
		regex="\<$idx\>"
		if [[ ! ${SETLIST[@]} =~ $regex ]]; then continue; fi
	fi

	HG_FILE="trace.${idx}/hits.hg19.${idx}.csv"
	if [ -f $HG_FILE ]; then
		awk -F, "{ nident += \$10; alnlength += \$11; qlen += \$12; n++ } END \
			{ printf(\"%s,%d,%d,%d,%d,%.4f,%.4f,%.2f,%.2f,%.2f\n\", \"${HG_FILE}\", nident, alnlength, qlen, n, \
				nident / alnlength * 100, nident / qlen * 100, alnlength / n, qlen / n, alnlength / qlen * 100) }" $HG_FILE
	fi

	PT_FILE="trace.${idx}/hits.panTro7.${idx}.csv"
	if [ -f $PT_FILE ]; then
		awk -F, "{ nident += \$10; alnlength += \$11; qlen += \$12; n++ } END \
			{ printf(\"%s,%d,%d,%d,%d,%.4f,%.4f,%.2f,%.2f,%.2f\n\", \"${PT_FILE}\", nident, alnlength, qlen, n, \
				nident / alnlength * 100, nident / qlen * 100, alnlength / n, qlen / n, alnlength / qlen * 100) }" $PT_FILE
	fi
done
