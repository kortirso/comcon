FactoryBot.define do
  factory :user do
    sequence(:email) { |i| "user#{i}@gmail.com" }
    password { 'user123qwE' }
    role { 'user' }
    confirmed_at { DateTime.now }

    trait :admin do
      role { 'admin' }
    end

    trait :unconfirmed do
      confirmed_at { nil }
    end
  end
end
