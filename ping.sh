#!/bin/sh

URL=$1
CHANNEL=$2
CURL="curl -s -o /dev/null -w %{http_code} -X GET"
WEBHOOK_URL="${PHATPING_SLACK_WEBHOOK}"
FAIL_DIR=.
BIN_DIR=.
FILE="${FAIL_DIR}/$(echo ${URL} | tr '/' '-')"

RESULT=$($CURL ${URL})
case $RESULT in
	2*|3*)
		if [ -f ${FILE} ] ; then
			CREATED=$(stat -r ${FILE} | awk '{print $9}')
			EPOCH=$(date +%s)
			AGE=$(echo "$EPOCH - $CREATED" | bc)
			PRETTY_AGE=$(${BIN_DIR}/displaytime.sh $AGE)
			rm ${FILE}
			WEBHOOK_DATA=$(printf "{\"channel\":\"${CHANNEL}\",\"attachments\":[{\"fallback\":\"${URL} back after ${PRETTY_AGE}\",\"text\":\"${URL} back after ${PRETTY_AGE}\",\"color\":\"good\"}]}")
			curl -sX POST "${WEBHOOK_URL}" -d "${WEBHOOK_DATA}" -H "Content-Type: application/json" > /dev/null
			printf "{\"level\":\"NOTICE\",\"target_url\":\"${URL}\",\"status\":\"up\",\"downtime\":\"${AGE}\"}"
		fi
		exit 0;;
	000)
		printf "{\"level\":\"WARN\",\"target_url\":\"${URL}\",\"status\":\"failed\"}"
		exit 1;;
	*)
		if [ -f ${FILE} ] ; then
			exit 0
		fi
		touch ${FILE};
		WEBHOOK_DATA=$(printf "{\"channel\":\"${CHANNEL}\",\"attachments\":[{\"fallback\":\"${URL} returning ${RESULT}\",\"text\":\"${URL} returning *${RESULT}*\",\"color\":\"danger\"}]}")
		curl -sX POST "${WEBHOOK_URL}" -d "${WEBHOOK_DATA}" -H "Content-Type: application/json" > /dev/null
		printf "{\"level\":\"NOTICE\",\"target_url\":\"${URL}\",\"status\":\"down\"}";;
esac
