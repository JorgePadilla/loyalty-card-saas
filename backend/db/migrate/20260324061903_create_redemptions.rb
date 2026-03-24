class CreateRedemptions < ActiveRecord::Migration[8.0]
  def change
    create_table :redemptions do |t|
      t.references :tenant, null: false, foreign_key: true
      t.references :loyalty_card, null: false, foreign_key: true
      t.references :reward, null: false, foreign_key: true
      t.integer :points_spent, null: false
      t.integer :status, default: 0, null: false

      t.timestamps
    end
    add_index :redemptions, [:tenant_id, :status]
    add_index :redemptions, [:tenant_id, :loyalty_card_id]
  end
end
