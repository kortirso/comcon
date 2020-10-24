# frozen_string_literal: true

RSpec.describe CombinationForm, type: :service do
  describe '.persist?' do
    context 'for invalid data' do
      let(:service) { described_class.new }

      it 'does not create new combination' do
        expect { service.persist? }.not_to change(Combination, :count)
      end

      it 'and returns false' do
        expect(service.persist?).to eq false
      end
    end

    context 'for valid data' do
      let!(:character_class) { create :character_class }
      let!(:race) { create :race, :human }
      let(:service) { described_class.new(character_class: character_class, combinateable_id: race.id, combinateable_type: 'Race') }

      it 'creates new combination' do
        expect { service.persist? }.to change(Combination, :count).by(1)
      end

      it 'and returns true' do
        expect(service.persist?).to eq true
      end
    end

    context 'for updating' do
      let!(:combination) { create :combination }

      context 'for unexisted combination' do
        let(:service) { described_class.new(id: 999) }

        it 'returns false' do
          expect(service.persist?).to eq false
        end
      end

      context 'for existed combination' do
        context 'for invalid data' do
          let(:service) { described_class.new(combination.attributes.merge(combinateable_type: 'World')) }

          it 'does not update combination' do
            service.persist?
            combination.reload

            expect(combination.combinateable_type).not_to eq 'World'
          end
        end

        context 'for valid data' do
          let!(:race) { create :race, :human }
          let(:service) { described_class.new(combination.attributes.merge(character_class: combination.character_class, combinateable_id: race.id, combinateable_type: 'Race')) }

          it 'updates combination' do
            service.persist?
            combination.reload

            expect(combination.combinateable).to eq race
          end
        end
      end
    end
  end
end
