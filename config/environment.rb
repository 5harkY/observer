# frozen_string_literal: true

ENV['ENVIRONMENT'] ||= 'development'

require 'pg'
require 'active_record'
require 'dotenv'
require 'yaml'
require 'erb'

# By default Dotenv.load for loading environment variables reaches out
# to the `.env` file, so if we want to use other environments it is worth
# extending this to the method below, which will first for a set development
# environment look for a file ending in `.env.development.local`,
# then `.env.development` and finally `.env`.

Dotenv.load(".env.#{ENV.fetch('ENVIRONMENT')}.local", ".env.#{ENV.fetch('ENVIRONMENT')}", '.env')

def db_configuration
  db_configuration_file_path = File.join(File.expand_path('..', __dir__), 'db', 'config.yml')
  db_configuration_result = ERB.new(File.read(db_configuration_file_path)).result
  YAML.safe_load(db_configuration_result, aliases: true)
end
ActiveRecord::Base.establish_connection(db_configuration[ENV['ENVIRONMENT']])


require 'sidekiq'

def redis_config
  {
    url: ENV.fetch('SIDEKIQ_REDIS_URL')
  }
end

Sidekiq.configure_server do |config|
  config.redis = redis_config
end

Sidekiq.configure_client do |config|
  config.redis = redis_config
end


require './app/models/ip_address'
require './app/models/observation'
require './app/models/observation_result'

require './app/services/report'
require './app/services/ping'

require './app/jobs/pinger'
