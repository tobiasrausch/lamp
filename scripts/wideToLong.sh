#!/bin/bash

SCRIPT=$(readlink -f "$0")
BASEDIR=$(dirname "$SCRIPT")

PLATE=${1}
if [ -f ${PLATE} ]
then
    echo ${PLATE}
    dos2unix ${PLATE}
    PTEST=`cat $PLATE | grep -c -P "^P[ \t]"`
    if [ ${PTEST} -eq 1 ]
    then
	# 384 plate
	cat ${PLATE}  | sed 's/ /_/g' | sed 's/^[ \t]*//' | sed 's/[ \t][ \t]*/\t/g' | grep -P "^[A-P]\t" | cut -f 1-25 | sed 's/,/./g' | sed 's/_\t/\t/g' | sed 's/_$//' > ${PLATE}.tmp
    else
	# 96 plate
	cat ${PLATE}  | sed 's/ /_/g' | sed 's/^[ \t]*//' | sed 's/[ \t][ \t]*/\t/g' | grep -P "^[A-H]\t" | cut -f 1-13 | sed 's/,/./g' | sed 's/_\t/\t/g' | sed 's/_$//' > ${PLATE}.tmp
    fi
    Rscript ${BASEDIR}/wideToLong.R ${PLATE}.tmp
    rm ${PLATE}.tmp
fi
