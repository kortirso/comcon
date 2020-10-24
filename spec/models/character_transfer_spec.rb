# frozen_string_literal: true

RSpec.describe CharacterTransfer, type: :model do
  it { is_expected.to belong_to :character }
  it { is_expected.to belong_to :race }
  it { is_expected.to belong_to :character_class }
  it { is_expected.to belong_to :world }

  it 'factory is_expected.to be valid' do
    character_transfer = create :character_transfer

    expect(character_transfer).to be_valid
  end
end
