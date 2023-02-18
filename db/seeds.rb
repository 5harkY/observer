require 'bundler/setup'

$LOAD_PATH.unshift File.expand_path('..', __dir__)
require 'config/environment'

addresses = %w[192.168.10.254 8.8.8.8 1.1.1.1 192.168.0.1 5.5.5.5]
step_5sec = (1.to_f/24/60/12)

addresses.each do |addr_str|
  addr = IpAddress.find_or_create_by(address: addr_str)
  start_date = DateTime.now.beginning_of_year

  3.times do
    start_date += 2.hour
    obs = addr.observations.create(created_at: start_date, stopped_at: start_date + 1.hour)
    rtt_base = rand(1..9) / 10
    obs.created_at.to_datetime.step(obs.stopped_at.to_datetime, step_5sec).each do |time|
      addr.observation_results.create(created_at: time, rtt: rtt_base + rand(0..0.1), success: rand < 0.95)
    end
  end

end