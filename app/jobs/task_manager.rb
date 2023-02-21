# frozen_string_literal: true

module Jobs
  class TaskManager
    include Sidekiq::Job

    def perform
      Observation.active.in_batches(of: 50) do |relation|
        Jobs::Pinger.perform_in(1.second, relation.pluck(:id))
      end
    end
  end
end
