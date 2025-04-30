FactoryBot.define do
  factory :subscription_plan do
    name { "MyString" }
    price { "9.99" }
    duration { 1 }
    plan_type { 1 }
  end
end
