# frozen_string_literal: true

RSpec.describe Fraction, type: :model do
  it { is_expected.to have_many(:races).dependent(:destroy) }
  it { is_expected.to have_many(:guilds).dependent(:destroy) }
  it { is_expected.to have_many(:events).dependent(:destroy) }
  it { is_expected.to have_many(:statics).dependent(:destroy) }
  it { is_expected.to have_many(:world_fractions).dependent(:destroy) }

  it 'factory is_expected.to be valid' do
    fraction = build :fraction, :alliance

    expect(fraction).to be_valid
  end
end
