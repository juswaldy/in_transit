#!/bin/bash

pushd /home/jus/openrefine-3.4.1
nohup nice ./refine -i 0.0.0.0 -m 8000m -p 3337 &
popd
