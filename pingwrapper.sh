#!/bin/sh

CHANNEL="random"
BIN_DIR=.
INTERVAL=12 # seconds

while :; do
	for URL in https://ols.wtf ; do
		${BIN_DIR}/ping.sh $URL $CHANNEL
	done
sleep ${INTERVAL}
done
