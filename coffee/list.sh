#!/bin/bash

action=$1

rootfolder=/mnt/d/projects/coffee

################################################################################
## Search descriptions.
################################################################################
if [ $action == "search" ]; then
	urlprefix="https://www.sweetmarias.com/catalogsearch/result/?q=" # 5001-6400
	from=5001
	to=6400
	outfile=${from}-${to}.csv
	for n in `seq ${from} 1 ${to}`; do
		url="${urlprefix}${n}"
		let "sleeptime = $RANDOM/10000 + 1"
		link=`wget -q -O- $url | grep '<a class="product-item-link" href="' | cut -d'"' -f4`
		echo $url $sleeptime "${n}|${link}"
		echo "${n}|${link}" >> $outfile
		sleep $sleeptime
	done

################################################################################
## Products by id.
################################################################################
elif [ $action == "product" ]; then
	urlprefix="https://www.sweetmarias.com/catalog/product/view/id/" #
	from=16001
	to=20000
	outfile=${from}-${to}.csv
	for n in `seq ${from} 1 ${to}`; do
		url="${urlprefix}${n}"
		let "sleeptime = ($RANDOM/10000 + 1) / 2"
		link=`wget -q -O- $url | grep '<meta property="og:url" content="' | cut -d'"' -f4`
		echo $url $sleeptime "${n}|${link}"
		echo "${n}|${link}" >> $outfile
		sleep $sleeptime
	done

################################################################################
## Preliminary listing.
################################################################################
elif [ $action == "prelim" ]; then
	batchname=$2
	for f in $rootfolder/$batchname/*.html; do
		name=`grep 'og:title' $f | cut -d'"' -f4`
		score=`grep 'score-value' $f | cut -d'>' -f2 | cut -d'<' -f1`
		desc=`grep 'og:description' $f | cut -d'"' -f4 | sed 's/&nbsp;/ /g'`
		echo "$name - $score"
		echo $desc
		echo
	done

################################################################################
fi
