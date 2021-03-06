# frozen_string_literal: true

FactoryBot.define do
  factory :guild do
    sequence(:name) { |i| "Name#{i}" }
    description { '' }
    association :world
    association :fraction

    before(:create) do |guild|
      guild.world_fraction = WorldFraction.find_or_create_by(world: guild.world, fraction: guild.fraction)
    end
  end
end
