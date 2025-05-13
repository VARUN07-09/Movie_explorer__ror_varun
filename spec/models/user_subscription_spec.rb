# require 'rails_helper'

# RSpec.describe UserSubscription, type: :model do
#   pending "add some examples to (or delete) #{__FILE__}"
# end
require 'rails_helper'

RSpec.describe UserSubscription, type: :model do
  let(:user) { create(:user) }

  describe 'associations' do
    it { should belong_to(:user) }
  end

  describe 'validations' do
    it { should validate_presence_of(:start_date) }
    it { should validate_presence_of(:end_date) }
    it { should validate_presence_of(:status) }
  end

  describe 'enums' do
    it 'defines enum for status' do
      expect(UserSubscription.statuses).to eq({
        "pending" => 0,
        "active" => 1,
        "expired" => 2,
        "canceled" => 3
      })
    end
  end

  describe 'ransackable attributes' do
    it 'includes expected ransackable attributes' do
      expect(described_class.ransackable_attributes).to include(
        "id", "user_id", "subscription_plan_id", "start_date", "end_date", "status",
        "created_at", "updated_at", "stripe_customer_id", "stripe_subscription_id", "expires_at"
      )
    end
  end

  describe 'ransackable associations' do
    it 'includes expected ransackable associations' do
      expect(described_class.ransackable_associations).to include("user", "subscription_plan")
    end
  end
end
