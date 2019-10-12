FactoryBot.define do
  factory :world do
    sequence(:name) { |i| "Name#{i}" }
    zone { 'EU' }
  end
end
