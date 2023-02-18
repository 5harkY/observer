# frozen_string_literal: true

ENV['ENVIRONMENT'] ||= 'development'

require 'active_record'
require 'dotenv'
require 'erb'
require 'pg'
require 'yaml'

# By default Dotenv.load for loading environment variables reaches out
# to the `.env` file, so if we want to use other environments it is worth
# extending this to the method below, which will first for a set development
# environment look for a file ending in `.env.development.local`,
# then `.env.development` and finally `.env`.

Dotenv.load(".env.#{ENV.fetch('ENVIRONMENT')}.local", ".env.#{ENV.fetch('ENVIRONMENT')}", '.env')

def db_configuration # rubocop:disable Style/TopLevelMethodDefinition
  db_configuration_file_path = File.join(File.expand_path('..', __dir__), 'db', 'config.yml')
  db_configuration_result = ERB.new(File.read(db_configuration_file_path)).result
  YAML.safe_load(db_configuration_result, aliases: true)
end
ActiveRecord::Base.establish_connection(db_configuration[ENV.fetch('ENVIRONMENT', nil)])

require 'sidekiq'
require 'sidekiq-cron'

def redis_config # rubocop:disable Style/TopLevelMethodDefinition
  {
    url: ENV.fetch('SIDEKIQ_REDIS_URL')
  }
end

Sidekiq.configure_server do |config|
  config.redis = redis_config

  config.on(:startup) do
    schedule_file = 'config/schedule.yml'

    Sidekiq::Cron::Job.load_from_hash YAML.load_file(schedule_file) if File.exist?(schedule_file)
  end
end

Sidekiq.configure_client do |config|
  config.redis = redis_config
end

require './app/models/ip_address'
require './app/models/observation'
require './app/models/observation_result'

require './app/services/ping'
require './app/services/report'

require './app/jobs/pinger'
require './app/jobs/task_manager'
