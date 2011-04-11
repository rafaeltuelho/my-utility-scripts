#!/bin/sh

# Put your own values
PROXY_IP=127.0.0.1
PROXY_PORT=5865

nc -x${PROXY_IP}:${PROXY_PORT} -X5 $*

