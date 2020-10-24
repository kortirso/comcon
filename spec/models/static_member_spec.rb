# frozen_string_literal: true

RSpec.describe StaticMember, type: :model do
  it { is_expected.to belong_to :static }
  it { is_expected.to belong_to :character }

  it 'factory is_expected.to be valid' do
    static_member = build :static_member

    expect(static_member).to be_valid
  end
end
