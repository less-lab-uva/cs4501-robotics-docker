#!/bin/sh
# adapted from https://jtreminio.com/blog/running-docker-containers-as-current-host-user/
rm .env 2> /dev/null
echo "USER_NAME=$USER" >> .env
echo "USER_ID=$(id -u ${USER})" >> .env
echo "GROUP_ID=$(id -g ${USER})" >> .env
