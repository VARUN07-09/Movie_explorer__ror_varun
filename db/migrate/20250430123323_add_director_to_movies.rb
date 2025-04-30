class AddDirectorToMovies < ActiveRecord::Migration[7.1]
  def change
    add_column :movies, :director, :string
  end
end
