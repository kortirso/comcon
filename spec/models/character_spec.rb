RSpec.describe Character, type: :model do
  it { should belong_to :user }
  it { should belong_to :race }
  it { should belong_to :character_class }

  it 'factory should be valid' do
    character = build :character, :human_warrior

    expect(character).to be_valid
  end
end
