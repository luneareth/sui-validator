#!/bin/bash
build="devnet"
tags="0.6.1"
version="${build}-${tags}"
blob_url="https://github.com/MystenLabs/sui-genesis/blob/tharbert/${version}/devnet/genesis.blob?raw=true"
docker_compose=file

if ! [ -f docker-compose.yaml ]
then
if [ ${docker_compose} == "file" ]
then
cat > docker-compose.yaml <<EOF
---
version: "3.9"
services:
  fullnode:
    container_name: sui-validator
    image:  mysten/sui-node:stable
    ports:
    - "9000:9000"
    - "9184:9184"
    expose:
    - "9000"
    - "9184"
    volumes:
    - ./fullnode.yaml:/sui/fullnode.yaml:ro
    - ./genesis.blob:/sui/genesis.blob:ro
    - suidb:/sui/suidb:rw
    command: ["/usr/local/bin/sui-node", "--config-path", "fullnode.yaml"]
volumes:
  suidb:
EOF
else
wget https://raw.githubusercontent.com/MystenLabs/sui/main/docker/fullnode/docker-compose.yaml
fi
sed -i 's/fullnode-template.yaml/fullnode.yaml/' docker-compose.yaml
fi
if ! [ -f fullnode.yaml ]
then
wget https://github.com/MystenLabs/sui/raw/main/crates/sui-config/data/fullnode-template.yaml
mv fullnode-template.yaml fullnode.yaml
sed -i 's/127.0.0.1:9184/0.0.0.0:9184/' fullnode.yaml
sed -i 's/127.0.0.1:9000/0.0.0.0:9000/' fullnode.yaml
fi
if ! [ -f genesis.blob ]
then
wget ${blob_url}
fi
check_network=`docker network ls | grep sui-network | wc -l`
if [ ${check_network} -neq 0 ]
then
  docker network rm sui-network
  docker network create sui-network
else
  docker network create sui-network
fi
docker-compose up -d
container_name=`docker ps | grep sui |  awk '{print $1}i'`
docker update --restart=unless-stopped ${container_name}

