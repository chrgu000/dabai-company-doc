#!/bin/bash

NAME=mini-web-api
echo $NAME
ID=`ps -ef | grep "$NAME" | grep -v "$0" | grep -v "grep" | awk '{print $2}'`
echo $ID
echo "---------------"
for id in $ID
do
kill -9 $id
echo "killed $id"
done
echo "---------------"

nohup /usr/java/jdk1.8.0_211/bin/java -jar /home/apps/jingle-web-api/target/mini-web-api-1.0-SNAPSHOT.jar >/home/apps/tempmini.txt &
