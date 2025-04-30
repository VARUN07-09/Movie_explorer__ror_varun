class AddMainLeadToMovies < ActiveRecord::Migration[7.1]
  def change
    add_column :movies, :main_lead, :string
  end
end
