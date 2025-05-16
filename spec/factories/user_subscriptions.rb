FactoryBot.define do
  factory :user_subscription do
    user
    plan_type { '1-month' }
    start_date { Date.today }
    end_date { Date.today + 30 }
    status { :active }
    expires_at { end_date }
  end
end