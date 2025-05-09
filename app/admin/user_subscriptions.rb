# app/admin/user_subscriptions.rb
ActiveAdmin.register UserSubscription do
    permit_params :user_id, :plan_type, :start_date, :end_date, :status
  
    index do
      selectable_column
      id_column
      column :user
      column :plan_type
      column :start_date
      column :end_date
      column :status
      column :created_at
      actions
    end
  
    filter :user
    filter :status
    filter :start_date
    filter :end_date
    filter :created_at
  
    form do |f|
      f.inputs do
        f.input :user
        f.input :plan_type, as: :select, collection: %w[basic premium gold], include_blank: false
        f.input :start_date, as: :datepicker
        f.input :end_date, as: :datepicker
        f.input :status, as: :select, collection: %w[pending active expired canceled], include_blank: false
      end
      f.actions
    end
  
    show do
      attributes_table do
        row :id
        row :user
        row :plan_type
        row :start_date
        row :end_date
        row :status
        row :created_at
        row :updated_at
      end
    end
  end
  