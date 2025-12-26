class CreatePlans < ActiveRecord::Migration[8.1]
  def change
    create_table :plans, id: :uuid do |t|
      t.string :name, null: false
      t.json :features
      t.integer :price, null: false
      t.string :stripe_price_id

      t.timestamps
    end
  end
end
