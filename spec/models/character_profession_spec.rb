# frozen_string_literal: true

RSpec.describe CharacterProfession, type: :model do
  it { is_expected.to belong_to :character }
  it { is_expected.to belong_to :profession }
  it { is_expected.to have_many(:character_recipes).dependent(:destroy) }
  it { is_expected.to have_many(:recipes).through(:character_recipes) }

  it 'factory is_expected.to be valid' do
    character_profession = build :character_profession

    expect(character_profession).to be_valid
  end
end
