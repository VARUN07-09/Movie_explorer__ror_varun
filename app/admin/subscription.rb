ActiveAdmin.register Subscription do
    permit_params :user_id, :plan_type, :status, :start_date, :end_date
  
    index do
      selectable_column
      id_column
      column :user
      column :plan_type
      column :status
      column :start_date
      column :end_date
      column :created_at
      actions
    end
  
    filter :user_email, as: :string
    filter :plan_type, as: :select, collection: Subscription.plan_types.keys
    filter :status, as: :select, collection: Subscription.statuses.keys
    filter :start_date
    filter :end_date
  
    form do |f|
        f.inputs do
          f.input :user
          f.input :plan_type
          f.input :status
          f.input :start_date, as: :datepicker
          f.input :end_date, as: :datepicker
        end
        f.actions
      end
      
  
    show do
      attributes_table do
        row :user
        row :plan_type
        row :status
        row :start_date
        row :end_date
        row :created_at
        row :updated_at
      end
    end
  end
  