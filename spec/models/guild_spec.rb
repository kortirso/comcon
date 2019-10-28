RSpec.describe Guild, type: :model do
  it { should belong_to :world }
  it { should belong_to :fraction }
  it { should have_many(:characters).dependent(:nullify) }
  it { should have_many(:events).dependent(:destroy) }
  it { should have_many(:guild_roles).dependent(:destroy) }
  it { should have_many(:characters_with_role).through(:guild_roles).source(:character) }

  it 'factory should be valid' do
    guild = build :guild

    expect(guild).to be_valid
  end

  describe 'methods' do
    context '.full_name' do
      let!(:guild) { create :guild }

      it 'returns full name for guild' do
        expect(guild.full_name).to eq "#{guild.name}, #{guild.fraction.name['en']}, #{guild.world.full_name}"
      end
    end
  end
end
