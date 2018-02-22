# netliself
Super simple self hosting, setup your self hosted website in less than 10 minutes

netliself helps you to setup an open source variant of a service similar to [netlify](https://www.netlify.com/) and host it yourself wherever you like! 

It includes simple form submission email forwarding, which allows you to add forms like newsletter subscription and get an email notification with the user input.  

netliself is prepared to run in gitlab and allows you to update your website by commiting to your gitlab repo.

The whole setup of the service after clicking a virtual server and configuring it, should take less than 10 minutes including ssl generation via letsencrypt.

You can use the exact same setup for production as well as for local development. Getting your development setup ready is done with one `docker-compose up`

# Getting started with the local setup

You can tryout netliself in two steps:

`git clone https://github.com/siavash9000/netliself.git` 

and then
`docker-compose up` 

in the folder netliself. Then you should be able to go to https://localhost and see the template website. netliself is prepared for aut reload. This means your website is rebuilt on every filechange you make, so that you can inspect your changes after a reload in the browser.


# Getting started with the production setup

Getting your website in production consists of setting up a server with a current docker and then deploying to it. We highly recommend you to user [docker-machine](https://github.com/docker/machine). Our following guide how to provision and setup a netliself on a vultr server, depends on docker-machine.

## Setup a server on vultr (skip if you already have server)

## Setup docker swarm on your server (skip if you already have a running swarm)

## Deploy manually to your swarm

## Deploy automatically via gitlab (recommended)
