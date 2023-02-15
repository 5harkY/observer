require 'dry-validation'

class AddressContract < Dry::Validation::Contract

  params do
    required(:address).filled(:string)
  end

  rule(:address) do
    addr = IPAddr.new(value)
    addr.ipv4? || addr.ipv6?
  rescue IPAddr::InvalidAddressError, IPAddr::AddressFamilyError
    key.failure('must be a valid ip address')
  end

end

class ReportContract < AddressContract
  params do
    required(:start_time).filled(:time)
    required(:end_time).filled(:time)
  end
end