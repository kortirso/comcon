RSpec.describe Character, type: :model do
  it { should belong_to :user }
  it { should belong_to :race }
  it { should belong_to :character_class }
  it { should belong_to :world }
  it { should belong_to(:guild).optional }
  it { should have_many(:dungeon_accesses).dependent(:destroy) }
  it { should have_many(:dungeons).through(:dungeon_accesses) }
  it { should have_many(:owned_events).class_name('Event').with_foreign_key('owner_id').dependent(:destroy) }
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
  it { should have_many(:statics).dependent(:destroy) }
  it { should have_many(:static_members).dependent(:destroy) }
  it { should have_many(:in_statics).through(:static_members).source(:static) }
  it { should have_many(:static_invites).dependent(:destroy) }
  it { should have_many(:invitations_to_statics).through(:static_invites).source(:static) }
  it { should have_one(:guild_role).dependent(:destroy) }

  it 'factory should be valid' do
    character = build :character, :human_warrior

    expect(character).to be_valid
  end

  describe 'methods' do
    context '.full_name' do
      let!(:character) { create :character }

      it 'returns full name for character' do
        expect(character.full_name).to eq "#{character.name} - #{character.world.full_name}"
      end
    end
  end
end
