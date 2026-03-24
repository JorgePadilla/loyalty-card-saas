class CreateLoyaltyCards < ActiveRecord::Migration[8.0]
  def change
    create_table :loyalty_cards do |t|
      t.references :tenant, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.uuid :qr_code, null: false
      t.integer :tier, default: 0, null: false
      t.integer :total_points, default: 0, null: false
      t.integer :redeemed_points, default: 0, null: false
      t.integer :current_points, default: 0, null: false
      t.integer :visits_count, default: 0, null: false
      t.integer :streak_count, default: 0, null: false
      t.datetime :last_visit_at

      t.timestamps
    end
    add_index :loyalty_cards, :qr_code, unique: true
    add_index :loyalty_cards, [:tenant_id, :user_id], unique: true
  end
end
