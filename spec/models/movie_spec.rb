require 'rails_helper'

RSpec.describe Movie, type: :model do
  describe 'validations' do
    subject { build(:movie) }

    it { should validate_presence_of(:title) }
    it { should validate_uniqueness_of(:title) }

    it { should validate_presence_of(:genre) }
    it { should validate_presence_of(:release_year) }

    it {
      should validate_numericality_of(:release_year)
        .only_integer
        .is_greater_than(1880)
    }

    it {
      should validate_numericality_of(:rating)
        .is_greater_than_or_equal_to(0)
        .is_less_than_or_equal_to(10)
        .allow_nil
    }

    it 'validates poster content type and size' do
      movie = build(:movie)
      file = fixture_file_upload(Rails.root.join('spec/fixtures/files/sample.jpg'), 'image/jpeg')
      movie.poster.attach(file)

      expect(movie).to be_valid
    end
  end

  describe 'ActiveStorage attachments' do
    it { is_expected.to have_one_attached(:poster) }
    it { is_expected.to have_one_attached(:banner) }
  end

  describe '#poster_url' do
    it 'returns nil if no poster is attached' do
      movie = build(:movie)
      expect(movie.poster_url).to be_nil
    end

    it 'returns the URL if poster is attached' do
      movie = create(:movie)
      file = fixture_file_upload(Rails.root.join('spec/fixtures/files/sample.jpg'), 'image/jpeg')
      movie.poster.attach(file)

      expect(movie.poster_url).to be_present
    end
  end
end
