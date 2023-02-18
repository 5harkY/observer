# frozen_string_literal: true

module Jobs
  class Pinger
    include Sidekiq::Job

    def perform(observation_id)
      observation = Observation.active.find_by_id(observation_id)
      return unless observation

      ip_addr = observation.ip_address
      rtt, success = Services::Ping.new.call(ip_addr.address)
      ip_addr.observation_results.create(rtt:, success:)
    end
  end
end
