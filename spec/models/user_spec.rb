require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:email) }
    it { should validate_presence_of(:password) }
    it { should validate_length_of(:password).is_at_least(8) }

    it 'is valid with valid attributes' do
      user = build(:user, name: 'John Doe', email: 'john@example.com', password: 'password123', password_confirmation: 'password123', role: :user)
      expect(user).to be_valid
    end

    it 'is invalid with an invalid email format' do
      user = build(:user, email: 'invalid_email')
      expect(user).not_to be_valid
      expect(user.errors[:email]).to include('is invalid')
    end

    it 'is invalid with a password confirmation mismatch' do
      user = build(:user, password: 'password123', password_confirmation: 'different')
      expect(user).not_to be_valid
      expect(user.errors[:password_confirmation]).to include("doesn't match Password")
    end
  end

  describe 'associations' do
    it { should have_many(:user_subscriptions).dependent(:destroy) }
    it { should have_many(:watchlists).dependent(:destroy) }
    it { should have_many(:movies).through(:watchlists) }
  end

  describe 'enums' do
    it { should define_enum_for(:role).with_values(user: 0, supervisor: 1, admin: 2) }
  end

  describe 'role methods' do
    it 'returns true for admin? when role is admin' do
      user = build(:user, role: :admin)
      expect(user.admin?).to be true
      expect(user.supervisor?).to be false
      expect(user.user?).to be false
    end

    it 'returns true for supervisor? when role is supervisor' do
      user = build(:user, role: :supervisor)
      expect(user.supervisor?).to be true
      expect(user.admin?).to be false
      expect(user.user?).to be false
    end

    it 'returns true for user? when role is user' do
      user = build(:user, role: :user)
      expect(user.user?).to be true
      expect(user.admin?).to be false
      expect(user.supervisor?).to be false
    end
  end
end