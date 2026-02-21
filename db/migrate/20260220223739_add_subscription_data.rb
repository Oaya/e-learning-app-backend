class AddSubscriptionData < ActiveRecord::Migration[8.1]
  def change
    add_column :tenants, :current_period_end, :datetime
    add_column :tenants, :cancel_at_period_end, :boolean
  end
end
