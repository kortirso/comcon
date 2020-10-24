# frozen_string_literal: true

RSpec.describe TimeOffset, type: :model do
  it { is_expected.to belong_to :timeable }

  it 'factory is_expected.to be valid' do
    time_offset = build :time_offset

    expect(time_offset).to be_valid
  end
end
