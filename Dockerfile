FROM docker.elastic.co/elasticsearch/elasticsearch:8.5.0

COPY --chown=root:elasticsearch ./certs/ /usr/share/elasticsearch/config/certs/