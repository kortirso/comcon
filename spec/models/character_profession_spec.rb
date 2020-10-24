# frozen_string_literal: true

RSpec.describe CharacterProfession, type: :model do
  it { should belong_to :character }
  it { should belong_to :profession }
  it { should have_many(:character_recipes).dependent(:destroy) }
  it { should have_many(:recipes).through(:character_recipes) }

  it 'factory should be valid' do
    character_profession = build :character_profession

    expect(character_profession).to be_valid
  end
end
