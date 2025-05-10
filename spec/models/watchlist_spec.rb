require 'rails_helper'

RSpec.describe Watchlist, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:movie) }
  end

  describe 'validations' do
    let(:user) { create(:user) }
    let(:movie) { create(:movie) }

    it 'is valid with valid attributes' do
      watchlist = build(:watchlist, user: user, movie: movie)
      expect(watchlist).to be_valid
    end

    it 'validates presence of user' do
      watchlist = build(:watchlist, user: nil, movie: movie)
      expect(watchlist).not_to be_valid
      expect(watchlist.errors[:user]).to include('must exist')
    end

    it 'validates presence of movie' do
      watchlist = build(:watchlist, user: user, movie: nil)
      expect(watchlist).not_to be_valid
      expect(watchlist.errors[:movie]).to include('must exist')
    end

    it 'validates uniqueness of user_id scoped to movie_id' do
      create(:watchlist, user: user, movie: movie)
      duplicate_watchlist = build(:watchlist, user: user, movie: movie)
      expect(duplicate_watchlist).not_to be_valid
      expect(duplicate_watchlist.errors[:user_id]).to include('already has this movie in their watchlist')
    end

    it 'allows same user to add different movies' do
      create(:watchlist, user: user, movie: movie)
      another_movie = create(:movie, title: 'Another Movie')
      new_watchlist = build(:watchlist, user: user, movie: another_movie)
      expect(new_watchlist).to be_valid
    end

    it 'allows different users to add same movie' do
      create(:watchlist, user: user, movie: movie)
      another_user = create(:user, email: 'another@example.com')
      new_watchlist = build(:watchlist, user: another_user, movie: movie)
      expect(new_watchlist).to be_valid
    end
  end

  describe 'database constraints' do
    let(:now) { Time.current }

    it 'enforces foreign key constraint for user_id' do
      movie = create(:movie)
      expect {
        ActiveRecord::Base.connection.execute(
          "INSERT INTO watchlists (user_id, movie_id, created_at, updated_at) VALUES (999, #{movie.id}, '#{now}', '#{now}')"
        )
      }.to raise_error(ActiveRecord::InvalidForeignKey)
    end

    it 'enforces foreign key constraint for movie_id' do
      user = create(:user)
      expect {
        ActiveRecord::Base.connection.execute(
          "INSERT INTO watchlists (user_id, movie_id, created_at, updated_at) VALUES (#{user.id}, 999, '#{now}', '#{now}')"
        )
      }.to raise_error(ActiveRecord::InvalidForeignKey)
    end
  end
end