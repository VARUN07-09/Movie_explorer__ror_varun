require 'rails_helper'

RSpec.describe SubscriptionPlan, type: :model do
  subject { build(:subscription_plan) }

  # Test validations
  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:price) }
  it { should validate_presence_of(:duration_months) }  # Updated to duration_months
  it { should validate_presence_of(:plan_type) }

  it { should validate_numericality_of(:price).is_greater_than(0) }
  it { should validate_numericality_of(:duration_months).only_integer.is_greater_than(0) }  # Updated to duration_months

  # Test ransackable attributes
  it "should have the correct ransackable attributes" do
    expect(SubscriptionPlan.ransackable_attributes).to eq(
      ["created_at", "duration_months", "id", "name", "plan_type", "price", "updated_at"]  # Updated to duration_months
    )
  end
end
