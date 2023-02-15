# frozen_string_literal: true
require './config/environment'

require './app/models/observation'
require './app/jobs/pinger'

Observation.active.pluck(:id).each { |obs_id| Jobs::Pinger.perform_async(obs_id) }