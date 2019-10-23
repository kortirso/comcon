RSpec.describe Profession, type: :model do
  it 'factory should be valid' do
    profession = build :profession

    expect(profession).to be_valid
  end
end
