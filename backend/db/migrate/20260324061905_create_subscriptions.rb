class CreateSubscriptions < ActiveRecord::Migration[8.0]
  def change
    create_table :subscriptions do |t|
      t.references :tenant, null: false, foreign_key: true, index: false
      t.string :stripe_subscription_id
      t.string :stripe_price_id
      t.integer :status, default: 0, null: false
      t.datetime :current_period_end

      t.timestamps
    end
    add_index :subscriptions, :stripe_subscription_id, unique: true
    add_index :subscriptions, [:tenant_id], unique: true
  end
end
