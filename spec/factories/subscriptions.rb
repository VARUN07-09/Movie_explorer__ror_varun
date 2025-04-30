FactoryBot.define do
  factory :subscription do
    user { nil }
    plan_type { 1 }
    status { 1 }
  end
end
