---
layout: post
title:  "Welcome to netlimy!"
date:   2018-02-25 15:00:00 +0700
categories: jekyll update
---

# netlimy - my own website
netlimy is an easy to use website self hosting framework. 
Setup your self hosted website in less than 10 minutes. Including 
continuous deployment.

netlimy offers a very similar feature set  to the great service 
[netlify](https://www.netlify.com/). It is for everyone who loves the
 convenience of netlify but does not want to miss full control. netlimy 
 is prepared for a full ci lifecylcle in [gitlab](https://www.gitlab.com).
 Deploy by pushing to your gitlab repo.

# Getting started with the local setup

You can tryout netlimy in two steps:

```
git clone https://github.com/siavash9000/netlimy.git
``` 

and then  

```
cd netlimy
docker-compose up
```  

in the folder netlimy. Now you can open your website
via [http://localhost:4000](http://localhost:4000) and start to adapt it. 
netlimy is prepared for automatic reload enabling an easy workflow:
1. Change a file and save it.
2. Reload [http://localhost:4000](http://localhost:4000) and inspect the change.


# Getting started with the production setup

Getting your netlimy website in production consists of setting up a 
server with docker swarm and then deploying to it.

## Provision a cloud server (skip if you already have a running docker swarm)
The easiest way to provision a cloud server for the purpose of setting up a docker swarm
is [dind-machine](https://github.com/siavash9000/dind-machine). dind-machine enables you to
to use [docker-machine](https://github.com/docker/machine) without installing it locally by 
providing a docker image with docker-machine. docker-machine comes with several 
[drivers](https://docs.docker.com/machine/drivers/) out of the box. To provision a 
[digitalocean](https://www.digitalocean.com/), create a digitalocean account and a 
[personal access token](https://www.digitalocean.com/community/tutorials/how-to-use-the-digitalocean-api-v2).
Then perform the following commands:  

1. pull the docker image of dind-machine:  
```
docker pull nukapi/dind-machine
```  
2. Define the path DIND_MACHINE_DATA to the sensitive docker-machine data:  
```
mkdir -p ~/.dind-machine
export DIND_MACHINE_DATA=~/.dind-machine
echo  'export DIND_MACHINE_DATA=~/.dind-machine' >> ~/.bashrc
```  
3. define an alias for dind-machine with:  
```
alias dind-machine="docker run -v $DIND_MACHINE_DATA:/root/.docker/ nukapi/dind-machine docker-machine"
echo 'alias dind-machine="docker run -i -v $DIND_MACHINE_DATA:/root/.docker/ nukapi/dind-machine docker-machine"' >> ~/.bashrc
```  

Now you can provision a cloud server in one command and initialize docker swarm on it. 
For example you can provision a digitalocean server for $0.007/hr and init a docker 
swarm on it by replacing `PERSONAL_ACCESS_TOKEN` with your digitalocean personal access 
token and perform the following commands to provision a small digitalocean cloud server:  

```
dind-machine create --driver digitalocean \  
--digitalocean-access-token=PERSONAL_ACCESS_TOKEN \  
--engine-install-url https://raw.githubusercontent.com/rancher/install-docker/master/17.12.0.sh \  
--digitalocean-size 1gb myserver  

dind-machine ssh myserver docker swarm init

```

Verify your setup with 
```
dind-machine ls 

NAME            ACTIVE   DRIVER         STATE     URL                         SWARM   DOCKER        ERRORS
myserver        -        generic        Running   tcp://MYSERVER_IP:2376              v17.12.0-ce   


dind-machine ssh myserver docker node ls

ID                            HOSTNAME            STATUS              AVAILABILITY        MANAGER STATUS
n5kwc4ukzpegh9374b31v7sde *   myserver            Ready               Active              Leader

```

## Deploy automatically via gitlab (recommended)

You need a github account Import the netlimy project 


## Deploy manually to your swarm
```
eval $(dind-machine env myserver --shell zsh) && export DOCKER_CERT_PATH="$DIND_MACHINE_DATA/machine/machines/myserver"
sudo -E docker node ls
```

## improve deployment speed
```
dind-machine ssh myserver docker run -i -v /srv/gitlab-runner/config:/etc/gitlab-runner gitlab/gitlab-runner register
dind-machine ssh myserver docker run --rm -d --name gitlab-runner -v /var/run/docker.sock:/var/run/docker.sock -v /srv/gitlab-runner/config:/etc/gitlab-runner gitlab/gitlab-runner:latest

```

```
privileged = true
volumes = ["/cache", "/var/run/docker.sock:/var/run/docker.sock"]

```