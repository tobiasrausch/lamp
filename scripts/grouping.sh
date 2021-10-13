#!/bin/bash

PLATE=${1}
cat names.tmp.out | awk '{print $2"\t"$1;}' | sed 's/H2O/H2O\tH2O/' | sed 's/negative/negative\tnegative/' | sed 's/\(TWIST.*\)$/\1\ttwist/' | sed 's/PC$/PC\tpc/' | awk '{if (NF==2) { print $0"\tsaliva";} else {print $0;} }'

if [ -f ${PLATE} ]
then
    echo ${PLATE}
    dos2unix ${PLATE}
    cat ${PLATE}  | sed 's/ /_/g' | sed 's/^[ \t]*//' | sed 's/[ \t][ \t]*/\t/g' | grep -P "^[A-H]\t" | cut -f 1-13 | sed 's/,/./g' | sed 's/_\t/\t/g' | sed 's/_$//' > ${PLATE}.tmp
    Rscript convertPlate.R ${PLATE}.tmp
    rm ${PLATE}.tmp
fi
