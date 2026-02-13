class AddStripeCheckoutSessionIdToTenants < ActiveRecord::Migration[8.1]
  def change
    add_column :tenants, :stripe_subscription_id, :string
    add_column :tenants, :stripe_customer_id, :string
  end
end
