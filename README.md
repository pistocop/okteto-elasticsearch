# Okteto Elasticsearch
> Deploy 3 [Elasticsearch](https://github.com/elastic/elasticsearch) nodes on [Okteto Cloud](https://cloud.okteto.com/)


## ✨ Features
- Elasticsearch 8.5.0 version
- Cluster composed by 3 nodes
- Deployable on [Okteto Cloud free tier](https://www.okteto.com/pricing/)
- Protected by [Elasticsearch password](https://www.elastic.co/guide/en/elasticsearch/reference/current/built-in-users.html#bootstrap-elastic-passwords) and [HTTPS connection](https://www.okteto.com/docs/cloud/ssl)
- [Okteto development environment](https://www.okteto.com/development-environments/) based on `busybox` image


## 🚀 Steps
- Create an [Okteto account](https://www.okteto.com/try-free/) install and configure the [Okteto CLI](https://www.okteto.com/docs/getting-started/)
- Clone the [okteto-elasticsearch](https://github.com/pistocop/okteto-elasticsearch) repo
- Generate the ES certificates:
    - Start Docker and run `$ bash scripts/certgen-launcher.sh`
- Deploy on Okteto
    - Run `$ okteto deploy --build`
    - Read from the command output the Endpoints link created and use on the following `curl`
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
    - Don't waste free resources, if you don't need the cluster tear down everything with `$ okteto destroy -v`
    - Want to use [Kibana](https://www.elastic.co/kibana/)? see [2]


## ✍️ Notes
- Security is provided by:
    - [TLS internode](https://www.elastic.co/guide/en/elasticsearch/reference/master/secure-cluster.html) communication with user-generted certificates
    - [HTTPS endpoint](https://www.okteto.com/docs/cloud/ssl) with Okteto managed certificates
- Kubernetes
    - Instead use the GKE ingress, we will use the Okteto provided auto SSL
        - Through the `dev.okteto.com/auto-ingress: "true"` annotation
    - We will create one `ClusterIP` for each note for the port `9300`
        - Because ES use that as default port for intranode communication

### How to
- [1] Change the default Elasticsearch password:
    - Generate the base64 new password
        - `$ echo "NEW_PASSWORD" | tr -d \\n | base64 -w 0`
    - Open the the `k8s/elasticsearch.yml` file 
        - Use the generated value to replace the `ELASTIC_PASSWORD` value of the `Secret` component
- [2] Run Kibana locally [TODO]
    - Run kibana locally and connect with Okteto cluster:
        - We run the docker locally for don't waste the okteto cloud resources
        - This introduce higher latency but better ES performances
    ```
$ curl -X POST -u elastic:changeme "https://es-http-pistocop.cloud.okteto.net/_security/service/elastic/kibana/credential/token/token1?pretty"
{
  "created" : true,
  "token" : {
    "name" : "token1",
    "value" : "AAEAAWVsYXN0aWMva2liYW5hL3Rva2VuMTp3Q2F6VE9zSFJ4NllSWjJnelhyLUF3"
  }
}

    ```



## ⚒️ Okteto

**Development environment**
- We could test the intranode connection thanks to [Okteto development environment](https://www.okteto.com/docs/reference/development-environment)
    ```
    # Start the busybox-curl pod
    $ okteto up

    # The pod is mounted with all the local files,
    # including the certificates:
    > ls certs/
    ca             es01           es02           es03           instances.yml

    # The pod is deployed into the cluster
    # and could test the certificates:
    [TODO] > curl -u elastic:changeme svc/es01:9200
    [TODO] > curl -XGET --cacert ./certs/ca/ca.crt -u elastic:changeme svc/es01:9200
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
This repository is build for side-project purposed and no warranties are provided.
Activities to keep in mind before using in production environments includes but are not limited to:
- We will arbitrary expose the `es01` node as API server:
    - So we don't have load balancing between the API requestes
    - There is no guarantee that `es01` isn't choosed as master node
- Create a more robust ES architecture with dedicated ES master nodes
- Fine-tune the ES nodes roles and HW requirements
- All the point listed on "TODO" section


## 💤 TODOs
- [ ] mount data volumes on `/usr/share/elasticsearch/data` to ensure pod's data persistence
- [ ] avoid to store the ES password into the yaml file
