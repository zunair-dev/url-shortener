FactoryBot.define do
  factory :statistic do
    association :url
    ip { Faker::Internet.ip_v4_address }
    user_agent { Faker::Internet.user_agent }
    referrer { Faker::Internet.url }
    created_at { Faker::Time.between(from: DateTime.now - 1, to: DateTime.now) }
  end
end
