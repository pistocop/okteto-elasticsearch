#!/usr/bin/env bash

# [!] Warning: this script is designed to run inside the ES docker image

# Certificate generation steps took from official docker-compose:
# https://www.elastic.co/guide/en/elasticsearch/reference/current/docker.html#docker-file

echo "Deleting old certificates..."
rm -fr mount/certs/*

echo "Creating CA"
bin/elasticsearch-certutil ca --silent --pem -out mount/certs/ca.zip
unzip mount/certs/ca.zip -d mount/certs/

echo "Creating certs"
echo -ne \
    "instances:\n"\
    "  - name: es01\n"\
    "    dns:\n"\
    "      - es01\n"\
    "      - localhost\n"\
    "    ip:\n"\
    "      - 127.0.0.1\n"\
    "  - name: es02\n"\
    "    dns:\n"\
    "      - es02\n"\
    "      - localhost\n"\
    "    ip:\n"\
    "      - 127.0.0.1\n"\
    "  - name: es03\n"\
    "    dns:\n"\
    "      - es03\n"\
    "      - localhost\n"\
    "    ip:\n"\
    "      - 127.0.0.1\n" \
    >mount/certs/instances.yml

bin/elasticsearch-certutil cert --silent --pass "" \
    --in mount/certs/instances.yml \
    --out mount/certs/certs.zip \
    --ca-cert mount/certs/ca/ca.crt \
    --ca-key mount/certs/ca/ca.key

unzip mount/certs/certs.zip -d mount/certs
