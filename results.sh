#!/bin/bash

if [ $# -lt 1 ]
then
    echo "Usage: $0 <Plate1> <Plate2> <Plate3> ..."
    exit -1
fi

# Aggregate
echo -e "id\tgroup\tic\tcovid\tplate" > lamp.table
NUM=1
for F in $@
do
    echo ${F}
    cat ${F} | awk 'NR%2==0' | grep -v -P "Group\tValue" > lamp.table1
    cat ${F} | awk 'NR%2==1' | grep -v -P "Group\tValue" > lamp.table2
    echo "Any sample mismatches?"
    paste lamp.table1 lamp.table2  | awk '$3!=$8'
    paste lamp.table1 lamp.table2 | cut -f 3,4,5,10 | sed "s/$/\tP${NUM}/" >> lamp.table
    rm lamp.table1 lamp.table2
    NUM=`expr ${NUM} + 1`
done

# Summarize
python results.py -i lamp.table > results.tsv

# Plot
Rscript qc.R lamp.table

# Any replicates?
if [ `cat lamp.table | grep "saliva" | cut -f 1 | sort | uniq -d | wc -l | cut -f 1` -gt 0 ]
then
    cat lamp.table | grep "saliva" | cut -f 1 | sort | uniq -d > dup.samples
    head -n 1 lamp.table > lamp.replicates
    cat lamp.table | grep -w -Ff dup.samples >> lamp.replicates
    rm dup.samples
    # Exactly 2 replicates?
    if [ `tail -n +2 lamp.replicates | cut -f 1 | sort | uniq -c | grep -v "2 " | wc -l` -eq 0 ]
    then
	Rscript rep.R lamp.replicates
    fi
    rm lamp.replicates
fi
