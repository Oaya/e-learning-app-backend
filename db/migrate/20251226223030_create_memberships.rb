class CreateMemberships < ActiveRecord::Migration[8.1]
  def change
    create_table :memberships, id: :uuid do |t|
      t.string :role, null: false
      t.references :user, type: :uuid, null: false, foreign_key: true
      t.references :tenant, type: :uuid, null: false, foreign_key: true
      t.timestamps
    end
  end
end
