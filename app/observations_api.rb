# frozen_string_literal: true

require 'sinatra'
require './config/environment'
require './app/validation_contract'

class ObservationsApi < Sinatra::Base

  post '/observations/start' do
    content_type :json

    validation_result = AddressContract.new.call(params)
    check_validation_result(validation_result)

    params = validation_result.to_h.slice(:address)
    addr = IpAddress.find_or_create_by(params)
    halt(200, { msg: 'already under observation' }.to_json) if addr.under_observation?

    addr.start_observation
    { msg: 'observation started' }.to_json
  end

  post '/observations/stop' do
    content_type :json

    validation_result = AddressContract.new.call(params)
    check_validation_result(validation_result)

    params = validation_result.to_h.slice(:address)
    addr = IpAddress.find_by(params)
    halt(200, { msg: 'was not under observation' }.to_json) unless addr&.under_observation?

    addr.stop_observation
    { msg: 'observation_stopped' }.to_json
  end

  get '/report' do
    content_type :json

    validation_result = ReportContract.new.call(params)
    check_validation_result(validation_result)

    params = validation_result.to_h.slice(:address, :start_time, :end_time)
    result = Services::Report.new.call(**params)
    halt(400, { errors: { observations: :not_found} }.to_json) if result.empty?

    result.to_json
  end

  private
  def check_validation_result(validation_result)
    halt(400, { errors: validation_result.errors.to_h }.to_json) unless validation_result.success?
  end

end

