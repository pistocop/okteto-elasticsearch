#!/bin/bash

SCRIPT_DIR=${0%/*}
cd "${SCRIPT_DIR}"

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${RED}Warning: ${GREEN}the old certificates will be deleted, process start in 5 seconds...${NC}"
secs=5
while [ $secs -gt 0 ]; do
   echo -ne "$secs\033[0K\r"
   sleep 1
   : $((secs--))
done


echo -e "${GREEN}Generating ES certificates...${NC}"
chmod u+x ./certgen.sh
docker run --rm -u root \
            --name deploy-es-cert-gen \
            --mount type=bind,src=$(pwd)/../,dst=/usr/share/elasticsearch/mount/ \
            --entrypoint /usr/share/elasticsearch/mount/scripts/certgen.sh \
            docker.elastic.co/elasticsearch/elasticsearch:8.2.2


echo -e "${GREEN}Certificate generated:${NC}"
ls -l ../certs/

