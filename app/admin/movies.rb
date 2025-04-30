ActiveAdmin.register Movie do
    permit_params :title, :genre, :release_year, :rating, :poster
  
    # Index page configuration
    index do
      selectable_column
      id_column
      column :title
      column :genre
      column :release_year
      column :rating
      column :poster do |movie|
        if movie.poster.attached?
          image_tag movie.poster_url, size: '100x150'
        else
          'No Poster'
        end
      end
      actions
    end
  
    # Filters for searching
    filter :title
    filter :genre
    filter :release_year
    filter :rating
  
    # Form for creating/editing movies
    form do |f|
      f.inputs do
        f.input :title
        f.input :genre
        f.input :release_year
        f.input :rating
        f.input :poster, as: :file
      end
      f.actions
    end
  
    # Show page configuration
    show do
      attributes_table do
        row :id
        row :title
        row :genre
        row :release_year
        row :rating
        row :poster do |movie|
          if movie.poster.attached?
            image_tag movie.poster_url, size: '200x300'
          else
            'No Poster'
          end
        end
        row :created_at
        row :updated_at
      end
    end
  end