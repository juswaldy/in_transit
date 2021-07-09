#!/bin/bash

codedir=/home/jus/github/tensorflow-fast-style-transfer
stdir=/home/jus/notebook/jus/styletransfer
modeldir=$stdir/hwalsuklee/model
content=$stdir/pics/lastsupper.jpg
outputdir=$stdir/results/hwalsuklee/lastsupper.jpg

pushd $codedir
i=0

for style in $modeldir/*/*; do
	outputfile=`basename $style`
	python run_test.py --content $content --style_model $style/final.ckpt --output $outputdir/$outputfile --gpu $i
	if (($i % 2 == 0)); then
		i=1
	else
		i=0
	fi
done

#IFS=';'
#pairs=`find $modeldir -iname 'final.ckpt.data-00000-of-00001' -exec dirname {} \; | xargs -n2 bash -c 'echo $1 $2\;' bash`
#for pair in $pairs; do
#	IFS=' '
#	for style in $pair; do
#		outputfile=`basename $style`
#		echo $style $outputfile
#		python run_test.py --content $content --style_model $style/final.ckpt --output $outputdir/$outputfile --gpu $i
#		if (($i % 2 == 0)); then
#		       	i=1
#		else
#		       	i=0
#		fi
#		test $? -gt 128 && exit
#	done
#	IFS=';'
#done

popd

