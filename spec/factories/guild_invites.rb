# frozen_string_literal: true

FactoryBot.define do
  factory :guild_invite do
    from_guild { false }
    association :guild
    association :character
  end
end
