require './app/observations_api'

# run Sinatra::Application
run Rack::URLMap.new("/" => ObservationsApi)