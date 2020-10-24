# frozen_string_literal: true

RSpec.describe GroupRole, type: :model do
  it { is_expected.to belong_to :groupable }

  it 'factory is_expected.to be valid' do
    group_role = build :group_role

    expect(group_role).to be_valid
  end
end
