RSpec.describe CharacterForm, type: :service do
  describe '.persist?' do
    context 'for invalid data' do
      let(:service) { CharacterForm.new(name: '') }

      it 'does not create new character' do
        expect { service.persist? }.to_not change(Character, :count)
      end

      it 'and returns false' do
        expect(service.persist?).to eq false
      end
    end

    context 'for valid data' do
      let!(:character) { create :character, :human_warrior }
      let!(:guild) { create :guild, fraction: character.race.fraction, world: character.world }

      context 'for existed character' do
        let(:service) { CharacterForm.new(name: character.name, guild: guild, level: 60, user: character.user, race: character.race, character_class: character.character_class) }

        it 'does not create new character' do
          expect { service.persist? }.to_not change(Character, :count)
        end

        it 'and returns false' do
          expect(service.persist?).to eq false
        end
      end

      context 'for invalid race/class' do
        let!(:character_class) { create :character_class, :shaman }
        let(:service) { CharacterForm.new(name: 'Хроми', world: character.world, level: 60, user: character.user, race: character.race, character_class: character_class) }

        it 'does not create new character' do
          expect { service.persist? }.to_not change(Character, :count)
          expect(service.errors.full_messages[0]).to eq 'Character class is not valid for race'
        end

        it 'and returns false' do
          expect(service.persist?).to eq false
        end
      end

      context 'for unexisted character' do
        let!(:combination) { create :combination, combinateable: character.race, character_class: character.character_class }
        let(:service) { CharacterForm.new(name: 'Хроми', world: character.world, level: 60, user: character.user, race: character.race, character_class: character.character_class) }

        it 'creates new character' do
          expect { service.persist? }.to change { Character.count }.by(1)
        end

        it 'and returns true' do
          expect(service.persist?).to eq true
        end
      end
    end

    context 'for updating' do
      let!(:character1) { create :character, :human_warrior }
      let!(:combination) { create :combination, combinateable: character1.race, character_class: character1.character_class }
      let!(:character2) { create :character, world: character1.world, level: 60, user: character1.user, race: character1.race, character_class: character1.character_class }

      context 'for unexisted character' do
        let(:service) { CharacterForm.new(id: 999, name: '123') }

        it 'returns false' do
          expect(service.persist?).to eq false
        end
      end

      context 'for existed character' do
        context 'for invalid data' do
          let(:service) { CharacterForm.new(character1.attributes.merge(world: character1.world, user: character1.user, race: character1.race, character_class: character1.character_class, name: '')) }

          it 'does not update character' do
            service.persist?
            character1.reload

            expect(character1.name).to_not eq ''
          end
        end

        context 'for existed data' do
          let(:service) { CharacterForm.new(character1.attributes.merge(world: character1.world, user: character1.user, race: character1.race, character_class: character1.character_class, name: character2.name)) }

          it 'does not update character' do
            service.persist?
            character1.reload

            expect(character1.name).to_not eq character2.name
          end
        end

        context 'for valid data' do
          let(:service) { CharacterForm.new(character1.attributes.merge(world: character1.world, user: character1.user, race: character1.race, character_class: character1.character_class, name: 'Убивамс')) }

          it 'updates character' do
            service.persist?
            character1.reload

            expect(character1.name).to eq 'Убивамс'
          end
        end
      end
    end
  end
end
