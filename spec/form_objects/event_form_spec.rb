# frozen_string_literal: true

RSpec.describe EventForm, type: :service do
  describe '.persist?' do
    context 'for invalid data' do
      let(:service) { described_class.new(name: '') }

      it 'does not create new event' do
        expect { service.persist? }.not_to change(Event, :count)
      end

      it 'and returns false' do
        expect(service.persist?).to eq false
      end
    end

    context 'for invalid time' do
      let!(:guild) { create :guild }
      let!(:character) { create :character, guild: guild }
      let(:service) { described_class.new(name: 'Хроми', owner: character, event_type: 'raid', start_time: DateTime.now + 1.hour, eventable_type: 'Guild', eventable_id: guild.id, hours_before_close: 2) }

      it 'does not create new event' do
        expect { service.persist? }.not_to change(Event, :count)
      end

      it 'and returns false' do
        expect(service.persist?).to eq false
      end
    end

    context 'for valid data' do
      let!(:guild) { create :guild }
      let!(:character) { create :character, guild: guild }
      let(:service) { described_class.new(name: 'Хроми', owner: character, event_type: 'raid', start_time: DateTime.now + 1.day, eventable_type: 'Guild', eventable_id: guild.id) }

      it 'creates new event' do
        expect { service.persist? }.to change(Event, :count).by(1)
      end

      it 'and returns true' do
        expect(service.persist?).to eq true
      end
    end

    context 'for updating' do
      let!(:guild) { create :guild }
      let!(:character) { create :character, guild: guild }
      let!(:event) { create :event, eventable: guild, owner: character }

      context 'for unexisted event' do
        let(:service) { described_class.new(id: 999, name: '1', owner: event.owner) }

        it 'returns false' do
          expect(service.persist?).to eq false
        end
      end

      context 'for existed event' do
        context 'for invalid data' do
          let(:service) { described_class.new(event.attributes.merge(name: '', owner: event.owner, dungeon: event.dungeon)) }

          it 'does not update event' do
            service.persist?
            event.reload

            expect(event.name).not_to eq ''
          end
        end

        context 'for valid data' do
          let(:service) { described_class.new(event.attributes.merge(name: 'Хроми', owner: event.owner, dungeon: event.dungeon)) }

          it 'updates event' do
            service.persist?
            event.reload

            expect(event.name).to eq 'Хроми'
          end
        end
      end
    end
  end
end
