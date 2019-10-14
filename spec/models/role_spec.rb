RSpec.describe Role, type: :model do
  it { should have_many(:character_roles).dependent(:destroy) }
  it { should have_many(:characters).through(:character_roles) }

  it 'factory should be valid' do
    role = build :role

    expect(role).to be_valid
  end
end
