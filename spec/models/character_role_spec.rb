# frozen_string_literal: true

RSpec.describe CharacterRole, type: :model do
  it { is_expected.to belong_to :character }
  it { is_expected.to belong_to :role }

  it 'factory is_expected.to be valid' do
    character_role = build :character_role

    expect(character_role).to be_valid
  end
end
