RSpec.describe Equipment, type: :model do
  it { should belong_to :character }
  it { should belong_to(:game_item).optional }

  it 'factory should be valid' do
    equipment = build :equipment

    expect(equipment).to be_valid
  end
end
