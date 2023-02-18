# frozen_string_literal: true

require 'bundler/setup'

$LOAD_PATH.unshift File.expand_path('..', __dir__)
require 'config/environment'

addresses = %w[192.168.10.254 8.8.8.8 1.1.1.1 192.168.0.1 5.5.5.5]
step_1min = (1.to_f / 24 / 60)

ActiveRecord::Base.logger = nil

Benchmark.realtime do
  addresses.each do |addr_str|
    addr = IpAddress.find_or_create_by(address: addr_str)
    start_date = Time.now.beginning_of_year

    10.times do
      start_date += 1.day
      obs = addr.observations.create(created_at: start_date, stopped_at: start_date + 1.day)
      rtt_base = rand(1..9) / 10
      observation_results_data = obs.created_at.to_time.step(obs.stopped_at.to_time, step_1min).map do |time|
        { created_at: time, rtt: rtt_base + rand(0..0.1), success: rand < 0.95 }
      end

      # puts "insert #{observation_results_data.count} entries"
      addr.observation_results.insert_all(observation_results_data)
    end
  end
end
