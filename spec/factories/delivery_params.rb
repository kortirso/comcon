FactoryBot.define do
  factory :delivery_param do
    params { { 'id' => '1', 'token' => '1' } }
    association :delivery
  end
end
