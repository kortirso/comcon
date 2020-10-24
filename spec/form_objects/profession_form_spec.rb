# frozen_string_literal: true

RSpec.describe ProfessionForm, type: :service do
  describe '.persist?' do
    context 'for invalid data' do
      let(:service) { described_class.new(name: { 'en' => '', 'ru' => '' }) }

      it 'does not create new profession' do
        expect { service.persist? }.not_to change(Profession, :count)
      end

      it 'and returns false' do
        expect(service.persist?).to eq false
      end
    end

    context 'for valid data' do
      let!(:profession) { create :profession }

      context 'for existed profession' do
        let(:service) { described_class.new(name: { 'en' => profession.name['en'], 'ru' => profession.name['ru'] }) }

        it 'does not create new profession' do
          expect { service.persist? }.not_to change(Profession, :count)
        end

        it 'and returns false' do
          expect(service.persist?).to eq false
        end
      end

      context 'for unexisted profession' do
        let(:service) { described_class.new(name: { 'en' => 'Skinning', 'ru' => 'Снятие шкур' }) }

        it 'creates new profession' do
          expect { service.persist? }.to change(Profession, :count).by(1)
        end

        it 'and returns true' do
          expect(service.persist?).to eq true
        end
      end
    end
  end
end
