# frozen_string_literal: true

describe UpdateCharacterRecipes do
  let!(:character_profession) { create :character_profession }
  let!(:recipe) { create :recipe }
  let!(:character_recipe) { create :character_recipe, character_profession: character_profession }

  describe '.call' do
    context 'for unexisted character profession' do
      let(:interactor) { described_class.call(character_id: character_profession.character.id, recipe_params: { 999.to_s => { recipe.id.to_s => '1', character_recipe.recipe.id.to_s => '1' } }) }

      it 'succeeds' do
        expect(interactor).to be_a_success
      end

      it 'and creates new character recipe' do
        expect { interactor }.not_to change(character_profession.character_recipes, :count)
      end
    end

    context 'for adding recipe' do
      let(:interactor) { described_class.call(character_id: character_profession.character.id, recipe_params: { character_profession.id.to_s => { recipe.id.to_s => '1', character_recipe.recipe.id.to_s => '1' } }) }

      it 'succeeds' do
        expect(interactor).to be_a_success
      end

      it 'and creates new character recipe' do
        expect { interactor }.to change { character_profession.character_recipes.count }.by(1)
      end
    end

    context 'for removing recipe' do
      let(:interactor) { described_class.call(character_id: character_profession.character.id, recipe_params: { character_profession.id.to_s => {} }) }

      it 'succeeds' do
        expect(interactor).to be_a_success
      end

      it 'and destroyes existed character recipe' do
        expect { interactor }.to change { character_profession.character_recipes.count }.by(-1)
      end
    end
  end
end
