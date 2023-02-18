RSpec.describe Services::Report, '#call' do
  subject(:service) { described_class.new }
  let(:result) { service.call(**params) }

  context 'no data in given dates range' do
    let(:params) { { address: '8.8.8.8', start_time: Time.now, end_time: Time.now } }

    it 'returns empty hash' do
      expect(result).to be_empty
    end
  end

  context 'only failed attempts' do
    let(:address) { '8.8.8.8' }
    let(:params) { { address:, start_time: Time.now.beginning_of_day, end_time: Time.now.end_of_day } }

    before do
      addr = IpAddress.create(address:)
      addr.observation_results.create(created_at: Time.now, success: false)
    end

    it 'returns hash with all zeros' do
      %i[avg_rtt min_rtt max_rtt median_rtt std_deviation].each do |key|
        expect(result[key].to_i).to be_zero
      end
      expect(result[:lost_percentage]).to eq 100.0
    end
  end

  context 'with few success attempts' do
    let(:start_time) { Time.now.beginning_of_day }
    let(:end_time) { Time.now.end_of_day }
    let(:address) { '8.8.8.8' }
    let(:params) { { address:, start_time:, end_time: } }

    before do
      addr = IpAddress.create(address:)
      rtt = 0.0
      created_at = start_time
      10.times do
        rtt += 10
        created_at += 1.minute
        addr.observation_results.create(created_at:, rtt:, success: rtt <= 50)
      end
    end

    it 'calculates correct values' do
      expect(result[:avg_rtt]).to eq 30
      expect(result[:min_rtt]).to eq 10
      expect(result[:max_rtt]).to eq 50
      expect(result[:median_rtt]).to eq 30
      expect(result[:lost_percentage]).to eq 50
      expect((result[:std_deviation] - 15.81138).abs).to be < 0.00001
    end

  end

  context 'with all success' do
    let(:start_time) { Time.now.beginning_of_day }
    let(:end_time) { Time.now.end_of_day }
    let(:address) { '8.8.8.8' }
    let(:params) { { address:, start_time:, end_time: } }

    before do
      addr = IpAddress.create(address:)
      rtt = 0.0
      created_at = start_time
      10.times do
        rtt += 10
        created_at += 1.minute
        addr.observation_results.create(created_at:, rtt:, success: true)
      end
    end

    it 'calculates correct values' do
      expect(result[:avg_rtt]).to eq 55
      expect(result[:min_rtt]).to eq 10
      expect(result[:max_rtt]).to eq 100
      expect(result[:median_rtt]).to eq 55
      expect(result[:lost_percentage]).to eq 0
      expect((result[:std_deviation] - 30.27650).abs).to be < 0.00001
    end

  end
end