# What is netlimy ?
netlimy is an easy to use and easy to scale website self hosting framework. It enables you to setup a running website including its continuous delivery within a few minutes on your own infrastructure. netlimy is for everyone who loves to conveniently run his own website and at the same time keep full control of the infrastructure.

## Features:
* no dependencies but docker.
* easy setup 
* fast and slick continuous delivery. push to git and see the content on your website 30 seconds later.
* form to email handler included. receive all form submissiions via email.
* easily extendable through docker. add own apis easily and within minutes. 
* easy scaling. add new server within seconds.
* gitlab integration included

# Getting started with the local setup

You can tryout netlimy easily with docker-compose. First clone the repo:

```
git clone https://github.com/siavash9000/netlimy.git
``` 

and then start netlimy

```
cd netlimy
docker-compose up
```  

Now you can open your website via [http://localhost](http://localhost) and start to adapt it. 
netlimy uses jekyyls livereload feature, so that you can see all changes you make without reloading 
in your browser.

# Getting started with the production setup

Getting your netlimy website in production consists of setting up a 
server with docker swarm and then deploying to it.

## Provision a cloud server (skip if you already have a server)
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


## Initialize a docker-swarm (Skip if you already have a running docker swarm)
If you use [dind-machine](https://github.com/siavash9000/dind-machine) you can init a docker swarm on your server by 
```
dind-machine ssh myserver docker swarm init
```
With docker-machine it is 
```
docker-machine ssh myserver docker swarm init
```
You can also initialize a docker swarm on shell on your server with
```
docker swarm init
```
# Access your docker swarm

dind-machine as well as docker-machine enable you to easily access the docker daemon of your server via command line.
You can inspect your running services 
```
eval $(dind-machine env myserver --shell zsh) && export DOCKER_CERT_PATH="$DIND_MACHINE_DATA/machine/machines/myserver"
sudo -E docker service ls

ID                  NAME                MODE                REPLICAS            IMAGE                                       PORTS
l72csb3o8y58        netlimy_nginx       replicated          2/2                 registry.gitlab.com/nukapi/netlimy:latest   *:80->80/tcp

```
or check the state of your nodes
```
ID                            HOSTNAME            STATUS              AVAILABILITY        MANAGER STATUS
7ggoswurrqm745by4mbc0uf6j *   myserver            Ready               Active              Leader
```

## Deploy netlimy automatically via gitlab (recommended)
netlimy has a `.gitlab-ci.yml` file, which defines a deployment to docker swarm on each successful build in [gitlab](https://www.gitlab.com). This enables you to update netlimy itself and all custom services you add just by pushing to your gitlab repo. You can customize the deployment process by adapting the ci file to your needs.  

You need a gitlab account to automatically deploy your website wit each git commit. Create a new project and import netlimy from github as described in [https://docs.gitlab.com/ee/user/project/import/github.html](https://docs.gitlab.com/ee/user/project/import/github.html).
Then create secret variables in your project settings as described in 
[https://docs.gitlab.com/ce/ci/variables/README.html#secret-variables](https://docs.gitlab.com/ce/ci/variables/README.html#secret-variables). You will need four variables:  
1. `NETLIMY_SERVER_IP`    
Write the ip adress of your server in this secret. If you used dind-machine or docker-machine for setting your server up,
you can obtain the ip by ``` dind-machine ls``` or ``` docker-machine ls```

2. `NETLIMY_TLSCACERT` , `NETLIMY_TLSCERT`, `NETLIMY_TLSKEY`  
These variables are used in the .gitlab-ci.yml file to deploy to your swarm. You can find the values
For `NETLIMY_TLSCACERT` you get the value with `sudo cat $DIND_MACHINE_DATA/machine/machines/myserver/ca.pem | xclip -i -selection clipboard` .
For `NETLIMY_TLSCERT` you get the value with `sudo cat $DIND_MACHINE_DATA/machine/machines/myserver/cert.pem | xclip -i -selection clipboard` .
For `NETLIMY_TLSKEY` you get the value with `sudo cat $DIND_MACHINE_DATA/machine/machines/myserver/key.pem | xclip -i -selection clipboard` .

That's it. Gitlab builds your website now each time you commit something to your repo. The build and deploy process is very 
simple and therefore easy to adapt or extend. Just check out the file .gitlab-ci.yml

# Add an API service and access it from your website via javascript
