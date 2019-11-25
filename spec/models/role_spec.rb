RSpec.describe Role, type: :model do
  it { should have_many(:character_roles).dependent(:destroy) }
  it { should have_many(:characters).through(:character_roles) }
  it { should have_many(:combinations).dependent(:destroy) }

  it 'factory should be valid' do
    role = build :role

    expect(role).to be_valid
  end

  context '.to_hash' do
    let!(:role) { create :role, :tank }

    it 'returns hashed role' do
      result = role.to_hash

      expect(result.keys).to eq [role.id.to_s]
      expect(result.values[0].keys).to eq %w[name]
    end
  end
end
