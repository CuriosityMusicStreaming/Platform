# Platform for MusicStreaming services

Used to run services locally. Provides local environment(MySQL, RabbitMQ) and provides services environment configuration.

### Run

To run platform you need:
 - Build all services
 - Run `./bin/curiosity-up`. It creates local environment and databases if needed
 - (_optionally_) Add `./bin` to $PATH to run platform scripts in any dir

To stop/restart:
 - `./bin/curiosity-down`
 - `./bin/curiosity-restart`

To watch services logs run `./bin/curiosity-logs-services`