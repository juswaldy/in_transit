#!/bin/bash

task=$1

################################################################################
## Extract apps.
################################################################################
if [[ $task == 'apps' ]]; then
	prefix=$2 # Specify WE_ for all files.
	sourcedir=/home/jus/bak/ERx
	targetdir=/home/jus/pssst/sim
	for f in `ls -1 $sourcedir/${prefix}*.tar.gz | sort -n -t_ -k3`; do
		echo $f
		for object in Account.csv Contact.csv hed__Term__c.csv EnrollmentrxRx__Term__c.csv EnrollmentrxRx__Enrollment_Opportunity__c.csv EnrollmentrxRx__Program_Catalog__c.csv; do
			echo "tar zxvf $f -C $targetdir --wildcards */$object"
			tar zxvf $f -C $targetdir --wildcards */$object
		done
	done

	# Clean up empty folders.
	#pushd $targetdir
	#for d in `ls -d !(*_1_*)`; do
	#	rm -rf $d
	#done
	#popd

################################################################################
## Extract field names from objects.
################################################################################
elif [[ $task == 'fields' ]]; then
	specific=$2 # Leave blank for all files.
	rootdir=/home/jus/pssst
	sourcedir=$rootdir/sim
	object=EnrollmentrxRx__Enrollment_Opportunity__c.csv
	for object in Account.csv Contact.csv EnrollmentrxRx__Enrollment_Opportunity__c.csv; do
		targetdir=$rootdir/fields/$object
		mkdir -p $targetdir
		for d in `ls -d1 $sourcedir/${specific} | sort -n -t_ -k4`; do
			version=`echo $d | cut -d'_' -f4 | cut -d'.' -f1`
			sub=`echo $d | cut -d'_' -f3`
			echo ${version}_${sub}
			head -1 $d/$object | sed 's/"//g;s/,/\n/g'
#			head -1 $d/$object | sed 's/"//g;s/,/\n/g' | sort | uniq > $targetdir/${version}.txt
		done
#		pushd $targetdir
#		rm allfields.txt combined.txt counts.txt
#		cat *.txt | sort | uniq > allfields.txt
#		popd
	done

################################################################################
else
	echo "usage: "`basename "$0"`" <task> <params>"
	echo "tasks: apps fields"
fi

