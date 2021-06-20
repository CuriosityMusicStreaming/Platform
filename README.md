# Platform

Platform for MusicStreaming microservices. 
It contains devtools to build services and local environment(MySQLm RabbitMQ) to run services locally

### Common principles

* Each microservice build and dockerized independently
* Each microservice has own database
* Each service after launch migrate own database
* Platform provides configured MySQL as database server and RabbitMQ as message broker to provide asynchronous interaction 
* Each microservice configured by environment variables and configured in docker-compose.yml in Platform
* Some microservices may depend on others, so it's written in their repo README.md files and configured in Platform docker-compose.yml
* Each microservice has own API that stored in [ApiStore](https://github.com/CuriosityMusicStreaming/ApiStore) 
  and synchronized in build phase by [apisynchronizer](https://github.com/UsingCoding/ApiSynchronizer)
* Why Curiosity? - Cause curiosity never ends.   

### Dependencies

Instruments:
* Docker 
* Docker-compose - to launch in local environment

MusicStreaming microservices:
* [ApiGateway](https://github.com/CuriosityMusicStreaming/ApiGateway) - simple apigateway for services
* [ContentService](https://github.com/CuriosityMusicStreaming/ContentService) - service to manage user content
* [PlaylistService](https://github.com/CuriosityMusicStreaming/PlaylistService) - service organize user content to playlists
* [UserService](https://github.com/CuriosityMusicStreaming/UserService) - service to manage users

### Installation

You need to _install_ Platform to have ability 
to run devtools provided by there and launch it from anywhere

Steps:

* Add `./bin` to $PATH

### Run

To run platform you need:
 - `./bin/curiosity-up`. 

It creates local environment, migrate databases(each microservice has own databases and migrate it independently of others), 
downloads microservices images from docker hub if not found locally

### Commands

`./bin/curiosity-up` - up platform
`./bin/curiosity-down` - stop platform
`./bin/curiosity-restart` - restart platform
`./bin/curiosity-logs-services` - watch services logs