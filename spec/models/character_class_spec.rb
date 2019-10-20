RSpec.describe CharacterClass, type: :model do
  it { should have_many(:characters).dependent(:destroy) }
  it { should have_many(:combinations).dependent(:destroy) }
  it { should have_many(:role_combinations).class_name('Combination') }
  it { should have_many(:available_roles).through(:role_combinations).source(:combinateable) }

  it 'factory should be valid' do
    character_class = build :character_class, :warrior

    expect(character_class).to be_valid
  end
end
