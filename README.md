# Okteto Elasticsearch
> Deploy [Elasticsearch 8.x](https://github.com/elastic/elasticsearch) cluster on [Okteto Cloud](https://cloud.okteto.com/)


## ✨ Features
- Elasticsearch _8.5.0_ version
- Cluster composed of 3 nodes
- Deployable under the [Okteto Cloud free tier](https://www.okteto.com/pricing/)
- Protected by Elasticsearch [password](https://www.elastic.co/guide/en/elasticsearch/reference/current/built-in-users.html#bootstrap-elastic-passwords), internode [TLS](https://www.elastic.co/guide/en/elasticsearch/reference/master/configuring-tls.html) and [HTTPS connection](https://www.okteto.com/docs/cloud/ssl)
- Okteto [development environment](https://www.okteto.com/development-environments/) based on [`busybox-curl`](https://hub.docker.com/r/yauritux/busybox-curl) image


## 🚀 Steps
- Create an [Okteto account](https://www.okteto.com/try-free/), install and configure the [Okteto CLI](https://www.okteto.com/docs/getting-started/)
- Clone the [okteto-elasticsearch](https://github.com/pistocop/okteto-elasticsearch) repo
- Generate the ES certificates:
    - Start Docker and run `$ bash scripts/certgen-launcher.sh`
- Deploy on Okteto
    - Run `$ okteto deploy --build`
    - Check the created endpoint from the previous output
- Call the ES endpoint:
    - Note: if not configured [1], `<your-password>` value is `changeme`
    ```
    $ curl -XGET -u elastic:<your-password> https://<your-endpoint-created>.cloud.okteto.net/_cat/nodes\?v

    # Example:
    $ curl -XGET -u elastic:changeme https://es01-http-mynamespace.cloud.okteto.net/_cat/nodes\?v
    ip          heap.percent ram.percent cpu load_1m load_5m load_15m node.role   master name
    10.8.38.167            7          62  32    1.69    1.41     0.93 cdfhilmrstw *      es02
    10.8.38.166           10          60  27    1.69    1.41     0.93 cdfhilmrstw -      es01
    10.8.38.168           11          62  36    1.69    1.41     0.93 cdfhilmrstw -      es03
    ```
- Enjoy your cluster!
    - Do you want to use [Kibana](https://www.elastic.co/kibana/)? see [2]
    - Don't waste free resources, if you don't need the cluster tear down everything with `$ okteto destroy -v`


## ✍️ Notes
- Security is provided by:
    - [TLS internode](https://www.elastic.co/guide/en/elasticsearch/reference/master/secure-cluster.html) communication with user-generated certificates
    - [HTTPS endpoint](https://www.okteto.com/docs/cloud/ssl) with Okteto managed certificates
- Kubernetes
    - Instead of declaring directly the GKE ingress, we will use the Okteto provided auto SSL
        - Through the `dev.okteto.com/auto-ingress: "true"` annotation
    - We will create one `ClusterIP` for each note for port `9300`
        - Because ES uses that as the default port for internode communication

### 🔧 How to
- [1] Change the default Elasticsearch password:
    - Generate the base64 new password
        - `$ echo "NEW_PASSWORD" | tr -d \\n | base64 -w 0`
    - Open the the `k8s/elasticsearch.yml` file 
        - Use the generated value to replace the `ELASTIC_PASSWORD` value of the `Secret` component
- [2] Run Kibana locally
    - 🚧 Currently [WIP](https://github.com/pistocop/elastic-certified-engineer/tree/develop/dockerfiles/20_cluster8x-extenalkibana), waiting [this ES issue](https://github.com/elastic/elasticsearch/issues/89017) will be resolved
    - Run kibana locally and connect with Okteto cluster:
        - We run the docker locally to don't waste the okteto cloud resources

## ⚒️ Okteto

**Development environment**
- We could test the internode network thanks to [Okteto development environment](https://www.okteto.com/docs/reference/development-environment)
    ```
    # Start the busybox-curl pod
    $ okteto up

    # The pod is mounted with all the local files, including the certificates:
    > ls -l /okteto/
    Dockerfile  README.md   certs       k8s         okteto.yml  scripts

    # The pod is deployed into the cluster and could use the certificates:
    > curl -u elastic:changeme es-http:9200
    {
      "name" : "es01",
      "cluster_name" : "okteto-cluster",
    ...

    > nc -vz es01 9300
    es01 (10.153.19.186:9300) open
    ```
**Sleeping system**
-  Q: "How can I restart a sleeping development environment?" - [link](https://www.okteto.com/pricing/?plan=SaaS)
    - A: Visit any of the public endpoints of your development environment

**Okteto useful commands**
```
# Log into the cluster
$ okteto init

# Deploy the local `okteto.yml` - wait 5/10m
$ okteto deploy --wait

# Activate a development container
# > https://www.okteto.com/docs/reference/cli/#up
$ okteto up

# Create kubectl context to Okteto cloud
$ okteto kubeconfig
$ kubectl get po
```


## 🛂 Disclaimer
This repository is built for side-project purposes and no warranties are provided.
Activities to keep in mind before using in production environments includes but are not limited to:
- We will arbitrarily expose the `es01` node as API server:
    - So we don't have load balancing between the API requests
    - There is no guarantee that `es01` isn't chosen as the master node
- Create a more robust ES architecture with dedicated ES master nodes
- Fine-tune the ES nodes' roles and HW requirements
- All the points listed in the "TODO" section


## 💤 TODOs
- [ ] mount data volumes on `/usr/share/elasticsearch/data` to ensure the pods' data persistence
- [ ] avoid storing the ES password in the yaml file
- [ ] integrate the [elasticsearch-readonlyrest-plugin](https://github.com/sscarduzio/elasticsearch-readonlyrest-plugin)
