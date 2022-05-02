#!/bin/bash

N=$2

if [ $# = 0 ]
then
	echo "Node of the cluster: "
	exit 1
fi

# change slaves file
i=1
rm config/slaves
while [ $i -lt $N ]
do
	echo "hadoop-slave$i" >> config/slaves
	((i++))
done 

echo ""

echo -e "\nbuild docker hadoop image\n"

# rebuild kiwenlau/hadoop image
sudo docker build -t mariablanco/hadoop-cluster:v1 .

echo ""