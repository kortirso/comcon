RSpec.describe Role, type: :model do
  it 'factory should be valid' do
    role = build :role

    expect(role).to be_valid
  end
end
