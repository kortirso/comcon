RSpec.describe Delivery, type: :model do
  it { should belong_to :guild }
  it { should belong_to :notification }
  it { should have_one(:delivery_param).dependent(:destroy) }

  it 'factory should be valid' do
    delivery = build :delivery

    expect(delivery).to be_valid
  end
end
