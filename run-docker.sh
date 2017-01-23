#!/usr/bin/env bash

CONTAINER_ID=$(docker run -u zap -p 2375:2375 -d owasp/zap2docker-weekly zap-x.sh -daemon -port 2375 -host 127.0.0.1 -config api.disablekey=true -config scanner.attackOnStart=true -config view.mode=attack)

# the target URL for ZAP to scan
TARGET_URL=$1

docker exec $CONTAINER_ID zap-cli -p 2375 status -t 60 && docker exec $CONTAINER_ID zap-cli -p 2375 open-url $TARGET_URL

docker exec $CONTAINER_ID zap-cli -p 2375 spider $TARGET_URL

# currently causes crash (firefox not working with xvfb in weekly build)
#docker exec $CONTAINER_ID zap-cli -p 2375 ajax-spider $TARGET_URL

docker exec $CONTAINER_ID zap-cli -p 2375 active-scan -r $TARGET_URL

#docker exec $CONTAINER_ID zap-cli -p 2375 alerts

#generate report and get it out of the container
docker exec $CONTAINER_ID zap-cli -p 2375 report -o container-report.xml -f xml
docker exec $CONTAINER_ID cat container-report.xml > host-report.xml

#get session and logs for debugging purposes
docker exec e5d0d62dc94f zap-cli -p 2375 session save ./zap-session
docker cp $CONTAINER_ID:$(docker exec $CONTAINER_ID pwd)/zap-session ./zap-session
docker logs $CONTAINER_ID > docker-log.txt

# docker logs [container ID or name]
divider==================================================================
printf "\n"
printf "$divider"
printf "ZAP-daemon log output follows"
printf "$divider"
printf "\n"

docker logs $CONTAINER_ID

docker stop $CONTAINER_ID
