#!/bin/bash
sudo mkdir -p /usr/local/cuda /usr/local/cuda/extras/CUPTI /usr/local/cuda/nvvm
sudo ln -s /usr/bin /usr/local/cuda/bin
sudo ln -s /usr/include /usr/local/cuda/include
sudo ln -s /usr/lib/x86_64-linux-gnu /usr/local/cuda/lib64
sudo ln -s /usr/local/cuda/lib64 /usr/local/cuda/lib
sudo ln -s /usr/include /usr/local/cuda/extras/CUPTI/include
sudo ln -s /usr/lib/x86_64-linux-gnu /usr/local/cuda/extras/CUPTI/lib64
sudo ln -s /usr/lib/nvidia-cuda-toolkit/libdevice /usr/local/cuda/nvvm/libdevice
