require 'timescaledb'
class ObservationResult < ActiveRecord::Base
  acts_as_hypertable
  belongs_to :ip_address
end