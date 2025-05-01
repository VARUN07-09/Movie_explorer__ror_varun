require 'rails_helper'

RSpec.describe SubscriptionPlan, type: :model do
  describe 'validations' do
    subject { build(:subscription_plan) }

    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:price) }
    it { should validate_numericality_of(:price).is_greater_than_or_equal_to(0) }
    it { should validate_presence_of(:duration) }
    it { should validate_numericality_of(:duration).only_integer.is_greater_than(0) }

    it 'should validate plan_type as enum' do
      expect(SubscriptionPlan.plan_types).to include("free", "basic", "premium")
    end
  end

  describe 'associations' do
    it { should have_many(:user_subscriptions) }
  end

  describe '#ransackable_attributes' do
    it 'returns the correct list of ransackable attributes' do
      expect(SubscriptionPlan.ransackable_attributes).to eq(
        ["created_at", "duration", "id", "name", "plan_type", "price", "updated_at"]
      )
    end
  end

  describe '#ransackable_associations' do
    it 'returns the correct list of ransackable associations' do
      expect(SubscriptionPlan.ransackable_associations).to eq(["user_subscriptions"])
    end
  end
end
