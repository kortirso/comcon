# frozen_string_literal: true

RSpec.describe CharacterProfessionForm, type: :service do
  describe '.persist?' do
    context 'for invalid data' do
      let(:service) { described_class.new(character: nil) }

      it 'does not create new character profession' do
        expect { service.persist? }.not_to change(CharacterProfession, :count)
      end

      it 'and returns false' do
        expect(service.persist?).to eq false
      end
    end

    context 'for valid data' do
      let!(:character) { create :character }
      let!(:profession1) { create :profession }
      let!(:profession2) { create :profession }
      let!(:profession3) { create :profession, main: false }
      let!(:profession4) { create :profession }

      context 'for existed character profession' do
        let!(:character_profession) { create :character_profession, character: character, profession: profession1 }
        let(:service) { described_class.new(character: character, profession: profession1) }

        it 'does not create new character profession' do
          expect { service.persist? }.not_to change(CharacterProfession, :count)
        end

        it 'and returns false' do
          expect(service.persist?).to eq false
        end
      end

      context 'for 2 existed character profession' do
        let!(:character_profession1) { create :character_profession, character: character, profession: profession1 }
        let!(:character_profession2) { create :character_profession, character: character, profession: profession2 }

        context 'for new main profession' do
          let(:service) { described_class.new(character: character, profession: profession4) }

          it 'does not create new character profession' do
            expect { service.persist? }.not_to change(CharacterProfession, :count)
          end

          it 'and returns false' do
            expect(service.persist?).to eq false
          end
        end

        context 'for new not main profession' do
          let(:service) { described_class.new(character: character, profession: profession3) }

          it 'creates new character profession' do
            expect { service.persist? }.to change(CharacterProfession, :count).by(1)
          end

          it 'and returns true' do
            expect(service.persist?).to eq true
          end
        end
      end

      context 'for valid data' do
        let(:service) { described_class.new(character: character, profession: profession1) }

        it 'creates new character profession' do
          expect { service.persist? }.to change(CharacterProfession, :count).by(1)
        end

        it 'and returns true' do
          expect(service.persist?).to eq true
        end
      end
    end
  end
end
