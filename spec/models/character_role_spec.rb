# frozen_string_literal: true

RSpec.describe CharacterRole, type: :model do
  it { should belong_to :character }
  it { should belong_to :role }

  it 'factory should be valid' do
    character_role = build :character_role

    expect(character_role).to be_valid
  end
end
