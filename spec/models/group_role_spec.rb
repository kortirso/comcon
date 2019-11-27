RSpec.describe GroupRole, type: :model do
  it { should belong_to :groupable }

  it 'factory should be valid' do
    group_role = build :group_role

    expect(group_role).to be_valid
  end
end
