RSpec.describe WorldStat, type: :model do
  it { should belong_to :world }

  it 'factory should be valid' do
    world_stat = build :world_stat

    expect(world_stat).to be_valid
  end
end
