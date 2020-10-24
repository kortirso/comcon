# frozen_string_literal: true

RSpec.describe GameItemQualityForm, type: :service do
  describe '.persist?' do
    context 'for invalid data' do
      let(:service) { described_class.new(uid: '', name: { 'en' => '', 'ru' => '' }) }

      it 'does not create new object' do
        expect { service.persist? }.not_to change(GameItemQuality, :count)
      end

      it 'and returns false' do
        expect(service.persist?).to eq false
      end
    end

    context 'for valid data' do
      let(:service) { described_class.new(uid: 1, name: { 'en' => 'Common', 'ru' => 'Обычный' }) }

      it 'creates new object' do
        expect { service.persist? }.to change(GameItemQuality, :count).by(1)
      end

      it 'and returns true' do
        expect(service.persist?).to eq true
      end
    end
  end
end
