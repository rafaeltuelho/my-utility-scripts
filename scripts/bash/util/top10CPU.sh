#!/bin/sh

ps -eo pcpu,pid,user,args | sort -k 1 -r | head -10
