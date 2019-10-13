RSpec.describe DungeonAccess, type: :model do
  it { should belong_to :character }
  it { should belong_to :dungeon }

  it 'factory should be valid' do
    dungeon_access = build :dungeon_access

    expect(dungeon_access).to be_valid
  end
end
