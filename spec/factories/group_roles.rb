FactoryBot.define do
  factory :group_role do
    value { GroupRole.default }
    left_value { GroupRole.default }
    association :groupable, factory: :event
  end
end
