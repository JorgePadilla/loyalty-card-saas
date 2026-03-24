class CreateRewards < ActiveRecord::Migration[8.0]
  def change
    create_table :rewards do |t|
      t.references :tenant, null: false, foreign_key: true
      t.string :name, null: false
      t.text :description
      t.string :image_url
      t.integer :points_cost, null: false
      t.integer :reward_type, default: 0, null: false
      t.boolean :active, default: true, null: false
      t.integer :tier_required

      t.timestamps
    end
    add_index :rewards, [:tenant_id, :active]
  end
end
