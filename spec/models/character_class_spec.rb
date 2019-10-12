RSpec.describe CharacterClass, type: :model do
  it { should have_many(:characters).dependent(:destroy) }

  it 'factory should be valid' do
    character_class = build :character_class, :warrior

    expect(character_class).to be_valid
  end
end
