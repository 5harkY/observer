# frozen_string_literal: true

require './config/environment'
# require_relative '../config/environment'
require './app/models/ip_address'
require './app/models/observation'
require './app/models/observation_result'

require './app/services/report'
require './app/services/ping'

require './app/jobs/pinger'

require './app/validation_contract'
