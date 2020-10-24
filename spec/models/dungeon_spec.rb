# frozen_string_literal: true

RSpec.describe Dungeon, type: :model do
  it { is_expected.to have_many(:events).dependent(:destroy) }

  it 'factory is_expected.to be valid' do
    dungeon = build :dungeon

    expect(dungeon).to be_valid
  end
end
