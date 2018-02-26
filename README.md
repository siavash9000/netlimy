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
netlimy uses lekyyls livereload feature, so that you can see all changes you make without reloading 
in your browser.

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

## Deploy automatically via gitlab

You need a gitlab account to automatically deploy your website wit each git commit. Create a new project and import from 
github netlimy as described in [https://docs.gitlab.com/ee/user/project/import/github.html](https://docs.gitlab.com/ee/user/project/import/github.html).
Then create secret variables in your project settings as described in 
[https://docs.gitlab.com/ce/ci/variables/README.html#secret-variables](https://docs.gitlab.com/ce/ci/variables/README.html#secret-variables). You will need four variables:  
1. `NETLIMY_SERVER_IP`    
Write the ip adress of your server in this secret. If you used dind-machine or docker-machine for setting your server up,
you can obtain the ip by ``` dind-machine ls``` or ``` docker-machine ls```

2. `NETLIMY_TLSCACERT` , `NETLIMY_TLSCERT`, `NETLIMY_TLSKEY`  
These variables are used in the .gitlab-ci.yml file to deploy to your swarm. You can find the values
For `NETLIMY_TLSCACERT` you get the value with `sudo cat $DIND_MACHINE_DATA/machine/machines/myserver/ca.pem` .
For `$NETLIMY_TLSCERT` you get the value with `sudo cat $DIND_MACHINE_DATA/machine/machines/myserver/cert.pem` .
For `NETLIMY_TLSCACERT` you get the value with `sudo cat $DIND_MACHINE_DATA/machine/machines/myserver/key.pem` .

That's it. Gitlab builds your website now each time you commit something to your repo. The build and deploy process is very 
simple and therefore easy to adapt or extend. Just check out the file .gitlab-ci.yml

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
# improve deployment speed

It takes around three minutes to build and deploy netlify in GitLab with their 
[shared runners](https://docs.gitlab.com/ee/ci/runners/#shared-vs-specific-runners). This means your website is updated 
around three minutes after pushing to GitLab. You might have noticed that docker is able to use a cache for image layers 
that did not changed. This caching can speed the build vastly. GitLabs ahred runner do not use this cacheing, but you 
can run a private runner on your server. The build and deployment time is reduced to 1 minute (small digital ocean machine). 
You can create a runner configuration interactively by 
```
dind-machine ssh myserver docker run -i -v /srv/gitlab-runner/config:/etc/gitlab-runner gitlab/gitlab-runner register
```

This creates the file `/srv/gitlab-runner/config/config.toml`. Since docker in docker is used for the creation of the 
docker images, we must change this file. Open a ssh shell on your server with
```
dind-machine ssh myserver
```
and open the file with vim
```
vim /srv/gitlab-runner/config/config.toml
```
Change the keys `priviliged` and `volumes` to the following values
```
privileged = true
volumes = ["/cache", "/var/run/docker.sock:/var/run/docker.sock"]
```
and start your private gitlab runner with
```
dind-machine ssh myserver docker run --rm -d --name gitlab-runner -v /var/run/docker.sock:/var/run/docker.sock -v /srv/gitlab-runner/config:/etc/gitlab-runner gitlab/gitlab-runner:latest

```

# Add an API service and access it from your website via javascript