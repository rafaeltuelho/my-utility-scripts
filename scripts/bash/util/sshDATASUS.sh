#!/bin/sh

echo "ssh em $1..."
ssh -p 37259 -X consultor@$1
