#!/bin/bash

parserscript=~/bin/dwparser.py
jztwutokens=jztwutokens.txt

pushd ~/sqlparser/analytics

# Get JZ TWU specific.
echo Get JZ TWU specific...
python $parserscript --connection jz_PROD --pattern 'TWU_%' --flatten > $jztwutokens

# Get the rest of the servers.
for db in aq fr ics jz; do
	echo Get ${db}...
	tokensfile=tokens.${db}.txt
	countsfile=counts.${db}.txt
	python $parserscript --connection ${db}_PROD --flatten > tokens.${db}.txt
	sort $tokensfile | uniq -c | sort -nr > $countsfile
done

tempfile=/tmp/z.txt

# Collect TWU specific from JZ, AQ and FR.
echo Collect TWU specific from JZ, AQ and FR...
tokensfile=tokens.twu.txt
countsfile=counts.twu.txt
cat $jztwutokens tokens.aq.txt tokens.fr.txt > $tokensfile
sort $tokensfile | uniq -c | sort -nr > $countsfile
sed 's/^ *//;s/ /|/' $countsfile > $tempfile
sed 's/ /|/' $tempfile > $countsfile

# Collect all.
echo Collect all...
tokensfile=tokens.all.txt
countsfile=counts.all.txt
cat tokens.*.txt > $tokensfile
sort $tokensfile | uniq -c | sort -nr > $countsfile
sed 's/^ *//;s/ /|/' $countsfile > $tempfile
sed 's/ /|/' $tempfile > $countsfile

popd

pushd ~/sqlparser
rm -f analytics.tar.gz
tar cvf analytics.tar analytics
gzip -9 analytics.tar
popd
