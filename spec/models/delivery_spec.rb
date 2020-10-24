# frozen_string_literal: true

RSpec.describe Delivery, type: :model do
  it { is_expected.to belong_to :deliveriable }
  it { is_expected.to belong_to :notification }
  it { is_expected.to have_one(:delivery_param).dependent(:destroy) }

  it 'factory is_expected.to be valid' do
    delivery = build :delivery

    expect(delivery).to be_valid
  end
end
