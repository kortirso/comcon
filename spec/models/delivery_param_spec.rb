# frozen_string_literal: true

RSpec.describe DeliveryParam, type: :model do
  it { is_expected.to belong_to :delivery }

  it 'factory is_expected.to be valid' do
    delivery_param = build :delivery_param

    expect(delivery_param).to be_valid
  end
end
