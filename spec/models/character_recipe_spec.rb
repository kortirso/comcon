# frozen_string_literal: true

RSpec.describe CharacterRecipe, type: :model do
  it { is_expected.to belong_to :recipe }
  it { is_expected.to belong_to :character_profession }

  it 'factory is_expected.to be valid' do
    character_recipe = build :character_recipe

    expect(character_recipe).to be_valid
  end
end
