# frozen_string_literal: true

RSpec.describe Recipe, type: :model do
  it { is_expected.to belong_to :profession }
  it { is_expected.to have_many(:character_recipes).dependent(:destroy) }

  it 'factory is_expected.to be valid' do
    recipe = build :recipe

    expect(recipe).to be_valid
  end

  describe 'methods' do
    describe '.name_en' do
      let!(:recipe) { create :recipe }

      it 'return en name' do
        expect(recipe.name_en).to eq recipe.name['en']
      end
    end

    describe '.name_ru' do
      let!(:recipe) { create :recipe }

      it 'return ru name' do
        expect(recipe.name_ru).to eq recipe.name['ru']
      end
    end
  end
end
