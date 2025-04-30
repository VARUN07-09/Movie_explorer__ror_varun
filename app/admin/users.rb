ActiveAdmin.register User do
  # Define only the filters you actually want
  filter :email
  filter :created_at
  filter :subscription_id # if this association exists
  permit_params :role
  # Do NOT include password_digest
  
  show do
    attributes_table do
      row :email
      row :created_at
      row :updated_at
    end

    panel "Subscriptions" do
      table_for user.subscriptions do
        column :plan_type
        column :status
        column :start_date
        column :end_date
      end
    end
  end
end