#!/bin/bash

task=$1

################################################################################
## Do for all jpg in input folder.
################################################################################
if [[ $task == 'folder' ]]; then
	folder=$2
	pushd $folder
	for f in `ls -1 *jpg | sort -n -t- -k2`; do
		tesseract $f $f.out
	done
	popd

################################################################################
else
	echo "usage: z.sh <task> <params>"
	echo "tasks: folder"
fi

