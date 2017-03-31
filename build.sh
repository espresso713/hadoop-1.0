#!/bin/sh
docker rm -f namdenode
docker rm -f datanode
docker build -t namenode:1.0 .
docker build -t datanode:1.0 -f Dockerfile_datanode  .
docker run -it -d --name namdenode namenode:1.0
docker run -it -d --name datanode datanode:1.0
docker exec -it namdenode /bin/bash
