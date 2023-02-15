class IpAddress < ActiveRecord::Base
  has_many :observations
  has_many :observation_results

  def start_observation
    observations.create
  end
  def stop_observation
    observations.active.first.update(stopped_at: DateTime.now)
  end
  def under_observation?
    observations.active.present?
  end
end