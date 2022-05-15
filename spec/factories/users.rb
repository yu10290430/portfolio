FactoryBot.define do
  factory :user do
    sequence(:name) { |n| "USER_NAME-#{n}"}
    sequence(:email) { |n| "TEST-#{n}@example.com"}
    password {"password"}
    password_confirmation {"password"}
    introduction {"testuser_introduction"}
    avatar { fixture_file_upload("spec/fixtures/files/Certificate-CSS基礎.png") }
  end
end
