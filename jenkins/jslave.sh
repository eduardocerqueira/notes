#!/bin/bash
# chkconfig: 2345 20 80
# description: Jenkins slave daemon

# Source function library.
. /etc/init.d/functions

JAVA="/usr/bin/java"
ROOT_PATH="/home/fedora"
SWARM_CLIENT="$ROOT_PATH/swarm-client-1.22-jar-with-dependencies.jar"
JMASTER_URL="https://my-jenkins-master.com"
JSLAVE_NAME="static-jslave-F25"
JSLAVE_LABELS="static-jslave-F25"
USERNAME="eduardo"
PASSWORD="ae8103259c887fcb8f1933868416518"
LOG="$ROOT_PATH/jslave.log"

echo "Starting Static Jenkins Slave"

$JAVA -Xmx2048m -jar $SWARM_CLIENT \
	-master $JMASTER_URL \
	-name $JSLAVE_NAME \
	-executors 10 \
	-labels $JSLAVE_LABELS \
	-fsroot /home/fedora \
	-mode exclusive \
	-disableSslVerification \
	-username $USERNAME \
	-password $PASSWORD > $LOG

if [ $? -eq 0 ]; then
   echo "$JSLAVE_NAME connected to $JMASTER_URL"
else
   echo "Error starting $JSLAVE_NAME"
fi

