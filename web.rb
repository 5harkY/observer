require 'sinatra'
require './app/application'
require './app/validation_contract'

post '/observations/start' do
  content_type :json

  validation_result = AddressContract.new.call(params)
  check_validation_result(validation_result)

  params = validation_result.to_h
  addr = IpAddress.find_or_create_by(params)
  halt(200, { msg: 'already under observation' }.to_json) if addr.under_observation?

  addr.start_observation
  { msg: 'observation started' }.to_json
end

post '/observations/stop' do
  content_type :json

  validation_result = AddressContract.new.call(params)
  check_validation_result(validation_result)

  params = validation_result.to_h
  addr = IpAddress.find_by(params)
  halt(200, { msg: 'was not under observation' }.to_json) unless addr&.under_observation?

  addr.stop_observation
  { msg: 'observation_stopped' }.to_json
end


get '/report' do
  content_type :json

  validation_result = ReportContract.new.call(params)
  check_validation_result(validation_result)

  result = Services::Report.new.call(**validation_result.to_h)
  halt(400, { errors: { observations: :not_found} }.to_json) if result.empty?

  result.to_json
end

def check_validation_result(validation_result)
  halt(400, { errors: validation_result.errors.to_h }.to_json) unless validation_result.success?
end

