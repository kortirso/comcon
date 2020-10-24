# frozen_string_literal: true

RSpec.describe SubscribeForm, type: :service do
  describe '.persist?' do
    context 'for invalid data' do
      let(:service) { described_class.new(name: '') }

      it 'does not create new subscribe' do
        expect { service.persist? }.not_to change(Subscribe, :count)
      end

      it 'and returns false' do
        expect(service.persist?).to eq false
      end
    end

    describe '.for_role_string_to_integer' do
      it 'for Dd role returns 2' do
        service = described_class.new(for_role: 'Dd')

        expect(service.send(:for_role_string_to_integer)).to eq 2
      end

      it 'for Healer role returns 1' do
        service = described_class.new(for_role: 'Healer')

        expect(service.send(:for_role_string_to_integer)).to eq 1
      end

      it 'for Tank role returns 0' do
        service = described_class.new(for_role: 'Tank')

        expect(service.send(:for_role_string_to_integer)).to eq 0
      end

      it 'for invalid value returns 2' do
        service = described_class.new(for_role: 'invalid')

        expect(service.send(:for_role_string_to_integer)).to eq 2
      end
    end

    describe '.for_role_nil_to_integer' do
      let!(:race) { create :race, :night_elf }
      let!(:character_class) { create :character_class, :druid }
      let!(:character) { create :character, race: race, character_class: character_class }

      context 'for Melee role' do
        let!(:role) { create :role, :melee }
        let!(:character_role) { create :character_role, character: character, role: role }

        it 'returns 2' do
          service = described_class.new(character: character)

          expect(service.send(:for_role_nil_to_integer)).to eq 2
        end
      end

      context 'for Ranged role' do
        let!(:role) { create :role, :ranged }
        let!(:character_role) { create :character_role, character: character, role: role }

        it 'returns 2' do
          service = described_class.new(character: character)

          expect(service.send(:for_role_nil_to_integer)).to eq 2
        end
      end

      context 'for Healer role' do
        let!(:role) { create :role, :healer }
        let!(:character_role) { create :character_role, character: character, role: role }

        it 'returns 1' do
          service = described_class.new(character: character)

          expect(service.send(:for_role_nil_to_integer)).to eq 1
        end
      end

      context 'for Tank role' do
        let!(:role) { create :role, :tank }
        let!(:character_role) { create :character_role, character: character, role: role }

        it 'returns 0' do
          service = described_class.new(character: character)

          expect(service.send(:for_role_nil_to_integer)).to eq 0
        end
      end
    end

    context 'for existed subscribe' do
      let!(:event) { create :event }
      let!(:character) { create :character }
      let!(:subscribe) { create :subscribe, subscribeable: event, character: character }
      let(:service) { described_class.new(subscribeable_id: event.id, subscribeable_type: 'Event', character: character, for_role: 'Healer') }

      it 'does not create new subscribe' do
        expect { service.persist? }.not_to change(Subscribe, :count)
      end

      it 'and returns false' do
        expect(service.persist?).to eq false
      end
    end

    context 'for valid data' do
      let!(:event) { create :event }
      let!(:character) { create :character }
      let(:service) { described_class.new(subscribeable_id: event.id, subscribeable_type: 'Event', character: character, for_role: 'Healer') }

      it 'creates new subscribe' do
        expect { service.persist? }.to change(Subscribe, :count).by(1)
      end

      it 'and subscribe is created with for_role 1' do
        service.persist?

        expect(Subscribe.last.for_role).to eq 'Healer'
      end

      it 'and returns true' do
        expect(service.persist?).to eq true
      end
    end

    context 'for updating' do
      let!(:subscribe) { create :subscribe }

      context 'for unexisted subscribe' do
        let(:service) { described_class.new(id: 999, approved: true) }

        it 'returns false' do
          expect(service.persist?).to eq false
        end
      end

      context 'for valid data' do
        let(:service) { described_class.new(subscribe.attributes.merge(subscribeable_id: subscribe.subscribeable_id, subscribeable_type: 'Event', character: subscribe.character, status: 'approved')) }

        it 'updates subscribe' do
          service.persist?
          subscribe.reload

          expect(subscribe.status).to eq 'approved'
        end
      end
    end
  end
end
