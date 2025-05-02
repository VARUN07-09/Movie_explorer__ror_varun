ActiveAdmin.register SubscriptionPlan do
  permit_params :name, :price, :duration, :plan_type

  filter :name
  filter :price
  filter :duration_months
  filter :plan_type

  form do |f|
    f.inputs do
      f.input :name
      f.input :price
      f.input :duration_months
      f.input :plan_type, as: :select, collection: SubscriptionPlan.plan_types.keys
    end
    f.actions
  end
end
