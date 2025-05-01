require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      user = User.new(
        name: 'John Doe',
        email: 'john@example.com',
        password: 'password',
        role: :user
      )
      expect(user).to be_valid
    end

    it 'is invalid without a name' do
      user = User.new(name: nil, email: 'john@example.com', password: 'password')
      expect(user).not_to be_valid
      expect(user.errors[:name]).to include("can't be blank")
    end

    it 'is invalid without an email' do
      user = User.new(name: 'John', email: nil, password: 'password')
      expect(user).not_to be_valid
      expect(user.errors[:email]).to include("can't be blank")
    end

    it 'is invalid with a duplicate email' do
      User.create!(name: 'Jane', email: 'jane@example.com', password: 'password')
      user = User.new(name: 'Another', email: 'jane@example.com', password: 'password')
      expect(user).not_to be_valid
      expect(user.errors[:email]).to include("has already been taken")
    end

    it 'is invalid with a short password' do
      user = User.new(name: 'Shorty', email: 'short@example.com', password: '123')
      expect(user).not_to be_valid
      expect(user.errors[:password]).to include("is too short (minimum is 6 characters)")
    end
  end

  describe 'associations' do
    it { should have_one(:subscription).dependent(:destroy) }
  end

  describe 'enums' do
    it { should define_enum_for(:role).with_values(user: 0, supervisor: 1, admin: 2) }
  end
end
