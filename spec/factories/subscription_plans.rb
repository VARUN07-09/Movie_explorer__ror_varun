# spec/factories/subscription_plans.rb
FactoryBot.define do
  factory :subscription_plan do
    name { "Basic Plan" }
    price { 9.99 }
    duration_months { 30 }
    plan_type { :basic }
  end
end
