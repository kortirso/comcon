RSpec.describe CharacterRecipe, type: :model do
  it { should belong_to :recipe }
  it { should belong_to :character_profession }

  it 'factory should be valid' do
    character_recipe = build :character_recipe

    expect(character_recipe).to be_valid
  end
end
