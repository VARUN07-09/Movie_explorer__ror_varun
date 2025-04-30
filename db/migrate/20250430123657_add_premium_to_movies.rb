class AddPremiumToMovies < ActiveRecord::Migration[7.1]
  def change
    add_column :movies, :premium, :boolean
  end
end
