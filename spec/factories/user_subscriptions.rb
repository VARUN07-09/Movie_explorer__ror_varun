FactoryBot.define do
  factory :user_subscription do
    user { nil }
    subscription_plan { nil }
    start_date { "2025-04-29" }
    end_date { "2025-04-29" }
    status { 1 }
  end
end
