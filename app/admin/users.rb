ActiveAdmin.register User do

  filter :email
  filter :created_at
  filter :subscription_id if User.reflect_on_association(:subscriptions)

  permit_params :name, :email, :password, :password_confirmation, :role

  show do
    attributes_table do
      row :email
      row :role
      row :created_at
      row :updated_at
    end

  #   panel "Subscriptions" do
  #     table_for user.subscriptions do
  #       column :plan_type
  #       column :status
  #       column :start_date
  #       column :end_date
  #     end
  #   end
  end

  form do |f|
    if f.object.new_record?
      f.inputs "Create New User" do
        f.input :name
        f.input :email
        f.input :password
        f.input :password_confirmation
        f.input :role, as: :select, collection: ['user', 'admin', 'supervisor'], include_blank: false
      end
    else
      f.inputs "Edit User Details" do
        f.input :name
        f.input :email
        f.input :role, as: :select, collection: ['admin', 'supervisor'], include_blank: false
        
      end
    end
    f.actions
  end
  
end
