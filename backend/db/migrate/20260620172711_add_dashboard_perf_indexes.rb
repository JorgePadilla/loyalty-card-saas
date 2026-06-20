class AddDashboardPerfIndexes < ActiveRecord::Migration[8.0]
  def change
    # Weekly points SUM (PointTransaction.earnings.where(created_at: ...)) — tenant-scoped.
    add_index :point_transactions, [:tenant_id, :created_at],
              if_not_exists: true, name: "index_point_transactions_on_tenant_and_created_at"

    # Top customers ORDER BY total_points DESC — tenant-scoped.
    add_index :loyalty_cards, [:tenant_id, :total_points],
              if_not_exists: true, name: "index_loyalty_cards_on_tenant_and_total_points"
  end
end
