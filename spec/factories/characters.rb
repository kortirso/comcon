FactoryBot.define do
  factory :character do
    sequence(:name) { |i| "Name#{i}" }
    level { 60 }
    association :user
    association :world
    association :race, :human
    association :character_class, :paladin

    trait :human_warrior do
      association :race, :human
      association :character_class, :warrior
    end

    trait :orc do
      association :race, :orc
    end

    before(:create) do |character|
      character.world_fraction = WorldFraction.find_or_create_by!(world: character.world, fraction: character.race.fraction)
    end
  end
end
