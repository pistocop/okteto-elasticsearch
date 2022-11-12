#!/usr/bin/env bash
# Shell tips from: https://sharats.me/posts/shell-script-best-practices/

set -o errexit
set -o pipefail

if [[ "${TRACE-0}" == "1" ]]; then # Debug mode: TRACE=1 ./script.sh
  set -o xtrace
fi

if [[ "${1-}" =~ ^-*h(elp)?$ ]]; then
  echo 'Usage: ./kibana-run.sh ES-HOST ES-USER ES-PSW

This bash script run a Kibana docker container attached to Elasticsearch "ES-HOST"
provided as input, using the "ES-USR" and "ES-PSW" (password) credentials.

'
  exit
fi

main() {
  if [ -z "$1" ]; then
    echo "ERROR: ES cluster HOST parameter not supplied" >&2
    exit 1
  fi
  if [ -z "$2" ]; then
    echo "ERROR: ES cluster TOKEN parameter not supplied" >&2
    exit 1
  fi

  ES_HOST="$1"
  ES_TOKEN="$2"
  KIB_VER="8.5.0"
  GREEN='\033[0;32m'
  NC='\033[0m'

  echo -e "${GREEN}Running Kibana on Docker, visit http://localhost:5601, exit with 'ctrl+c'${NC}"
  docker run --rm --name kib-01 -p 5601:5601 \
    -e ELASTICSEARCH_SEARCH="$ES_HOST" \
    -e ELASTICSEARCH_SERVICEACCOUNTTOKEN="$ES_TOKEN" \
    docker.elastic.co/kibana/kibana:"$KIB_VER"

}

main "$@"
