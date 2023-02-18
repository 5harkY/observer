# frozen_string_literal: true

require './app/observations_api'

run Rack::URLMap.new('/' => ObservationsApi)
