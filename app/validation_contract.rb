require 'dry-validation'

class AddressContract < Dry::Validation::Contract

  params do
    required(:address).filled(:string)
  end

  rule(:address) do
    addr = IPAddr.new(value)
    addr.ipv4? || addr.ipv6?
  rescue IPAddr::InvalidAddressError, IPAddr::AddressFamilyError
    key.failure('must be an ip address')
  end

end

class ReportContract < AddressContract
  params do
    required(:start_time).filled(:time)
    required(:end_time).filled(:time)
  end

  rule(:end_time, :start_time) do
    key.failure('must be after start time') if values[:end_time] < values[:start_time]
  end

  rule(:start_time) do
    key.failure('must be in the past') if value > DateTime.now
  end
end