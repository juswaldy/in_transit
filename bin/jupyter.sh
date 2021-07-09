#!/bin/bash

rootfolder=/home/jus/notebook
for server in "jus 8080" "christian 8081" "lulu 8082" "PROD 8888" "juan 8083"; do
	folder=`echo $server | cut -d' ' -f1`
	port=`echo $server | cut -d' ' -f2`
	pushd $rootfolder/$folder
	nohup nice jupyter notebook --ip=* --port=$port --no-browser > /dev/null 2>&1 &
	popd
done
