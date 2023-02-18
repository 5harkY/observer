# frozen_string_literal: true

RSpec.describe ObservationsApi do
  def app
    ObservationsApi
  end

  def body
    JSON.parse(last_response.body).with_indifferent_access
  end

  def status
    last_response.status
  end

  describe 'POST /observations/start' do
    let(:make_request) { post '/observations/start', params }
    context 'with wrong params:' do
      context 'empty' do
        let(:params) { {} }
        it 'returns validation error' do
          make_request
          expect(status).to eq 400
          expect(body[:errors]).to include({ address: ['is missing'] })
        end
      end

      context 'empty address' do
        let(:params) { { address: nil } }
        it 'returns validation error' do
          make_request
          expect(status).to eq 400
          expect(body[:errors]).to include({ address: ['must be filled'] })
        end
      end

      context 'wrong address' do
        let(:params) { { address: 'whatever' } }
        it 'returns validation error' do
          make_request
          expect(status).to eq 400
          expect(body[:errors]).to include({ address: ['must be an ip address'] })
        end
      end
    end

    context 'with valid params' do
      let(:params) { { address: '8.8.8.8' } }
      it 'starts observation' do
        expect(IpAddress.count).to eq 0
        expect(Observation.count).to eq 0
        make_request
        expect(status).to eq 200
        expect(body[:msg]).to eq 'observation started'
        expect(IpAddress.count).to eq 1
        expect(Observation.active.count).to eq 1
      end

      context 'when observation already exist' do
        before do
          IpAddress.create(params).start_observation
        end

        it 'does not start new one' do
          expect(IpAddress.count).to eq 1
          expect(Observation.count).to eq 1
          make_request
          expect(status).to eq 200
          expect(body[:msg]).to eq 'already under observation'
          expect(IpAddress.count).to eq 1
          expect(Observation.active.count).to eq 1
        end
      end

      context 'with extra params' do
        let(:params) { { address: '8.8.8.8', created_at: Time.now.end_of_month } }

        it 'ignores them' do
          expect(IpAddress.count).to eq 0
          make_request
          expect(status).to eq 200
          expect(IpAddress.count).to eq 1
          expect(IpAddress.first.created_at).to be_today
        end
      end
    end
  end

  describe 'POST /observations/stop' do
    let(:make_request) { post '/observations/stop', params }
    context 'with wrong params:' do
      context 'empty' do
        let(:params) { {} }
        it 'returns validation error' do
          make_request
          expect(status).to eq 400
          expect(body[:errors]).to include({ address: ['is missing'] })
        end
      end

      context 'empty address' do
        let(:params) { { address: nil } }
        it 'returns validation error' do
          make_request
          expect(status).to eq 400
          expect(body[:errors]).to include({ address: ['must be filled'] })
        end
      end

      context 'wrong address' do
        let(:params) { { address: 'whatever' } }
        it 'returns validation error' do
          make_request
          expect(status).to eq 400
          expect(body[:errors]).to include({ address: ['must be an ip address'] })
        end
      end
    end

    context 'with valid params' do
      let(:params) { { address: '8.8.8.8' } }

      it 'returns 200 if no observation' do
        make_request
        expect(status).to eq 200
        expect(body[:msg]).to eq 'was not under observation'
        expect(IpAddress.count).to eq 0
        expect(Observation.active.count).to eq 0
      end

      context 'with extra params' do
        let(:params) { { address: '8.8.8.8', created_at: Time.now.end_of_month } }

        it 'ignores them' do
          expect(IpAddress.count).to eq 0
          make_request
          expect(status).to eq 200
          expect(body[:msg]).to eq 'was not under observation'
          expect(IpAddress.count).to eq 0
        end
      end

      context 'when observation was started' do
        let(:address) { IpAddress.create(params) }
        before do
          address.start_observation
        end

        it 'it stops' do
          expect(IpAddress.count).to eq 1
          expect(Observation.count).to eq 1
          make_request
          expect(status).to eq 200
          expect(body[:msg]).to eq 'observation stopped'
          expect(IpAddress.count).to eq 1
          expect(Observation.active.count).to eq 0
        end

        context 'when it was already stopped' do
          before do
            address.stop_observation
          end
          it 'returns 200 ' do
            make_request
            expect(status).to eq 200
            expect(body[:msg]).to eq 'was not under observation'
            expect(IpAddress.count).to eq 1
            expect(Observation.active.count).to eq 0
          end
        end
      end
    end
  end

  describe 'GET /report' do
    let(:make_request) { get '/report', params }
    context 'with wrong params:' do
      context 'empty' do
        let(:params) { {} }
        it 'returns validation error' do
          make_request
          expect(status).to eq 400
          expect(body[:errors]).to include({
            address: ['is missing'],
start_time: ['is missing'],
                                             end_time: ['is missing']
          })
        end
      end

      context 'empty values' do
        let(:params) { { address: nil, start_time: nil, end_time: nil } }
        it 'returns validation error' do
          make_request
          expect(status).to eq 400
          expect(body[:errors]).to include({
            address: ['must be filled'],
start_time: ['must be filled'],
                                             end_time: ['must be filled']
          })
        end
      end

      context 'wrong type' do
        let(:params) { { address: 'whatever', start_time: 'whatever', end_time: '30.30.3030' } }
        it 'returns validation error' do
          make_request
          expect(status).to eq 400
          expect(body[:errors]).to include({
            address: ['must be an ip address'],
start_time: ['must be a time'],
                                             end_time: ['must be a time']
          })
        end
      end

      context 'end_time less than start_time' do
        let(:params) { { address: '8.8.8.8', start_time: '12:30', end_time: '12:00' } }

        it 'returns validation error' do
          make_request
          expect(status).to eq 400
          expect(body[:errors]).to include({ end_time: ['must be after start time'] })
        end
      end

      context 'start_time in the future' do
        let(:start_time) { Time.now + 1.hour }
        let(:end_time) { start_time + 1.hour }
        let(:params) { { address: '8.8.8.8', start_time:, end_time: } }

        it 'returns validation error' do
          make_request
          expect(status).to eq 400
          expect(body[:errors]).to include({ start_time: ['must be in the past'] })
        end
      end
    end

    context 'with valid params:' do
      let(:start_time) { Time.now - 1.hour }
      let(:end_time) { start_time + 1.hour }
      let(:address) { '8.8.8.8' }
      let(:params) { { address:, start_time:, end_time: } }

      context 'with no observations made' do
        it 'returns error' do
          make_request
          expect(status).to eq 400
          expect(body[:errors]).to include({ address: ['observations for given time interval was not found'] })
        end
      end

      context 'with some observations made' do
        before do
          addr = IpAddress.create(address:)
          addr.observations.create(created_at: start_time)
          addr.observation_results.create(created_at: start_time + 1.minute, rtt: 100, success: true)
          addr.observation_results.create(created_at: start_time + 2.minute, rtt: 200, success: true)
          addr.observation_results.create(created_at: start_time + 3.minute, rtt: 600, success: true)
          addr.observation_results.create(created_at: start_time + 4.minute, rtt: 0, success: false)
        end

        it 'returns report' do
          make_request
          expect(status).to eq 200
          expect(body[:avg_rtt]).to eq 300
          expect(body[:lost_percentage]).to eq 25
        end
      end
    end
  end
end
