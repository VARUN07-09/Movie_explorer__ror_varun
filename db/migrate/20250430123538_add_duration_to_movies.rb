class AddDurationToMovies < ActiveRecord::Migration[7.1]
  def change
    add_column :movies, :duration, :integer
  end
end
