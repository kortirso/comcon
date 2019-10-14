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
  it { should have_many(:character_roles).dependent(:destroy) }
  it { should have_many(:roles).through(:character_roles) }
  it { should have_many(:main_character_roles).class_name('CharacterRole') }
  it { should have_many(:main_roles).through(:main_character_roles).source(:role) }
  it { should have_many(:secondary_character_roles).class_name('CharacterRole') }
  it { should have_many(:secondary_roles).through(:secondary_character_roles).source(:role) }

  it 'factory should be valid' do
    character = build :character, :human_warrior

    expect(character).to be_valid
  end
end
