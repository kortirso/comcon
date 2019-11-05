RSpec.describe DeliveryParam, type: :model do
  it { should belong_to :delivery }

  it 'factory should be valid' do
    delivery_param = build :delivery_param

    expect(delivery_param).to be_valid
  end
end
