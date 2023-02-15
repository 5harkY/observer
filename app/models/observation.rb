class Observation < ActiveRecord::Base
  belongs_to :ip_address
  scope :active, -> { where(stopped_at: nil) }
end