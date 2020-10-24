# frozen_string_literal: true

RSpec.describe Activity, type: :model do
  it { is_expected.to belong_to(:guild).optional }

  it 'factory is_expected.to be valid' do
    activity = build :activity

    expect(activity).to be_valid
  end
end
