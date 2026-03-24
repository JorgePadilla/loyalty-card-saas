class CreateVisits < ActiveRecord::Migration[8.0]
  def change
    create_table :visits do |t|
      t.references :tenant, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.references :staff, null: false, foreign_key: { to_table: :users }
      t.string :service_name
      t.integer :amount_cents, default: 0, null: false
      t.datetime :checked_in_at, null: false
      t.integer :points_earned, default: 0, null: false

      t.timestamps
    end
    add_index :visits, [:tenant_id, :user_id]
    add_index :visits, [:tenant_id, :checked_in_at]
  end
end
