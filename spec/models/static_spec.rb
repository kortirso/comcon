RSpec.describe Static, type: :model do
  it { should belong_to :guild }

  it 'factory should be valid' do
    static = build :static

    expect(static).to be_valid
  end
end
