# frozen_string_literal: true

RSpec.describe WorldFraction, type: :model do
  it { is_expected.to belong_to :world }
  it { is_expected.to belong_to :fraction }
  it { is_expected.to have_many(:events).dependent(:destroy) }
  it { is_expected.to have_many(:characters).dependent(:destroy) }
  it { is_expected.to have_many(:guilds).dependent(:destroy) }
  it { is_expected.to have_many(:statics).dependent(:destroy) }

  it 'factory is_expected.to be valid' do
    world_fraction = build :world_fraction

    expect(world_fraction).to be_valid
  end
end
