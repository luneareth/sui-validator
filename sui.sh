#!/bin/bash
if ! [ -f docker-compose.yaml ]
then
wget https://raw.githubusercontent.com/MystenLabs/sui/main/docker/fullnode/docker-compose.yaml
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
wget https://github.com/MystenLabs/sui-genesis/raw/main/devnet/genesis.blob
fi
check_network=`docker network ls | grep sui-network`
if [ ${check_network} -neq 0 ]
then
  docker network rm sui-network
  docker network create sui-network
else
  docker network create sui-network
fi
docker-compose up -d
container_id=`docker ps | grep sui |  awk '{print $1}i'`
docker update --restart=unless-stopped ${container_id}

