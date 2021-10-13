#!/bin/bash

if [ $# -lt 1 ]
then
    echo "Usage: $0 <Plate1.names> <Plate2.names> <Plate3.names> ..."
    exit -1
fi

DATESTR=`date +%Y%m%d`

rm -f bysample/Plate*
for F in $@
do
    NAME=`echo ${F} | sed 's/^.*\///' | sed 's/\.names$//'`
    P1=./data/${NAME}.p1
    P2=./data/${NAME}.p2
    ID=./data/${NAME}.names

    # Merge deltas
    if [ ${P1} != ${P2} ]
    then
	if [ -f ${P1} ]
	then
	    if [ -f ${P2} ]
	    then
		if [ -f ${ID} ]
		then
		    # Convert to column format
		    for PLATE in ${P1} ${P2} ${ID}
		    do
			./scripts/wideToLong.sh ${PLATE}
		    done

		    # Calculate results
		    paste ${P1}.tmp.out ${P2}.tmp.out  | awk '{print $2"\t"($1-$3);}' > bysample/${NAME}.values
		    rm ${P1}.tmp.out ${P2}.tmp.out
		fi
	    fi
	fi

	# Convert the sample labels to groups
	cat ${ID}.tmp.out | awk '{print $2"\t"$1;}' | sed 's/\tH2O/\tH2O\tH2O/' | sed 's/LAMP_PC/PC\tpc/' | sed 's/LAMP_H2O/H2O\tH2O/' | sed 's/negative/negative\tnegative/' | sed 's/\(TWIST.*\)$/\1\ttwist/' | sed 's/_Twist/twist\ttwist/' | sed 's/Empty$/Empty\tempty/' | sed 's/_EMPTY$/Empty\tempty/' | sed 's/\tE\([0-9]\)$/\tE\1\tKnopp/' | sed 's/\t\([A-Z][0-9]\)_Knopp$/\t\1\tKnopp/' | sed 's/\tPC$/\tPC\tpc/' | sed 's/_POSCTR$/posCTR\tposCTR/' | sed 's/_NEGCTR$/negCTR\tnegCTR/' | awk '{if (NF==2) { print $0"\tsaliva";} else {print $0;} }' > ${ID}.table
	rm ${ID}.tmp.out

	# Merge tables
	echo -e "Sample\tId\tGroup\tValue" > bysample/${NAME}.tsv
	paste <(sort -k1,1V ${ID}.table) <(sort -k1,1V bysample/${NAME}.values) | cut -f 1-3,5 >> bysample/${NAME}.tsv
	rm ${ID}.table bysample/${NAME}.values
	sed -i 's/^\([A-Z]\)/\1\t/' bysample/${NAME}.tsv
	Rscript lamp.R bysample/${NAME}.tsv
    fi
done

# Summarize
./results.sh bysample/*.tsv

# Create table
# By default order for replicates: positive, negative, fail
tail -n +2 results.tsv | cut -f 1,5 | sort -r | uniq | awk '{if (OLD!=$1) { print $0;}; OLD=$1;}' | sort > covid.screening.${DATESTR}.tsv 
