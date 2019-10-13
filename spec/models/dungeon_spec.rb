RSpec.describe Dungeon, type: :model do
  it { should have_many(:dungeon_accesses).dependent(:destroy) }
  it { should have_many(:characters).through(:dungeon_accesses) }
  it { should have_many(:events).dependent(:destroy) }

  it 'factory should be valid' do
    dungeon = build :dungeon

    expect(dungeon).to be_valid
  end
end
