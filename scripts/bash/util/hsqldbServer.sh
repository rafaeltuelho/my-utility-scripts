#!/bin/sh

echo "iniciando o HSQLDB Server..."
java -cp ~/java/tools/hsqldb/lib/hsqldb.jar org.hsqldb.Server 2>&1 &
