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

  describe "POST /observations/start" do
    context 'with wrong params:' do
      context 'empty' do
        let(:params) { {} }
        it "returns validation error" do
          post "/observations/start", params
          expect(status).to eq 400
          expect(body[:errors]).to include({address: ['is missing']})
        end
      end

      context 'empty address' do
        let(:params) { { address: nil } }
        it "returns validation error" do
          post "/observations/start", params
          expect(status).to eq 400
          expect(body[:errors]).to include({address: ['must be filled']})
        end
      end

      context 'wrong address' do
        let(:params) { { address: 'whatever' } }
        it "returns validation error" do
          post "/observations/start", params
          expect(status).to eq 400
          expect(body[:errors]).to include({address: ['must be a valid ip address']})
        end
      end

    end
  end

  context 'with valid params' do
    let(:params) { { address: '8.8.8.8'} }
    it 'starts observation' do
      expect(IpAddress.count).to eq 0
      expect(Observation.count).to eq 0
      post "/observations/start", params
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
        post "/observations/start", params
        expect(status).to eq 200
        expect(body[:msg]).to eq 'already under observation'
        expect(IpAddress.count).to eq 1
        expect(Observation.active.count).to eq 1
      end
    end

    context 'with extra params' do
      let(:params) { { address: '8.8.8.8', created_at: Time.now.end_of_month} }

      it 'ignores them' do
        expect(IpAddress.count).to eq 0
        post "/observations/start", params
        expect(status).to eq 200
        expect(IpAddress.count).to eq 1
        expect(IpAddress.first.created_at).to be_today
      end
    end

  end

end
