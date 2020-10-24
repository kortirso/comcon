# frozen_string_literal: true

RSpec.describe CharacterRecipesUpload, type: :service do
  describe '.call' do
    let!(:character) { create :character }
    let!(:profession) { create :profession, name: { 'en' => 'Alchemy', 'ru' => 'Алхимия' }, main: true, recipeable: true }
    let!(:recipe) { create :recipe, profession: profession, name: { 'en' => '123', 'ru' => 'Хорошее зелье маны' } }

    context 'for invalid value' do
      let(:request) { described_class.call(character_id: character.id, profession_id: profession.id, value: '') }

      it 'does not create character recipes' do
        expect { request }.not_to change(CharacterRecipe, :count)
      end

      it 'and returns nil' do
        expect(request).to eq nil
      end
    end

    context 'for empty value' do
      let(:request) { described_class.call(character_id: character.id, profession_id: profession.id, value: 'en') }

      it 'does not create character recipes' do
        expect { request }.not_to change(CharacterRecipe, :count)
      end

      it 'and returns nil' do
        expect(request).to eq nil
      end
    end

    context 'for unexisted character profession' do
      let(:request) { described_class.call(character_id: character.id, profession_id: profession.id, value: 'ruRU;Хорошее зелье маны') }

      it 'does not create character recipes' do
        expect { request }.not_to change(CharacterRecipe, :count)
      end

      it 'and returns nil' do
        expect(request).to eq nil
      end
    end

    context 'for existed character profession' do
      let!(:character_profession) { create :character_profession, character: character, profession: profession }

      context 'for existed character recipe' do
        let!(:character_recipe) { create :character_recipe, recipe: recipe, character_profession: character_profession }
        let(:request) { described_class.call(character_id: character.id, profession_id: profession.id, value: 'ruRU;Хорошее зелье маны') }

        it 'does not create character recipes' do
          expect { request }.not_to change(CharacterRecipe, :count)
        end

        it 'and returns not nil' do
          expect(request).not_to eq nil
        end
      end

      context 'for unexisted character recipe' do
        let(:request) { described_class.call(character_id: character.id, profession_id: profession.id, value: 'ruRU;Хорошее зелье маны') }

        it 'creates character recipes' do
          expect { request }.to change(CharacterRecipe, :count).by(1)
        end

        it 'and returns not nil' do
          expect(request).not_to eq nil
        end
      end
    end
  end
end
