# frozen_string_literal: true

RSpec.describe StaticInviteForm, type: :service do
  describe '.persist?' do
    context 'for invalid data' do
      let(:service) { described_class.new(static: nil, character: nil) }

      it 'does not create new static invite' do
        expect { service.persist? }.not_to change(StaticInvite, :count)
      end

      it 'and returns false' do
        expect(service.persist?).to eq false
      end
    end

    context 'for valid data' do
      let!(:character) { create :character }
      let!(:static) { create :static, :guild, world: character.world, fraction: character.race.fraction }

      context 'for existed static invite' do
        let!(:static_invite) { create :static_invite, static: static, character: character }
        let(:service) { described_class.new(static: static, character: character, from_static: static_invite.from_static) }

        it 'does not create new static invite' do
          expect { service.persist? }.not_to change(StaticInvite, :count)
        end

        it 'and returns false' do
          expect(service.persist?).to eq false
        end
      end

      context 'for different worlds' do
        let!(:other_world_static) { create :static, :guild, fraction: character.race.fraction }
        let(:service) { described_class.new(static: other_world_static, character: character) }

        it 'does not create new static invite' do
          expect { service.persist? }.not_to change(StaticInvite, :count)
        end

        it 'and returns false' do
          expect(service.persist?).to eq false
        end
      end

      context 'for different fractions' do
        let!(:other_fraction_static) { create :static, :guild, world: character.world }
        let(:service) { described_class.new(static: other_fraction_static, character: character) }

        it 'does not create new static invite' do
          expect { service.persist? }.not_to change(StaticInvite, :count)
        end

        it 'and returns false' do
          expect(service.persist?).to eq false
        end
      end

      context 'for unexisted static invite, but invalid status' do
        let(:service) { described_class.new(static: static, character: character, status: 1) }

        it 'does not create new static invite' do
          expect { service.persist? }.not_to change(StaticInvite, :count)
        end

        it 'and returns false' do
          expect(service.persist?).to eq false
        end
      end

      context 'for unexisted static invite' do
        let(:service) { described_class.new(static: static, character: character) }

        it 'creates new static invite' do
          expect { service.persist? }.to change(StaticInvite, :count).by(1)
        end

        it 'and returns true' do
          expect(service.persist?).to eq true
        end
      end
    end

    context 'for updating' do
      let!(:character1) { create :character }
      let!(:character2) { create :character, world: character1.world, race: character1.race }
      let!(:static) { create :static, :guild, world: character1.world, fraction: character1.race.fraction }
      let!(:static_invite1) { create :static_invite, static: static, character: character1 }
      let!(:static_invite2) { create :static_invite, static: static, character: character2 }

      context 'for unexisted static invite' do
        let(:service) { described_class.new(id: 999, status: 1) }

        it 'returns false' do
          expect(service.persist?).to eq false
        end
      end

      context 'for existed static invite' do
        context 'for invalid data' do
          let(:service) { described_class.new(static_invite1.attributes.merge(static: static_invite1.static, character: static_invite1.character, status: -1)) }

          it 'does not update static invite' do
            service.persist?
            static_invite1.reload

            expect(static_invite1.status_send?).to eq true
          end
        end

        context 'for existed data' do
          let(:service) { described_class.new(static_invite1.attributes.merge(static: static_invite2.static, character: static_invite2.character, status: 1)) }

          it 'does not update static invite' do
            service.persist?
            static_invite1.reload

            expect(static_invite1.status_send?).to eq true
          end
        end

        context 'for invalid status' do
          let(:service) { described_class.new(static_invite1.attributes.merge(static: static_invite1.static, character: static_invite1.character, status: 0)) }

          it 'does not update static invite' do
            service.persist?
            static_invite1.reload

            expect(static_invite1.status_send?).to eq true
          end
        end

        context 'for valid data' do
          let(:service) { described_class.new(static_invite1.attributes.merge(static: static_invite1.static, character: static_invite1.character, status: 1)) }

          it 'updates static invite' do
            service.persist?
            static_invite1.reload

            expect(static_invite1.status_declined?).to eq true
          end
        end
      end
    end
  end
end
