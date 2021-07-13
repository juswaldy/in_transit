#!/bin/bash

action=$1

rootfolder=/mnt/d/projects/coffee
batchname=batch3
batchfolder=$rootfolder/$batchname

################################################################################
## Grab html.
################################################################################
if [ $action == "html" ]; then
	for file in burundi-kayanza-masha-station-6075.html burundi-kayanza-nemba-station-5957.html colombia-las-estrellas-de-urrao-6088.html guatemala-proyecto-xinabajul-tujlate-6162.html guatemala-xinabajul-antonio-castillo-6150.html kenya-kiambu-dagitu-6259.html kenya-kirinyaga-kabumbu-6255.html sumatra-honey-labu-aceh-mengaya-6108.html sweet-maria-s-espresso-monkey-blend.html sweet-maria-s-ethiopiques-blend.html sweet-maria-s-liquid-amber-espresso-blend.html sweet-maria-s-polar-expresso-holiday-blend-6314.html ethiopia-organic-sidama-shantawene-village-6285.html ethiopia-organic-dry-process-sidama-shantawene-6289.html kenya-nyeri-thageini-aa-6267.html green-coffee/guatemala-honey-process-finca-rosma-6266.html flores-laga-lizu-gnung-waja-mala-6054.html; do
		f=`echo $file | cut -d'/' -f2`
		phantomjs.exe get.js "https://www.sweetmarias.com/$file" > $batchfolder/$f
		sleep 3
	done

################################################################################
## Combine pics.
################################################################################
elif [ $action == "pics" ]; then
	width=200
	picsfile=$rootfolder/$batchname-pics.html
	echo -n "" > $picsfile
	newlines="<br /><br /><br />"
	i=0
	for file in `ls -1 $batchfolder/*.html`; do
		f=`echo $file | cut -d'/' -f7 | cut -d'.' -f1`
		echo $f
		if (($i % 4 == 0)); then echo "$newlines" >> $picsfile; fi
		echo "<img src='$batchname/pics/cupping.$f.png' width='$width' /><img src='$batchname/pics/flavor.$f.png' width='$width' />" >> $picsfile
		let "i++"
	done

################################################################################
fi
