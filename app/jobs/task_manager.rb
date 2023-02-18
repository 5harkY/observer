# frozen_string_literal: true

module Jobs
  class TaskManager
    include Sidekiq::Job

    def perform
      Observation.active.pluck(:id).each { |obs_id| Jobs::Pinger.perform_async(obs_id) }
    end
  end
end
