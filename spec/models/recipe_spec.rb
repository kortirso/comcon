RSpec.describe Recipe, type: :model do
  it { should belong_to :profession }

  it 'factory should be valid' do
    recipe = build :recipe

    expect(recipe).to be_valid
  end
end
