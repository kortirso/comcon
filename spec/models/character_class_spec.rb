RSpec.describe CharacterClass, type: :model do
  it { should have_many(:characters).dependent(:destroy) }
  it { should have_many(:combinations).dependent(:destroy) }
  it { should have_many(:role_combinations).class_name('Combination') }
  it { should have_many(:available_roles).through(:role_combinations).source(:combinateable) }

  it 'factory should be valid' do
    character_class = build :character_class, :warrior

    expect(character_class).to be_valid
  end

  context '.to_hash' do
    let!(:character_class) { create :character_class, :warrior }

    it 'returns hashed character_class' do
      result = character_class.to_hash

      expect(result.keys).to eq [character_class.id.to_s]
      expect(result.values[0].keys).to eq %w[name roles]
    end
  end
end
