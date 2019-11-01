RSpec.describe Static, type: :model do
  it { should belong_to :staticable }
  it { should belong_to :fraction }
  it { should belong_to :world }

  it 'factory should be valid' do
    static = build :static, :guild

    expect(static).to be_valid
  end
end
