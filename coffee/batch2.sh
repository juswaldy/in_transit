#!/bin/bash

action=$1

rootfolder=/mnt/d/projects/coffee
batchname=batch2
batchfolder=$rootfolder/$batchname

################################################################################
## Grab html.
################################################################################
if [ $action == "html" ]; then
	for file in colombia-buesaco-alianza-de-granjeros-2018.html guatemala-antigua-pulcal-villa-sarchi-5855.html sweet-maria-s-ethiopiques-blend.html sweet-maria-s-new-classic-espresso.html sweet-maria-s-espresso-monkey-blend.html; do
		echo $file
		f=`echo $file | cut -d'/' -f2`
		phantomjs.exe get.js "https://www.sweetmarias.com/$file" > $batchfolder/$f
		sleep 3
	done

################################################################################
## Combine pics.
################################################################################
elif [ $action == "pics" ]; then
	width=200
	picsfile=$rootfolder/batch1-2-pics.html
	echo -n "" > $picsfile
	newlines="<br /><br /><br />"
	i=0

	batchname=batch1
	for file in brazil-santa-luzia-yellow-bourbon.png costa-rica-chirripo-finca-jose-gcx-5514.png ethiopia-illubabor-baaroo-cooperative.png ethiopia-yukiro-cooperative-gcx-5521.png flores-poco-ranaka.png guatemala-huehuetenango-finca-rosma-lot-1-2018.png guatemala-xinabajul-lo-mejor-de-cuilco.png mexico-organic-grupo-de-bella-vista.png; do
		echo $file
		if (($i % 4 == 0)); then echo "$newlines" >> $picsfile; fi
		echo "<img src='$batchname/pics/cupping.$file' width='$width' /><img src='$batchname/pics/flavor.$file' width='$width' />" >> $picsfile
		let "i++"
	done

	batchname=batch2
	for file in colombia-buesaco-alianza-de-granjeros-2018.png guatemala-antigua-pulcal-villa-sarchi-5855.png sweet-maria-s-altiplano-blend.png sweet-maria-s-espresso-monkey-blend.png sweet-maria-s-ethiopiques-blend.png sweet-maria-s-new-classic-espresso.png; do
		echo $file
		if (($i % 4 == 0)); then echo "$newlines" >> $picsfile; fi
		echo "<img src='$batchname/pics/cupping.$file' width='$width' /><img src='$batchname/pics/flavor.$file' width='$width' />" >> $picsfile
		let "i++"
	done
################################################################################
fi
