# frozen_string_literal: true

module Jobs
  class TaskManager
    include Sidekiq::Job

    def perform
      Observation.active.in_batches(of: 100) do |relation|
        Jobs::Pinger.perform_async(relation.pluck(:id))
      end
    end
  end
end
