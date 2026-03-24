class CreateTenants < ActiveRecord::Migration[8.0]
  def change
    create_table :tenants do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.string :logo_url
      t.string :theme_color, default: "#C9A84C"
      t.string :stripe_customer_id
      t.integer :plan, default: 0, null: false
      t.jsonb :settings, default: {}

      t.timestamps
    end
    add_index :tenants, :slug, unique: true
    add_index :tenants, :stripe_customer_id, unique: true
  end
end
