#!/bin/bash

vid=$1
stylefrom=$2
styleto=$3
framefirst=$4
framelast=$5

rootfolder=/home/jus/notebook/jus/styletransfer/vids/${vid}
style1=${rootfolder}/${stylefrom}
style2=${rootfolder}/${styleto}
stagingfolder=${rootfolder}/staging

pushd /home/jus/bin
python transition.py --style1 $style1 --style2 $style2 --outfolder $stagingfolder --framefirst $framefirst --framelast $framelast
popd

