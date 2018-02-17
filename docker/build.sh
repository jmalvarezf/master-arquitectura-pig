#!/bin/bash

# Shared directory
SRC_DIR=$(pwd)
DST_DIR=/media/notebooks

# Pull images
docker pull accaminero/namenode01
docker pull swapnillinux/cloudera-hadoop-yarnmaster
docker pull swapnillinux/cloudera-hadoop-datanode

# Create directory for data sharing
mkdir -p ${SRC_DIR}

# Create network
docker network create hadoop

# Create Yarn master
docker run -d --net hadoop --net-alias yarnmaster --name yarnmastersl -h yarnmaster -p 8032:8032 -p 8088:8088 swapnillinux/cloudera-hadoop-yarnmaster

# Create name node
docker run -d --net hadoop --net-alias namenode --name namenodesl -h namenode -p 8020:8020 -p 8889:8889 -v ${SRC_DIR}:${DST_DIR} accaminero/namenode01

# Create data node
docker run -d --net hadoop --net-alias datanode1 --name datanode1sl -h datanode1 --link namenodesl --link yarnmastersl -p 8042:8042 -p 50020:50020 -p 50075:50075 swapnillinux/cloudera-hadoop-datanode
docker run -d --net hadoop --net-alias datanode2 --name datanode2sl -h datanode2 --link namenodesl --link yarnmastersl swapnillinux/cloudera-hadoop-datanode
docker run -d --net hadoop --net-alias datanode3 --name datanode3sl -h datanode3 --link namenodesl --link yarnmastersl swapnillinux/cloudera-hadoop-datanode
docker run -d --net hadoop --net-alias datanode4 --name datanode4sl -h datanode4 --link namenodesl --link yarnmastersl swapnillinux/cloudera-hadoop-datanode

# Get IP addresses
for NODE in $(docker ps --format '{{.Names}}'); do
    echo "$(docker inspect ${NODE} | grep IPAddress | grep 172 | cut -d ':' -f2 | sed 's/\"//g' | sed 's/,//g') $( echo $NODE | sed 's/sl//g')"
done | sort
echo "Now include above lines in /etc/hosts"
