# What is netlimy ?
netlimy is an easy to use and easy to scale self hosting framework for jekyll websites. It is based solely on docker and enables you to setup a running website including continuous delivery within a few minutes on your own infrastructure or any cloud server which can run docker and docker swarm. netlimy is for everyone who loves to conveniently run his own website while keeping full control over its infrastructure. Don't want too loose control? Just DIY. But without pain.

### Features:
* easy setup for your jekyll website.
* automatic https cert generation and updates. secure connection without hassle
* fast continuous delivery. push to git and netlimy builds and deploys your website automatically.
* rolling updates. deploy changes with no downtime.
* no dependencies but docker.
* easily extendable through docker. add own apis easily and within minutes. 
* easy scaling. add new server without pain.
* gitlab integration included.

## Requirements
To deploy netlimy in production you will need:
1. A running docker swarm. A single node swarm is perfectly ok.
2. A Domain resolving to a node of your swarm.
3. The website you want to deploy must be in a git repository, which is accessible via internet.

## Configure netlimy

The main part of the configuration is done in the file ```production.yml```. To deploy netlimy with your own website
to the following adaptions

1. Set `WEBSITE_GIT_REPO` to your own websites git repo
2. Set `DOMAINS` to your domains, Seperate them with a whitespace. Configure your domain to resolve to one or multiple
nodes of your docker swarm. You can do this on the website of your domain provider. *The dns configuration must be done before deploying netlimy. Otherwise netlimy will not be able to generate the certs neded for https.*
3. In the command of the nginx service on line 19 replace *netlimy.com* with your main domain whis is also listed in the variable `DOMAINS`
4. If your swarm consist of multiple nodes, take care that netlimy and nginx are deployed to the same node. You can do this
as described [https://docs.docker.com/compose/compose-file/#placement](https://docs.docker.com/compose/compose-file/#placement).

## Deploy netlimy

docker-machine gives you easily remote access to the docker daemon of your server. You can export the necessary variable environments easily with 
```
eval $(docker-machine env myserver)
```
and then list all your running services
```
docker service ls
```
or check the state of your nodes
```
docker node ls
```
You can deploy netlimy on your swarm by
```
cd netlimy
docker stack deploy -c production.yml netlimy
```
You can then list your services with
```
docker service ls
```
Take a look on the netlimy logs with
```
docker service logs netlimy_netlimy
```

## Setup a docker swarm in digital ocean (optional)
One easy way to provision a cloud server for the purpose of setting up a docker swarm
is docker-machine. There exist official and community driver for docker-machine for many 
cloud provider. You can provision a cloud server with docker installed in one command and 
initialize docker swarm on it.

The following example shows hot to provision one of the smallest avialable digitalocean server 
for $0.007/hr. Replace `YOUR_PERSONAL_ACCESS_TOKEN` with your digitalocean personal access 
token and perform the following command:  

```
docker-machine create --driver digitalocean \  
--digitalocean-access-token=YOUR_PERSONAL_ACCESS_TOKEN \  
--engine-install-url https://raw.githubusercontent.com/rancher/install-docker/master/17.12.0.sh \  
--digitalocean-size 1gb myserver  
```

Inspect your server: 
```
docker-machine ls 

NAME            ACTIVE   DRIVER         STATE     URL                         SWARM   DOCKER        ERRORS
myserver        -        digitalocean   Running   tcp://MYSERVER_IP:2376              v17.12.0-ce   
```

Init a docker swarm:
```
docker-machine ssh myserver docker swarm init
```
Inspect your swarm nodes:
```
docker node ls

ID                            HOSTNAME            STATUS              AVAILABILITY        MANAGER STATUS
n5kwc4ukzpegh9374b31v7sde *   myserver            Ready               Active              Leader
```

## Run netlimy locally (optional)

You can tryout netlimy easily with docker-compose. First clone the repo:
```
git clone https://github.com/siavash9000/netlimy.git
``` 
and then start netlimy
```
cd netlimy
docker-compose up
```  
Now you can open the netlimy website via [http://localhost](http://localhost). You can change the variable `WEBSITE_GIT_REPO` to your own jekyll website in the file `docker-compose.yml` and restart netlimy. netlimy delivers now your website! netlimy pulls the repo constantly and builds and redeploys the website in case of changes. You can test this mechanism by pushing a change to your website. Build and redeploy should be finished in few minutes, depending on the perfromance of your setup. 

## Scaling netlimy (optional)
Since netlimy is based `docker swarm` scaling means adding nodes to the swarm as described [here](https://docs.docker.com/engine/swarm/swarm-tutorial/add-nodes/) and incresing the replica count in production.yml.
Once added to the swarm, docker takes care of the load balancing and the deployment on the new node.
