# frozen_string_literal: true

RSpec.describe Character, type: :model do
  it { is_expected.to belong_to :user }
  it { is_expected.to belong_to :race }
  it { is_expected.to belong_to :character_class }
  it { is_expected.to belong_to :world }
  it { is_expected.to belong_to(:guild).optional }
  it { is_expected.to belong_to :world_fraction }
  it { is_expected.to have_many(:owned_events).class_name('Event').with_foreign_key('owner_id').dependent(:destroy) }
  it { is_expected.to have_many(:subscribes).dependent(:destroy) }
  it { is_expected.to have_many(:events).through(:subscribes).source(:subscribeable) }
  it { is_expected.to have_many(:character_roles).dependent(:destroy) }
  it { is_expected.to have_many(:roles).through(:character_roles) }
  it { is_expected.to have_many(:main_character_roles).class_name('CharacterRole') }
  it { is_expected.to have_many(:main_roles).through(:main_character_roles).source(:role) }
  it { is_expected.to have_many(:secondary_character_roles).class_name('CharacterRole') }
  it { is_expected.to have_many(:secondary_roles).through(:secondary_character_roles).source(:role) }
  it { is_expected.to have_many(:character_professions).dependent(:destroy) }
  it { is_expected.to have_many(:professions).through(:character_professions) }
  it { is_expected.to have_many(:statics).dependent(:destroy) }
  it { is_expected.to have_many(:static_members).dependent(:destroy) }
  it { is_expected.to have_many(:in_statics).through(:static_members).source(:static) }
  it { is_expected.to have_many(:static_invites).dependent(:destroy) }
  it { is_expected.to have_many(:invitations_to_statics).through(:static_invites).source(:static) }
  it { is_expected.to have_many(:guild_invites).dependent(:destroy) }
  it { is_expected.to have_many(:guild_invitations).through(:guild_invites).source(:guild) }
  it { is_expected.to have_many(:bank_requests).dependent(:nullify) }
  it { is_expected.to have_many(:character_transfers).dependent(:destroy) }
  it { is_expected.to have_many(:equipment).dependent(:destroy) }
  it { is_expected.to have_one(:guild_role).dependent(:destroy) }

  it 'factory is_expected.to be valid' do
    character = create :character, :human_warrior

    expect(character).to be_valid
  end

  describe 'methods' do
    describe '.full_name' do
      let!(:character) { create :character }

      it 'returns full name for character' do
        expect(character.full_name).to eq "#{character.name} - #{character.world.full_name}"
      end
    end
  end
end
