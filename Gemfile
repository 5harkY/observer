# frozen_string_literal: true

source 'https://rubygems.org'

ruby '3.1.2'

gem 'puma'
gem 'sinatra'

gem 'dry-validation'

gem 'activerecord'
gem 'pg'
gem 'standalone_migrations'
gem 'timescaledb'

gem 'dotenv'
gem 'erb'
gem 'rake'
gem 'yaml'

gem 'sidekiq'
gem 'sidekiq-cron'

group :test do
  gem 'database_cleaner-active_record'
  gem 'rack-test'
  gem 'rspec'
end

group :development, :test do
  gem 'byebug'
  gem 'rubocop', require: false
  gem 'rubocop-performance', require: false
end
