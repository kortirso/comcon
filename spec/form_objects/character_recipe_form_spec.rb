# frozen_string_literal: true

RSpec.describe CharacterRecipeForm, type: :service do
  describe '.persist?' do
    context 'for invalid data' do
      let(:service) { described_class.new(recipe: nil, character_profession: nil) }

      it 'does not create new character recipe' do
        expect { service.persist? }.not_to change(CharacterRecipe, :count)
      end

      it 'and returns false' do
        expect(service.persist?).to eq false
      end
    end

    context 'for valid data' do
      let!(:recipe) { create :recipe }
      let!(:character_profession) { create :character_profession }

      context 'for existed character recipe' do
        let!(:character_recipe) { create :character_recipe, recipe: recipe, character_profession: character_profession }
        let(:service) { described_class.new(recipe: recipe, character_profession: character_profession) }

        it 'does not create new character recipe' do
          expect { service.persist? }.not_to change(CharacterRecipe, :count)
        end

        it 'and returns false' do
          expect(service.persist?).to eq false
        end
      end

      context 'for unexisted character' do
        let(:service) { described_class.new(recipe: recipe, character_profession: character_profession) }

        it 'creates new character recipe' do
          expect { service.persist? }.to change(CharacterRecipe, :count).by(1)
        end

        it 'and returns true' do
          expect(service.persist?).to eq true
        end
      end
    end
  end
end
