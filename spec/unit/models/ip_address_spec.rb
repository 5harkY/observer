# frozen_string_literal: true

RSpec.describe IpAddress do
  let(:ip_addr) { described_class.create(**params) }
  let(:params) { { address: '8.8.8.8' } }

  describe '#under_observation?' do
    it 'returns false if no observations at all' do
      expect(ip_addr.under_observation?).to be_falsey
    end

    it 'returns false if there are only stopped observations' do
      ip_addr.observations.create(stopped_at: Time.now)
      expect(ip_addr.under_observation?).to be_falsey
    end

    it 'returns true if there is active observation' do
      ip_addr.observations.create
      expect(ip_addr.under_observation?).to be_truthy
    end
  end

  describe '#start_observation' do
    it 'creates observation if were not active one' do
      expect { ip_addr.start_observation }.to change { ip_addr.under_observation? }.from(false).to(true)
    end
    it 'does not create observation if already was active one' do
      ip_addr.start_observation
      expect { ip_addr.start_observation }.not_to change { ip_addr.under_observation? }
    end
  end

  describe '#stop_observation' do
    it 'stops observation if it exists' do
      ip_addr.start_observation
      expect { ip_addr.stop_observation }.to change { ip_addr.under_observation? }.from(true).to(false)
    end
    it 'does nothing if there are no active observations' do
      expect { ip_addr.stop_observation }.not_to change { ip_addr.under_observation? }
    end
  end
end
