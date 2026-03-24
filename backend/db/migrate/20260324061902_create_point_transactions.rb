class CreatePointTransactions < ActiveRecord::Migration[8.0]
  def change
    create_table :point_transactions do |t|
      t.references :tenant, null: false, foreign_key: true
      t.references :loyalty_card, null: false, foreign_key: true
      t.integer :kind, null: false
      t.integer :points, null: false
      t.string :description
      t.references :staff, foreign_key: { to_table: :users }
      t.references :visit, foreign_key: true

      t.timestamps
    end
    add_index :point_transactions, [:tenant_id, :loyalty_card_id]
    add_index :point_transactions, [:tenant_id, :kind]
  end
end
