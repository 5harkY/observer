# frozen_string_literal: true

RSpec.describe Services::Ping, '#call' do
  subject(:service) { described_class.new }
  let(:result) { service.call(address) }
  let(:rtt) { result[0] }
  let(:success) { result[1] }
  let(:address) { |ex| ex.metadata[:address] }
  let(:zero_response) { [0, false] }

  context 'invalid address' do
    it 'returns zero rtt', address: 'whatever' do
      expect(result).to eq zero_response
    end
    it 'returns zero rtt', address: '1.1.1.1.1' do
      expect(result).to eq zero_response
    end
    it 'returns zero rtt', address: '255.255.255.255' do
      expect(result).to eq zero_response
    end
  end

  context 'destination unreachable' do
    let(:timeout) { 1 }
    let(:result) { service.call(address, timeout) }
    it 'returns zero rtt within timeout', address: '254.254.254.254' do
      start_time = Time.now
      expect(result).to eq zero_response
      execution_time = Time.now - start_time
      expect(execution_time - timeout.seconds).to be < 0.1
    end
  end

  context 'valid address' do
    it 'returns non zero rtt', address: '0.0.0.0' do
      expect(success).to be_truthy
      expect(rtt).to be > 0
    end
  end
end
