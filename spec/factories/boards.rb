FactoryBot.define do
  factory :board do
    association :user
    sequence(:title) { |n| "TITLE-#{n}"}
    body { "MyText" }
    weather { "晴れ" }
    address { "東京都" }
    kind { "エギング" }
    date { "2022-04-25" }
    tide { "大潮" }
    result { "3" }
    created_at { "2022-04-25" }
  end
end
