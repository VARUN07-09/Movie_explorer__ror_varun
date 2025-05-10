require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    let(:user_attributes) do
      {
        name: 'John Doe',
        email: 'john@example.com',
        password: 'password123',
        password_confirmation: 'password123',
        role: :user
      }
    end

    it 'is valid with valid attributes' do
      user = build(:user, user_attributes)
      expect(user).to be_valid
    end

    it 'is invalid without a name' do
      user = build(:user, user_attributes.merge(name: nil))
      expect(user).not_to be_valid
      expect(user.errors[:name]).to include("can't be blank")
    end

    it 'is invalid without an email' do
      user = build(:user, user_attributes.merge(email: nil))
      expect(user).not_to be_valid
      expect(user.errors[:email]).to include("can't be blank")
    end

    it 'is invalid with a duplicate email' do
      create(:user, email: 'jane@example.com')
      user = build(:user, user_attributes.merge(email: 'jane@example.com'))
      expect(user).not_to be_valid
      expect(user.errors[:email]).to include("has already been taken")
    end

    it 'is invalid with a short password' do
      user = build(:user, user_attributes.merge(password: '123', password_confirmation: '123'))
      expect(user).not_to be_valid
      expect(user.errors[:password]).to include("is too short (minimum is 8 characters)")
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
end