class AddFieldsToUsers < ActiveRecord::Migration[8.0]
  def change
    add_reference :users, :tenant, null: false, foreign_key: true
    add_column :users, :first_name, :string
    add_column :users, :last_name, :string
    add_column :users, :phone, :string
    add_column :users, :role, :integer, default: 0, null: false
    add_column :users, :stripe_customer_id, :string
    add_column :users, :refresh_token, :string

    add_index :users, [:tenant_id, :email_address], unique: true
  end
end
