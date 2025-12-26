class AddPalnToTenants < ActiveRecord::Migration[8.1]
  def change
    add_reference :tenants, :plan, null: false, foreign_key: true, type: :uuid
  end
end
