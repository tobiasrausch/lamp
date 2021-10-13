#! /usr/bin/env python

from __future__ import print_function
import csv
import argparse
import sys
import collections
import numpy

# Parse command line
parser = argparse.ArgumentParser(description='Summarize results')
parser.add_argument('-i', '--infile', metavar='results.tsv', required=True, dest='infile', help='LAMP results (required)')
parser.add_argument('-t', '--threshold', metavar='0.3', type=float, required=False, dest='thres', help='threshold (optional)')
args = parser.parse_args()

# addFailSamples
#afail = set(['VZTBYZ', 'AZGDWT'])
afail = set([])

# qPCR
qpcr = dict()
#qpcr['O2X2HK'] = 'likely_positive'
#qpcr['X3EV9R'] = 'likely_positive'
#qpcr['NH8GFX'] = 'negative'
#qpcr['DX0YDO'] = 'negative'
#qpcr['KU8R64'] = 'negative'
#qpcr['EURFVTE'] = 'negative'
#qpcr['EHUAZEY'] = 'negative' 


# Estimate threshold
icval = collections.defaultdict(list)
thres = dict()
if args.infile:
    f_reader = csv.DictReader(open(args.infile), delimiter="\t")
    for fields in f_reader:
        if fields['group'] == "saliva":
            icval[fields['plate']].append(float(fields['ic']))
for pl in icval.keys():
    thres[pl] = numpy.percentile(numpy.array(icval[pl]), 75) - 0.1
    if thres[pl] > 0.3:
        thres[pl] = 0.3
if (args.thres):
    for pl in thres.keys():
        thres[pl] = float(args.thres)
print("IC and COVID threshold:", thres, file=sys.stderr)

# Classify results
print("BARCODE", "FAIL", "LAMP", "qPCR", "OUTCOME", "IC", "COVID", sep="\t")
if args.infile:
    f_reader = csv.DictReader(open(args.infile), delimiter="\t")
    for fields in f_reader:
        if fields['group'] != "saliva":
            continue
        fields['lamp'] = "unclear"
        if float(fields['covid']) > thres[fields['plate']]:
            fields['lamp'] = "likely_positive"
        elif float(fields['covid']) <= thres[fields['plate']]:
            fields['lamp'] = "negative"
        fields['failure'] = "no"
        if float(fields['ic']) <= thres[fields['plate']]:
            fields['failure'] = "yes"
        fields['qPCR'] = "na"
        if fields['id'] in qpcr.keys():
            fields['qPCR'] = qpcr[fields['id']]
        fields['outcome'] = "unclear"
        if fields['qPCR'] != "na":
            fields['outcome'] = fields['qPCR']
        else:
            # Lamp
            if fields['failure'] == "yes":
                fields['outcome'] = "fail"
            else:
                fields['outcome'] = fields['lamp']
        print(fields['id'], fields['failure'], fields['lamp'], fields['qPCR'], fields['outcome'], fields['ic'], fields['covid'], sep="\t")

# Add missing, failed samples
for s in afail:
    print(s, 'yes', 'na', 'na', 'fail', 0.0, 0.0, sep="\t")
