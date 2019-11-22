RSpec.describe WorldFraction, type: :model do
  it { should belong_to :world }
  it { should belong_to :fraction }
  it { should have_many(:events).dependent(:destroy) }
  it { should have_many(:characters).dependent(:destroy) }
  it { should have_many(:guilds).dependent(:destroy) }
  it { should have_many(:statics).dependent(:destroy) }

  it 'factory should be valid' do
    world_fraction = build :world_fraction

    expect(world_fraction).to be_valid
  end
end
