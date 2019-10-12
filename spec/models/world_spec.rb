RSpec.describe World, type: :model do
  it 'factory should be valid' do
    world = build :world

    expect(world).to be_valid
  end
end
