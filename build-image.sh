#!/bin/bash

echo "Building image"

echo -e "\nbuild docker hadoop image\n"
sudo docker build -t mariablanco/hadoop-cluster:v1 .

echo "Image built"