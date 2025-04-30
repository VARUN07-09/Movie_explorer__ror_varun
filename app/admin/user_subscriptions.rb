ActiveAdmin.register UserSubscription do
  permit_params :user_id, :subscription_plan_id, :start_date, :end_date, :status

  form do |f|
    f.inputs do
      f.input :user
      f.input :subscription_plan
      f.input :start_date, as: :datepicker
      f.input :end_date, as: :datepicker
      f.input :status, as: :select, collection: UserSubscription.statuses.keys
    end
    f.actions
  end
end
