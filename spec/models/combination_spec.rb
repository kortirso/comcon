# frozen_string_literal: true

RSpec.describe Combination, type: :model do
  it { is_expected.to belong_to :character_class }
  it { is_expected.to belong_to :combinateable }

  it 'factory is_expected.to be valid' do
    combination = build :combination

    expect(combination).to be_valid
  end
end
