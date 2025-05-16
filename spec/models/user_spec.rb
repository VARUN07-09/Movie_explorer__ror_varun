# require 'rails_helper'

# RSpec.describe User, type: :model do
#   describe 'associations' do
#     it { should have_many(:user_subscriptions).dependent(:destroy) }
#     it { should have_many(:watchlists).dependent(:destroy) }
#     it { should have_many(:movies).through(:watchlists) }
#     it { should have_one_attached(:profile_picture) }
#   end

#   describe 'validations' do
#     subject { FactoryBot.build(:user) } # assumes you have a user factory

#     it { should validate_presence_of(:name) }
#     it { should validate_presence_of(:email) }
#     # it { should validate_uniqueness_of(:email).case_insensitive }
#     # it { should allow_value('user@example.com').for(:email) }
#     it { should_not allow_value('invalid_email').for(:email) }

#     it 'validates password length on create' do
#       user = described_class.new(password: 'short')
#       user.validate
#       expect(user.errors[:password]).to include("is too short (minimum is 8 characters)")
#     end
#   end

#   describe 'enums' do
#     it { should define_enum_for(:role).with_values(user: 0, supervisor: 1, admin: 2) }
#   end

#   describe '#profile_picture_url' do
#     let(:user) { FactoryBot.create(:user) }

#     it 'returns nil if no profile picture is attached' do
#       expect(user.profile_picture_url).to be_nil
#     end

#     it 'returns Cloudinary URL if profile picture is attached' do
#       user.profile_picture.attach(
#         io: File.open(Rails.root.join('spec/fixtures/files/sample.jpg')),
#         filename: 'sample.jpg',
#         content_type: 'image/jpeg'
#       )

#       allow(Cloudinary::Utils).to receive(:cloudinary_url).and_return("https://res.cloudinary.com/sample.jpg")
#       expect(user.profile_picture_url).to eq("https://res.cloudinary.com/sample.jpg")
#     end
#   end

#   describe 'callbacks' do
#     let(:free_plan) { create(:subscription_plan, plan_type: :free, price: 0, duration_months: 12) }

#     before do
#       allow(Stripe::Customer).to receive(:create).and_return(OpenStruct.new(id: 'cus_test123'))
#     end

#     # it 'creates a default subscription after user creation' do
#     #   user = create(:user)
#     #   expect(user.user_subscriptions.count).to eq(1)
#     #   expect(user.user_subscriptions.first.subscription_plan.plan_type).to eq('free')
#     # end

#     # it 'logs error if Stripe fails' do
#     #   allow(Stripe::Customer).to receive(:create).and_raise(Stripe::StripeError.new("Stripe error"))
#     #   expect(Rails.logger).to receive(:error).with(/Failed to create Stripe customer/)
#     #   expect {
#     #     create(:user)
#     #   }.to change(UserSubscription, :count).by(1) # still creates subscription without Stripe
#     # end
#   end
# end
