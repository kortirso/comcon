FactoryBot.define do
  factory :world_fraction do
    association :world
    association :fraction, :alliance
  end
end
