class AddSuspendedAtToTenants < ActiveRecord::Migration[8.0]
  def change
    add_column :tenants, :suspended_at, :datetime
  end
end
