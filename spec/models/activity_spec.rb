# frozen_string_literal: true

RSpec.describe Activity, type: :model do
  it { should belong_to(:guild).optional }

  it 'factory should be valid' do
    activity = build :activity

    expect(activity).to be_valid
  end
end
