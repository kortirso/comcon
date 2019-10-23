RSpec.describe Profession, type: :model do
  it { should have_many(:character_professions).dependent(:destroy) }
  it { should have_many(:characters).through(:character_professions) }

  it 'factory should be valid' do
    profession = build :profession

    expect(profession).to be_valid
  end
end
