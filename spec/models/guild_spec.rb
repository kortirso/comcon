RSpec.describe Guild, type: :model do
  it { should belong_to :world }
  it { should have_many(:characters).dependent(:nullify) }

  it 'factory should be valid' do
    guild = build :guild

    expect(guild).to be_valid
  end
end
