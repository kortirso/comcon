RSpec.describe Recipe, type: :model do
  it { should belong_to :profession }
  it { should have_many(:character_recipes).dependent(:destroy) }

  it 'factory should be valid' do
    recipe = build :recipe

    expect(recipe).to be_valid
  end

  describe 'methods' do
    context '.name_en' do
      let!(:recipe) { create :recipe }

      it 'return en name' do
        expect(recipe.name_en).to eq recipe.name['en']
      end
    end

    context '.name_ru' do
      let!(:recipe) { create :recipe }

      it 'return ru name' do
        expect(recipe.name_ru).to eq recipe.name['ru']
      end
    end
  end
end
