FactoryBot.define do
  factory :user do
    name { Faker::Name.name } # Use Faker for unique names
    email { Faker::Internet.unique.email }
    password { "password123" }
    password_confirmation { "password123" }
    role { :user }

    # Traits for different roles
    trait :admin do
      role { :admin }
    end

    trait :supervisor do
      role { :supervisor }
    end
  end
end