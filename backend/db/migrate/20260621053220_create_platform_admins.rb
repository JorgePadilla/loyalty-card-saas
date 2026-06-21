class CreatePlatformAdmins < ActiveRecord::Migration[8.0]
  def change
    create_table :platform_admins do |t|
      t.string :email_address
      t.string :password_digest
      t.string :name
      t.string :locale

      t.timestamps
    end
    add_index :platform_admins, :email_address, unique: true
  end
end
