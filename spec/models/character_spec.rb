RSpec.describe Character, type: :model do
  it { should belong_to :user }
  it { should belong_to :race }
  it { should belong_to :character_class }
  it { should belong_to :world }
  it { should belong_to(:guild).optional }
  it { should have_many(:dungeon_accesses).dependent(:destroy) }
  it { should have_many(:dungeons).through(:dungeon_accesses) }
  it { should have_many(:owned_events).class_name('Event').with_foreign_key('owner_id') }
  it { should have_many(:subscribes).dependent(:destroy) }
  it { should have_many(:events).through(:subscribes) }
  it { should have_many(:character_roles).dependent(:destroy) }
  it { should have_many(:roles).through(:character_roles) }
  it { should have_many(:main_character_roles).class_name('CharacterRole') }
  it { should have_many(:main_roles).through(:main_character_roles).source(:role) }
  it { should have_many(:secondary_character_roles).class_name('CharacterRole') }
  it { should have_many(:secondary_roles).through(:secondary_character_roles).source(:role) }
  it { should have_many(:character_professions).dependent(:destroy) }
  it { should have_many(:professions).through(:character_professions) }
  it { should have_one(:guild_role).dependent(:destroy) }

  it 'factory should be valid' do
    character = build :character, :human_warrior

    expect(character).to be_valid
  end

  describe 'class methods' do
    context '.has_guild_master?' do
      let!(:user1) { create :user }
      let!(:user2) { create :user }
      let!(:user3) { create :user }
      let!(:guild) { create :guild }
      let!(:character1) { create :character, guild: guild, user: user2 }
      let!(:character2) { create :character, guild: guild, user: user3 }
      let!(:guild_role1) { create :guild_role, guild: guild, character: character1, name: 'rl' }
      let!(:guild_role2) { create :guild_role, guild: guild, character: character2, name: 'gm' }

      it 'returns false for user without characters in guild' do
        result = user1.characters.where(guild_id: guild.id).has_guild_master?

        expect(result).to eq false
      end

      it 'returns false for user with characters in guild, but no gm' do
        result = user2.characters.where(guild_id: guild.id).has_guild_master?

        expect(result).to eq false
      end

      it 'returns true for user with gm characters in guild' do
        result = user3.characters.where(guild_id: guild.id).has_guild_master?

        expect(result).to eq true
      end
    end
  end
end
