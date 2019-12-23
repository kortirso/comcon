RSpec.describe CharacterTransfer, type: :model do
  it { should belong_to :character }
  it { should belong_to :race }
  it { should belong_to :character_class }
  it { should belong_to :world }

  it 'factory should be valid' do
    character_transfer = create :character_transfer

    expect(character_transfer).to be_valid
  end
end
