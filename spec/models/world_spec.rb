RSpec.describe World, type: :model do
  it { should have_many(:characters).dependent(:destroy) }
  it { should have_many(:guilds).dependent(:destroy) }

  it 'factory should be valid' do
    world = build :world

    expect(world).to be_valid
  end

  describe 'methods' do
    context '.full_name' do
      let!(:world) { create :world }

      it 'returns full name for world' do
        expect(world.full_name).to eq "#{world.name} (#{world.zone})"
      end
    end
  end
end
