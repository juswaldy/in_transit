#!/bin/bash

task=$1

################################################################################
## Extract jpg from pdf, and flip every other image.
################################################################################
if [[ $task == 'wlcsource' ]]; then
	rootdir=/home/jus/notebook/jus/bible/wlc
	sourcedir=$rootdir/source
	targetdir=$rootdir/source-devarim
	infile=$2
	startnum=$3
	evenodd=$4 # flip 0=even, 1=odd

	mkdir -p $targetdir
	pushd $sourcedir

	# Extract.
	mkdir -p tmp
	convert -density 600 $infile -quality 100 tmp/%04d.jpg

	# Flip.
	numfiles=`ls -1 tmp | wc -l`
	pushd tmp
	i=1
	for n in `seq 0 $(($numfiles-1))`; do
		from=$n
		to=$(($startnum+$n))
		fromfile=`printf "%04d.jpg" $from`
		tofile=`printf "$targetdir/devarim%04d.jpg" $to`
		if [ `expr $to % 2` -eq $evenodd ]; then
			convert $fromfile -rotate 180 $tofile
			echo flipped $fromfile $tofile
		else
			cp $fromfile $tofile
			echo copied $fromfile $tofile
		fi
	done
	popd

	# Clean up.
	rm -rf tmp

	popd

################################################################################
## Deskew and rotate pages.
################################################################################
elif [[ $task == 'deskew' ]]; then
	hebrewreader.py /home/jus/notebook/jus/bible/wlc source-devarim rotato

################################################################################
## Assemble into pdf.
################################################################################
elif [[ $task == 'topdf' ]]; then
	inputfolder=$2
	targetfile=$3
	quality=$4
	convert $inputfolder/*.jpg -quality $quality $targetfile

################################################################################
## Extract images from pdf and flip.
################################################################################
elif [[ $task == 'xflip' ]]; then
	rootdir=/home/jus/notebook/jus/bible/tyndale
	sourcedir=$rootdir/john
	targetdir=$rootdir/original
	infile=$2
	startnum=$3
	evenodd=$4 # flip 0=even, 1=odd

	mkdir -p $targetdir
	pushd $sourcedir

	# Extract.
	mkdir -p tmp
	convert -density 600 $infile -quality 100 tmp/%04d.jpg

	# Flip.
	numfiles=`ls -1 tmp | wc -l`
	pushd tmp
	i=1
	for n in `seq 0 $(($numfiles-1))`; do
		from=$n
		to=$(($startnum+$n))
		fromfile=`printf "%04d.jpg" $from`
		tofile=`printf "$targetdir/john%04d.jpg" $to`
		if [ `expr $to % 2` -eq $evenodd ]; then
			convert $fromfile -rotate 180 $tofile
			echo flipped $fromfile $tofile
		else
			cp $fromfile $tofile
			echo copied $fromfile $tofile
		fi
	done
	popd

	# Clean up.
	rm -rf tmp

	popd

################################################################################
else
	echo "usage: `basename $0` <task> <params>"
	echo "tasks: wlcsource"
fi

