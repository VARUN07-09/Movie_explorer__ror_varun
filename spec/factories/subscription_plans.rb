FactoryBot.define do
  factory :subscription_plan do
    name { "MyString" }
    price { "9.99" }
    duration_months { 1 }
    plan_type { 1 }
    description { "MyText" }
  end
end
