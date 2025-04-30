# db/migrate/YYYYMMDDHHMMSS_create_movies.rb
class CreateMovies < ActiveRecord::Migration[7.1]
  def change
    create_table :movies do |t|
      t.string :title, null: false
      t.string :genre, null: false
      t.integer :release_year, null: false
      t.decimal :rating, precision: 3, scale: 1
      t.string :poster

      t.timestamps
    end
  end
end