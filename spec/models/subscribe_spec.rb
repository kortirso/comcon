# frozen_string_literal: true

RSpec.describe Subscribe, type: :model do
  it { is_expected.to belong_to :character }
  it { is_expected.to belong_to :subscribeable }

  it 'factory is_expected.to be valid' do
    subscribe = build :subscribe

    expect(subscribe).to be_valid
  end
end
