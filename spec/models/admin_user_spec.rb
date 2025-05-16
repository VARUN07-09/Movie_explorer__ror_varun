# # require 'rails_helper'

# # RSpec.describe AdminUser, type: :model do
# #   pending "add some examples to (or delete) #{__FILE__}"
# # end
# RSpec.describe AdminUser, type: :model do
#     describe 'validations' do
#         subject { build(:admin_user) }
#         it { should validate_presence_of(:email) }
#         it { should validate_uniqueness_of(:email).case_insensitive }
#         it { should validate_presence_of(:password).on(:create) }
#         it { should validate_length_of(:password).is_at_least(6).on(:create) }
#         it { should validate_confirmation_of(:password).on(:create) }
#         it 'validates email format' do
#             valid_admin = build(:admin_user, email: 'admin@example.com')
#             expect(valid_admin).to be_valid
#             invalid_admin = build(:admin_user, email: 'invalid_email')
#             expect(invalid_admin).not_to be_valid
#             expect(invalid_admin.errors[:email]).to include('is invalid')
#         end
#     end
#     describe 'associations' do
#         it { should have_many(:comments).class_name('ActiveAdmin::Comment').as(:author).dependent(:destroy) }
#     end
#     describe 'Devise modules' do
#         let(:admin_user) { create(:admin_user, email: 'admin@example.com', password: 'password123') }
#         it 'authenticates with valid credentials' do
#             expect(AdminUser.find_for_database_authentication(email: 'admin@example.com')).to eq(admin_user)
#             expect(admin_user.valid_password?('password123')).to be true
#         end
#         it 'does not authenticate with invalid credentials' do
#             expect(admin_user.valid_password?('wrongpassword')).to be false
#         end
#         it 'supports password reset' do
#             admin_user.send_reset_password_instructions
#             expect(admin_user.reset_password_token).to be_present
#             expect(admin_user.reset_password_sent_at).to be_present
#         end
#         it 'supports remember me' do
#             admin_user.remember_me!
#             expect(admin_user.remember_created_at).to be_present
#         end
#     end
#     describe 'database constraints' do
#         it 'enforces unique email' do
#           create(:admin_user, email: 'admin@example.com')
#           duplicate_admin = build(:admin_user, email: 'admin@example.com')
#           expect(duplicate_admin).not_to be_valid
#           expect(duplicate_admin.errors[:email]).to include('has already been taken')
#         end
    
#         it 'enforces non-null email' do
#           admin_user = build(:admin_user, email: nil)
#           expect(admin_user).not_to be_valid
#           expect(admin_user.errors[:email]).to include("can't be blank")
#         end
#       end
    
#       describe 'factory' do
#         it 'creates a valid admin user' do
#           admin_user = build(:admin_user)
#           expect(admin_user).to be_valid
#         end
#     end
# end
