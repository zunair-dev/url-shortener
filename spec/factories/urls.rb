FactoryBot.define do
  factory :url do
    url { Faker::Internet.url }
    slug { SecureRandom.alphanumeric(8) }
  end
end
