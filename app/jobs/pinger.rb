# frozen_string_literal: true

require 'parallel'

module Jobs
  class Pinger
    include Sidekiq::Job

    def perform(target)
      target.is_a?(Array) ? ping_batch(target) : ping_single(target)
    end

    private

    def ping_single(observation_id)
      observation = Observation.active.find_by_id(observation_id)
      return unless observation

      ip_addr = observation.ip_address
      rtt, success = Services::Ping.new.call(ip_addr.address)
      ip_addr.observation_results.create(rtt:, success:)
    end

    def ping_batch(observation_ids)
      return if observation_ids.empty?

      addresses = Observation.active.where(id: observation_ids).includes(:ip_address).map(&:ip_address)
      return if addresses.empty?

      observation_results_data = Parallel.map(addresses, in_threads: addresses.count) do |addr|
        rtt, success = Services::Ping.new.call(addr.address)
        { ip_address_id: addr.id, rtt:, success: }
      end

      ObservationResult.insert_all(observation_results_data)
    end
  end
end
