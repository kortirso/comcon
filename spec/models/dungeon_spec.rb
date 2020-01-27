RSpec.describe Dungeon, type: :model do
  it { should have_many(:events).dependent(:destroy) }

  it 'factory should be valid' do
    dungeon = build :dungeon

    expect(dungeon).to be_valid
  end
end
