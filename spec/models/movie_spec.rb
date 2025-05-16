# require 'rails_helper'

# RSpec.describe Movie, type: :model do
#   describe 'validations' do
#     subject { build(:movie) }

#     it { should validate_presence_of(:title) }
#     it { should validate_uniqueness_of(:title) }
#     it { should validate_presence_of(:genre) }
#     it { should validate_presence_of(:release_year) }

#     it {
#       should validate_numericality_of(:release_year)
#         .only_integer
#         .is_greater_than(1880)
#     }

#     it {
#       should validate_numericality_of(:rating)
#         .is_greater_than_or_equal_to(0)
#         .is_less_than_or_equal_to(10)
#         .allow_nil
#     }

#     it 'validates poster content type' do
#       movie = build(:movie)
#       movie.poster.attach(
#         io: StringIO.new('fake image content'),
#         filename: 'test.jpg',
#         content_type: 'image/jpeg'
#       )
#       expect(movie).to be_valid
#     end

#     it 'rejects invalid poster content type' do
#       movie = build(:movie)
#       movie.poster.attach(
#         io: StringIO.new('fake text'),
#         filename: 'test.txt',
#         content_type: 'text/plain'
#       )
#       expect(movie).not_to be_valid
#       expect(movie.errors[:poster]).to include('has an invalid content type')
#     end

#     it 'rejects oversized poster' do
#       movie = build(:movie)
#       movie.poster.attach(
#         io: StringIO.new('a' * 6.megabytes),
#         filename: 'test.jpg',
#         content_type: 'image/jpeg'
#       )
#       expect(movie).not_to be_valid
#       expect(movie.errors[:poster]).to include('file size must be less than 5 MB (current size is 6 MB)')
#     end
#   end

#   describe 'associations' do
#     it { should have_many(:watchlists).dependent(:destroy) }
#     it { should have_many(:users).through(:watchlists) }
#   end

#   describe 'ActiveStorage attachments' do
#     it { should have_one_attached(:poster) }
#     it { should have_one_attached(:banner) }
#   end

#   describe '.search' do
#     # before { Movie.delete_all } # Ensure clean state
#     it 'finds movies by title' do
#       create(:movie, title: "Inception-#{SecureRandom.hex(4)}")
#       create(:movie, title: "Avatar-#{SecureRandom.hex(4)}")
#       results = Movie.search('Inception')
#       expect(results.pluck(:title)).to include(a_string_matching(/Inception/))
#     end

#     it 'returns empty for no matches' do
#       create(:movie, title: "Inception-#{SecureRandom.hex(4)}")
#       results = Movie.search('Matrix')
#       expect(results).to be_empty
#     end
#   end

#   describe '#poster_url' do
#     it 'returns nil if no poster is attached' do
#       movie = build(:movie)
#       expect(movie.poster_url).to be_nil
#     end
#   end

#   describe '#banner_url' do
#     it 'returns nil if no banner is attached' do
#       movie = build(:movie)
#       expect(movie.banner_url).to be_nil
#     end
#   end

# end