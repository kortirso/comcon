# frozen_string_literal: true

RSpec.describe StaticMemberForm, type: :service do
  describe '.persist?' do
    context 'for invalid data' do
      let(:service) { described_class.new(static: nil, character: nil) }

      it 'does not create new static member' do
        expect { service.persist? }.not_to change(StaticMember, :count)
      end

      it 'and returns false' do
        expect(service.persist?).to eq false
      end
    end

    context 'for valid data' do
      let!(:character) { create :character }
      let!(:static) { create :static, :guild, world: character.world, fraction: character.race.fraction }

      context 'for existed static member' do
        let!(:static_member) { create :static_member, static: static, character: character }
        let(:service) { described_class.new(static: static, character: character) }

        it 'does not create new static member' do
          expect { service.persist? }.not_to change(StaticMember, :count)
        end

        it 'and returns false' do
          expect(service.persist?).to eq false
        end
      end

      context 'for different worlds' do
        let!(:other_world_static) { create :static, :guild, fraction: character.race.fraction }
        let(:service) { described_class.new(static: other_world_static, character: character) }

        it 'does not create new static member' do
          expect { service.persist? }.not_to change(StaticMember, :count)
        end

        it 'and returns false' do
          expect(service.persist?).to eq false
        end
      end

      context 'for different fractions' do
        let!(:other_fraction_static) { create :static, :guild, world: character.world }
        let(:service) { described_class.new(static: other_fraction_static, character: character) }

        it 'does not create new static member' do
          expect { service.persist? }.not_to change(StaticMember, :count)
        end

        it 'and returns false' do
          expect(service.persist?).to eq false
        end
      end

      context 'for unexisted character' do
        let(:service) { described_class.new(static: static, character: character) }

        it 'creates new static member' do
          expect { service.persist? }.to change(StaticMember, :count).by(1)
        end

        it 'and returns true' do
          expect(service.persist?).to eq true
        end
      end
    end
  end
end
