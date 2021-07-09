#!/bin/bash

task=$1

rootdir=/home/jus/notebook/jus/bible/tyndale

function prep() {
	bookname=$1
	groupnum=$2
	startnum=$3
	evenodd=$4
	steps=$5
	if [[ $steps == *"1"* ]]; then tyndale.sh extract ${bookname}/*.${groupnum}.pdf; fi
	if [[ $steps == *"2"* ]]; then tyndale.sh flip ${bookname} $startnum $evenodd; fi
	if [[ $steps == *"3"* ]]; then echo "Cleaning up staging..."; rm -f $rootdir/processing/staging/*; fi
}

################################################################################
## Extract images from pdf into jpgs.
################################################################################
if [[ $task == 'extract' ]]; then
	infile=$2
	pushd $rootdir/processing/source
	convert -verbose -density 600 $infile -quality 100 ../staging/%07d.jpg
	popd

################################################################################
## Flip every other image.
################################################################################
elif [[ $task == 'flip' ]]; then
	bookname=$2
	startnum=$3
	evenodd=$4 # flip 0=even, 1=odd

	targetdir=$rootdir/0.original

	pushd $rootdir/processing/staging
	numfiles=`ls -1 . | wc -l`
	i=1
	for n in `seq 0 $(($numfiles-1))`; do
		from=$n
		to=$(($startnum+$n))
		fromfile=`printf "%07d.jpg" $from`
		tofile=`printf "$targetdir/${bookname}.%07d.jpg" $to`
		if [ `expr $to % 2` -eq $evenodd ]; then
			convert $fromfile -crop 3300x4200+0+0 -rotate 180 $tofile
			echo flipped $fromfile $tofile
		else
			convert $fromfile -crop 3300x4200+0+0 $tofile
			echo copied $fromfile $tofile
		fi
	done

	popd

################################################################################
## Assemble jpgs into pdf.
################################################################################
elif [[ $task == 'topdf' ]]; then
	inputfolder=$2
	targetfile=$3
	quality=$4
	pushd $rootdir
	convert $inputfolder/*.jpg -quality $quality $targetfile
	popd

################################################################################
## Cleanup target folders.
################################################################################
elif [[ $task == "cleanup" ]]; then
	pushd $rootdir
	rm -f 0.original/* 1.cropped/* 2.rotated/* 3.final/* *.html
	popd

################################################################################
## Run a tyndale preparation.
################################################################################
elif [[ $task == "process" ]]; then
	bookname=$2
	pushd $rootdir
	tyndale.py --bookname $bookname --action crop
	tyndale.py --bookname $bookname --action rotate
	tyndale.py --bookname $bookname --action finalize
	for s in 1.cropped 2.rotated 3.final; do
		find $s -type f | sort | sed 's/^/<img src="/;s/$/" width="100"\/>/' > ${s}.html
	done
	popd


################################################################################
## Run a tyndale preparation.
################################################################################
elif [[ $task == "prep" ]]; then

	bookname=$2

	pushd $rootdir

	if [[ $bookname == "01.john" ]]; then
		prep $bookname 01 1 0 123
		prep $bookname 02 8 0 123
		prep $bookname 03 20 0 123
		prep $bookname 04 32 0 123
		prep $bookname 05 44 0 123
		prep $bookname 06 56 0 123
		prep $bookname 07 68 0 123
	elif [[ $bookname == "02.mark" ]]; then
		prep $bookname 01 1 1 123
		prep $bookname 02 11 1 123
		prep $bookname 03 21 1 123
		prep $bookname 04 31 1 123
		prep $bookname 05 41 1 123
		prep $bookname 06 51 1 123
	elif [[ $bookname == "03.matthew" ]]; then
		prep $bookname 01 1 0 123
		prep $bookname 02 13 0 123
		prep $bookname 03 25 0 123
		rm $rootdir/0.original/${bookname}.0000034.jpg
		prep $bookname 04 34 0 123
		prep $bookname 05 44 0 123
		prep $bookname 06 54 0 123
		prep $bookname 07 64 0 123
		prep $bookname 08 74 0 123
		prep $bookname 09 84 0 123
	elif [[ $bookname == "04.luke" ]]; then
		prep $bookname 01 1 1 123
		prep $bookname 02 11 1 123
		prep $bookname 03 21 1 123
		prep $bookname 04 31 1 123
		prep $bookname 05 41 1 123
		prep $bookname 06 51 1 123
		prep $bookname 07 61 1 123
		prep $bookname 08 71 1 123
		prep $bookname 09 81 1 123
		prep $bookname 10 91 1 123
	elif [[ $bookname == "05.acts" ]]; then
		prep $bookname 01 1 1 123
		prep $bookname 02 11 1 123
		prep $bookname 03 21 1 123
		prep $bookname 04 31 1 123
		prep $bookname 05 41 1 123
		prep $bookname 06 51 1 123
		prep $bookname 06.x 61 1 123
		rm $rootdir/0.original/${bookname}.0000062.jpg
		mv $rootdir/0.original/${bookname}.0000061.jpg $rootdir/0.original/${bookname}.0000061.x.jpg
		prep $bookname 07 61 1 123
		mv $rootdir/0.original/${bookname}.0000061.x.jpg $rootdir/0.original/${bookname}.0000061.jpg
		prep $bookname 08 71 1 123
		prep $bookname 09 81 1 123
		prep $bookname 10 89 1 123
	elif [[ $bookname == "06.revelation" ]]; then
		prep $bookname 01 1 1 123
		prep $bookname 02 11 1 123
		prep $bookname 03 21 1 123
		prep $bookname 04 31 1 123
		prep $bookname 05 41 1 123
	elif [[ $bookname == "07.12peter" ]]; then
		prep $bookname 01 1 1 123
		prep $bookname 02 11 1 123
	elif [[ $bookname == "08.123john" ]]; then
		prep $bookname 01 1 0 123
		prep $bookname 02 10 0 123
		prep $bookname 03 12 0 123
	elif [[ $bookname == "09.james_jude" ]]; then
		prep $bookname 01 1 0 123
		prep $bookname 02 10 0 123
	elif [[ $bookname == "10.hebrews" ]]; then
		prep $bookname 01 1 1 123
		prep $bookname 02 11 1 123
		prep $bookname 03 21 1 123
	elif [[ $bookname == "11.romans" ]]; then
		prep $bookname 01 1 0 123
		prep $bookname 02 11 0 123
		prep $bookname 03 21 0 123
		prep $bookname 04 31 0 123
	elif [[ $bookname == "12.1corinthians" ]]; then
		prep $bookname 01 1 0 123
		prep $bookname 02 11 0 123
		prep $bookname 03 21 0 123
		prep $bookname 04 31 0 123
	elif [[ $bookname == "13.2corinthians" ]]; then
		prep $bookname 01 1 1 123
		prep $bookname 02 11 1 123
		prep $bookname 03 21 1 123
	elif [[ $bookname == "14.galatians" ]]; then
		prep $bookname 01 1 1 123
		prep $bookname 02 11 1 123
	elif [[ $bookname == "15.ephesians_philippians" ]]; then
		prep $bookname 01 1 1 123
		prep $bookname 02 11 1 123
		prep $bookname 03 21 1 123
	elif [[ $bookname == "16.colossians" ]]; then
		prep $bookname 01 1 0 123
	elif [[ $bookname == "17.12thessalonians" ]]; then
		prep $bookname 01 1 0 123
		prep $bookname 02 11 0 123
	elif [[ $bookname == "18.12timothy" ]]; then
		prep $bookname 01 1 1 123
		prep $bookname 02 11 1 123
	elif [[ $bookname == "19.titus_philemon" ]]; then
		prep $bookname 01 1 0 123
	elif [[ $bookname == "20.ToTheReder" ]]; then
		prep $bookname 01 1 1 123
	fi

	popd

################################################################################
else
	echo "usage: `basename $0` <task> <params>"
	echo "tasks: extract <infile in source folder>"
	echo "       flip <bookname> <startnum> <flipevenodd 0=even 1=odd>"
	echo "       topdf <inputfolder> <targetfile> <quality>"
	echo "       prep"
fi

