class AddStreamingPlatformToMovies < ActiveRecord::Migration[7.1]
  def change
    add_column :movies, :streaming_platform, :string
  end
end
