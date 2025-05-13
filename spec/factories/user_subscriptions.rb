FactoryBot.define do
  factory :user_subscription do
    user
    status { %w[active expired].sample }
    stripe_customer_id { "cus_#{SecureRandom.hex(8)}" }
    stripe_subscription_id { "sub_#{SecureRandom.hex(8)}" }

    # Transient attribute to select plan type
    transient do
      plan_type { %w[1-day 1-month 3-months].sample }
    end

    # Set start_date and end_date based on plan_type
    after(:build) do |user_subscription, evaluator|
      case evaluator.plan_type
      when '1-day'
        user_subscription.start_date = Date.today
        user_subscription.end_date = Date.today + 1.day
      when '1-month'
        user_subscription.start_date = Date.today
        user_subscription.end_date = Date.today + 1.month
      when '3-months'
        user_subscription.start_date = Date.today
        user_subscription.end_date = Date.today + 3.months
      end
    end
  end
end