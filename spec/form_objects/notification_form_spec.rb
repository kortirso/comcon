# frozen_string_literal: true

RSpec.describe NotificationForm, type: :service do
  describe '.persist?' do
    context 'for invalid data' do
      let(:service) { described_class.new(name: { 'en' => '', 'ru' => '' }, event: 'guild_event_creation') }

      it 'does not create new notification' do
        expect { service.persist? }.not_to change(Notification, :count)
      end

      it 'and returns false' do
        expect(service.persist?).to eq false
      end
    end

    context 'for valid data' do
      context 'for existed notification' do
        let!(:notification) { create :notification }
        let(:service) { described_class.new(name: { 'en' => notification.name['en'], 'ru' => notification.name['ru'] }, event: 'guild_event_creation') }

        it 'does not create new notification' do
          expect { service.persist? }.not_to change(Notification, :count)
        end

        it 'and returns false' do
          expect(service.persist?).to eq false
        end
      end

      context 'for unexisted notification' do
        let(:service) { described_class.new(name: { 'en' => 'Guild event creation', 'ru' => 'Создание гильдейского события' }, event: 'guild_event_creation', status: 0) }

        it 'creates new notification' do
          expect { service.persist? }.to change(Notification, :count).by(1)
        end

        it 'and returns true' do
          expect(service.persist?).to eq true
        end
      end
    end
  end
end
