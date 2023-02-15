class IpAddress < ActiveRecord::Base
  has_many :observations
  has_many :observation_results

  def start_observation
    Observation.transaction do
      return if under_observation?

      observations.create
    end
  end
  def stop_observation
    Observation.transaction do
      return unless under_observation?

      active_observation.update(stopped_at: DateTime.now)
    end
  end
  def under_observation?
    active_observation.present?
  end

  private

  def active_observation
    observations.active.first
  end
end