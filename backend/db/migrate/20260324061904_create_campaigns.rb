class CreateCampaigns < ActiveRecord::Migration[8.0]
  def change
    create_table :campaigns do |t|
      t.references :tenant, null: false, foreign_key: true
      t.string :name, null: false
      t.text :description
      t.decimal :multiplier, precision: 5, scale: 2, default: 1.0, null: false
      t.datetime :starts_at, null: false
      t.datetime :ends_at, null: false
      t.jsonb :target_segment, default: {}
      t.boolean :active, default: true, null: false

      t.timestamps
    end
    add_index :campaigns, [:tenant_id, :active]
    add_index :campaigns, [:tenant_id, :starts_at, :ends_at]
  end
end
