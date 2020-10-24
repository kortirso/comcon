# frozen_string_literal: true

RSpec.describe WorldStat, type: :model do
  it { is_expected.to belong_to :world }

  it 'factory is_expected.to be valid' do
    world_stat = build :world_stat

    expect(world_stat).to be_valid
  end
end
