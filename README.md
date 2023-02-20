# observer
Simple app for checking availability of remote ip addresses. 
It can send an ICMP request to a remote ip address and form a report of it availabiility in given time period

#### Add ip address to observation 
`curl -d "address=8.8.8.8" -X POST http://localhost:9292/observations/start`

#### Stop observing an ip address 
`curl -d "address=8.8.8.8" -X POST http://localhost:9292/observations/stop`

#### Build a report of address availability 
`curl -d "address=8.8.8.8&start_time=01.01.2023 00:00&end_time=23:59" -X GET http://localhost:9292/report`

## CLI commands

* `bin/console` - run app console
* `rackup` - start web server
* `bin/sidekiq` - start sidekiq server
* `rake db:create` - create database within environment
* `rake db:migrate` - run database migrations
* `rake db:seed` - populate database with sample data
* `rspec` - run tests

## Dev setup (with docker-compose)
As an alternative to self-hosted app, you can run it with docker-compose by running `docker-compose up`
