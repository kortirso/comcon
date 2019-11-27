FactoryBot.define do
  factory :group_role do
    value { { tanks: { amount: 0, by_class: {} }, healers: { amount: 0, by_class: {} }, dd: { amount: 0, by_class: {} } } }
    association :groupable, factory: :event
  end
end
