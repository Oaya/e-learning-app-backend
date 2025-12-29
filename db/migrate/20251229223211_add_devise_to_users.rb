class AddDeviseToUsers < ActiveRecord::Migration[8.1]
  def change
    # Required by Devise :database_authenticatable
    add_column :users, :encrypted_password, :string, null: false, default: ""

    # Recommended: ensure uniqueness of email
    add_index :users, :email, unique: true unless index_exists?(:users, :email, unique: true)

    # Optional modules (only add if you enable these in the User model)

    # :recoverable (password reset)
    add_column :users, :reset_password_token, :string
    add_column :users, :reset_password_sent_at, :datetime
    add_index  :users, :reset_password_token, unique: true

    # :rememberable (remember-me cookies)
    # add_column :users, :remember_created_at, :datetime
  end
end
