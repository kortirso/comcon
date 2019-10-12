FactoryBot.define do
  factory :user do
    sequence(:email) { |i| "user#{i}@gmail.com" }
    password { 'user123qwE' }
    role { 'user' }

    trait :admin do
      role { 'admin' }
    end
  end
end
