#!/bin/bash

#docker rm vulcanexus-humble-run && docker rmi stepkun/vulcanexus:humble-run
docker build --target run -t stepkun/vulcanexus:humble-run -f humble.Dockerfile .

#docker rm vulcanexus-humble-devel && docker rmi stepkun/vulcanexus:humble-devel
docker build --target devel -t stepkun/vulcanexus:humble-dev -f humble.Dockerfile .

#docker rm vulcanexus-humble-full && docker rmi stepkun/vulcanexus:humble-full
docker build --target full -t stepkun/vulcanexus:humble-full -f humble.Dockerfile .
