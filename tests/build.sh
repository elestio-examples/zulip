#!/usr/bin/env bash
sed -i "s~ARG UBUNTU_MIRROR~ARG UBUNTU_MIRROR='http://us.archive.ubuntu.com/ubuntu/'~g" Dockerfile
docker buildx build . --output type=docker,name=elestio4test/zulip:latest | docker load
