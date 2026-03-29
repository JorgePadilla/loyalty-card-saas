# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2026_03_24_061906) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "campaigns", force: :cascade do |t|
    t.bigint "tenant_id", null: false
    t.string "name", null: false
    t.text "description"
    t.decimal "multiplier", precision: 5, scale: 2, default: "1.0", null: false
    t.datetime "starts_at", null: false
    t.datetime "ends_at", null: false
    t.jsonb "target_segment", default: {}
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tenant_id", "active"], name: "index_campaigns_on_tenant_id_and_active"
    t.index ["tenant_id", "starts_at", "ends_at"], name: "index_campaigns_on_tenant_id_and_starts_at_and_ends_at"
    t.index ["tenant_id"], name: "index_campaigns_on_tenant_id"
  end

  create_table "loyalty_cards", force: :cascade do |t|
    t.bigint "tenant_id", null: false
    t.bigint "user_id", null: false
    t.uuid "qr_code", null: false
    t.integer "tier", default: 0, null: false
    t.integer "total_points", default: 0, null: false
    t.integer "redeemed_points", default: 0, null: false
    t.integer "current_points", default: 0, null: false
    t.integer "visits_count", default: 0, null: false
    t.integer "streak_count", default: 0, null: false
    t.datetime "last_visit_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["qr_code"], name: "index_loyalty_cards_on_qr_code", unique: true
    t.index ["tenant_id", "user_id"], name: "index_loyalty_cards_on_tenant_id_and_user_id", unique: true
    t.index ["tenant_id"], name: "index_loyalty_cards_on_tenant_id"
    t.index ["user_id"], name: "index_loyalty_cards_on_user_id"
  end

  create_table "point_transactions", force: :cascade do |t|
    t.bigint "tenant_id", null: false
    t.bigint "loyalty_card_id", null: false
    t.integer "kind", null: false
    t.integer "points", null: false
    t.string "description"
    t.bigint "staff_id"
    t.bigint "visit_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["loyalty_card_id"], name: "index_point_transactions_on_loyalty_card_id"
    t.index ["staff_id"], name: "index_point_transactions_on_staff_id"
    t.index ["tenant_id", "kind"], name: "index_point_transactions_on_tenant_id_and_kind"
    t.index ["tenant_id", "loyalty_card_id"], name: "index_point_transactions_on_tenant_id_and_loyalty_card_id"
    t.index ["tenant_id"], name: "index_point_transactions_on_tenant_id"
    t.index ["visit_id"], name: "index_point_transactions_on_visit_id"
  end

  create_table "redemptions", force: :cascade do |t|
    t.bigint "tenant_id", null: false
    t.bigint "loyalty_card_id", null: false
    t.bigint "reward_id", null: false
    t.integer "points_spent", null: false
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["loyalty_card_id"], name: "index_redemptions_on_loyalty_card_id"
    t.index ["reward_id"], name: "index_redemptions_on_reward_id"
    t.index ["tenant_id", "loyalty_card_id"], name: "index_redemptions_on_tenant_id_and_loyalty_card_id"
    t.index ["tenant_id", "status"], name: "index_redemptions_on_tenant_id_and_status"
    t.index ["tenant_id"], name: "index_redemptions_on_tenant_id"
  end

  create_table "rewards", force: :cascade do |t|
    t.bigint "tenant_id", null: false
    t.string "name", null: false
    t.text "description"
    t.string "image_url"
    t.integer "points_cost", null: false
    t.integer "reward_type", default: 0, null: false
    t.boolean "active", default: true, null: false
    t.integer "tier_required"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tenant_id", "active"], name: "index_rewards_on_tenant_id_and_active"
    t.index ["tenant_id"], name: "index_rewards_on_tenant_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "ip_address"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "solid_cable_messages", force: :cascade do |t|
    t.binary "channel", null: false
    t.binary "payload", null: false
    t.datetime "created_at", null: false
    t.bigint "channel_hash", null: false
    t.index ["channel"], name: "index_solid_cable_messages_on_channel"
    t.index ["channel_hash"], name: "index_solid_cable_messages_on_channel_hash"
    t.index ["created_at"], name: "index_solid_cable_messages_on_created_at"
  end

  create_table "solid_cache_entries", force: :cascade do |t|
    t.binary "key", null: false
    t.binary "value", null: false
    t.datetime "created_at", null: false
    t.bigint "key_hash", null: false
    t.integer "byte_size", null: false
    t.index ["byte_size"], name: "index_solid_cache_entries_on_byte_size"
    t.index ["key_hash", "byte_size"], name: "index_solid_cache_entries_on_key_hash_and_byte_size"
    t.index ["key_hash"], name: "index_solid_cache_entries_on_key_hash", unique: true
  end

  create_table "solid_queue_blocked_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.string "queue_name", null: false
    t.integer "priority", default: 0, null: false
    t.string "concurrency_key", null: false
    t.datetime "expires_at", null: false
    t.datetime "created_at", null: false
    t.index ["concurrency_key", "priority", "job_id"], name: "index_solid_queue_blocked_executions_for_release"
    t.index ["expires_at", "concurrency_key"], name: "index_solid_queue_blocked_executions_for_maintenance"
    t.index ["job_id"], name: "index_solid_queue_blocked_executions_on_job_id", unique: true
  end

  create_table "solid_queue_claimed_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.bigint "process_id"
    t.datetime "created_at", null: false
    t.index ["job_id"], name: "index_solid_queue_claimed_executions_on_job_id", unique: true
    t.index ["process_id", "job_id"], name: "index_solid_queue_claimed_executions_on_process_id_and_job_id"
  end

  create_table "solid_queue_failed_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.text "error"
    t.datetime "created_at", null: false
    t.index ["job_id"], name: "index_solid_queue_failed_executions_on_job_id", unique: true
  end

  create_table "solid_queue_jobs", force: :cascade do |t|
    t.string "queue_name", null: false
    t.string "class_name", null: false
    t.text "arguments"
    t.integer "priority", default: 0, null: false
    t.string "active_job_id"
    t.datetime "scheduled_at"
    t.datetime "finished_at"
    t.string "concurrency_key"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active_job_id"], name: "index_solid_queue_jobs_on_active_job_id"
    t.index ["class_name"], name: "index_solid_queue_jobs_on_class_name"
    t.index ["finished_at"], name: "index_solid_queue_jobs_on_finished_at"
    t.index ["queue_name", "finished_at"], name: "index_solid_queue_jobs_for_filtering"
    t.index ["scheduled_at", "finished_at"], name: "index_solid_queue_jobs_for_alerting"
  end

  create_table "solid_queue_pauses", force: :cascade do |t|
    t.string "queue_name", null: false
    t.datetime "created_at", null: false
    t.index ["queue_name"], name: "index_solid_queue_pauses_on_queue_name", unique: true
  end

  create_table "solid_queue_processes", force: :cascade do |t|
    t.string "kind", null: false
    t.datetime "last_heartbeat_at", null: false
    t.bigint "supervisor_id"
    t.integer "pid", null: false
    t.string "hostname"
    t.text "metadata"
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.index ["last_heartbeat_at"], name: "index_solid_queue_processes_on_last_heartbeat_at"
    t.index ["name", "supervisor_id"], name: "index_solid_queue_processes_on_name_and_supervisor_id", unique: true
    t.index ["supervisor_id"], name: "index_solid_queue_processes_on_supervisor_id"
  end

  create_table "solid_queue_ready_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.string "queue_name", null: false
    t.integer "priority", default: 0, null: false
    t.datetime "created_at", null: false
    t.index ["job_id"], name: "index_solid_queue_ready_executions_on_job_id", unique: true
    t.index ["priority", "job_id"], name: "index_solid_queue_poll_all"
    t.index ["queue_name", "priority", "job_id"], name: "index_solid_queue_poll_by_queue"
  end

  create_table "solid_queue_recurring_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.string "task_key", null: false
    t.datetime "run_at", null: false
    t.datetime "created_at", null: false
    t.index ["job_id"], name: "index_solid_queue_recurring_executions_on_job_id", unique: true
    t.index ["task_key", "run_at"], name: "index_solid_queue_recurring_executions_on_task_key_and_run_at", unique: true
  end

  create_table "solid_queue_recurring_tasks", force: :cascade do |t|
    t.string "key", null: false
    t.string "schedule", null: false
    t.string "command", limit: 2048
    t.string "class_name"
    t.text "arguments"
    t.string "queue_name"
    t.integer "priority", default: 0
    t.boolean "static", default: true, null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_solid_queue_recurring_tasks_on_key", unique: true
    t.index ["static"], name: "index_solid_queue_recurring_tasks_on_static"
  end

  create_table "solid_queue_scheduled_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.string "queue_name", null: false
    t.integer "priority", default: 0, null: false
    t.datetime "scheduled_at", null: false
    t.datetime "created_at", null: false
    t.index ["job_id"], name: "index_solid_queue_scheduled_executions_on_job_id", unique: true
    t.index ["scheduled_at", "priority", "job_id"], name: "index_solid_queue_dispatch_all"
  end

  create_table "solid_queue_semaphores", force: :cascade do |t|
    t.string "key", null: false
    t.integer "value", default: 1, null: false
    t.datetime "expires_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["expires_at"], name: "index_solid_queue_semaphores_on_expires_at"
    t.index ["key", "value"], name: "index_solid_queue_semaphores_on_key_and_value"
    t.index ["key"], name: "index_solid_queue_semaphores_on_key", unique: true
  end

  create_table "subscriptions", force: :cascade do |t|
    t.bigint "tenant_id", null: false
    t.string "stripe_subscription_id"
    t.string "stripe_price_id"
    t.integer "status", default: 0, null: false
    t.datetime "current_period_end"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["stripe_subscription_id"], name: "index_subscriptions_on_stripe_subscription_id", unique: true
    t.index ["tenant_id"], name: "index_subscriptions_on_tenant_id", unique: true
  end

  create_table "tenants", force: :cascade do |t|
    t.string "name", null: false
    t.string "slug", null: false
    t.string "logo_url"
    t.string "theme_color", default: "#C9A84C"
    t.string "stripe_customer_id"
    t.integer "plan", default: 0, null: false
    t.jsonb "settings", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_tenants_on_slug", unique: true
    t.index ["stripe_customer_id"], name: "index_tenants_on_stripe_customer_id", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "tenant_id", null: false
    t.string "first_name"
    t.string "last_name"
    t.string "phone"
    t.integer "role", default: 0, null: false
    t.string "stripe_customer_id"
    t.string "refresh_token"
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
    t.index ["tenant_id", "email_address"], name: "index_users_on_tenant_id_and_email_address", unique: true
    t.index ["tenant_id"], name: "index_users_on_tenant_id"
  end

  create_table "visits", force: :cascade do |t|
    t.bigint "tenant_id", null: false
    t.bigint "user_id", null: false
    t.bigint "staff_id", null: false
    t.string "service_name"
    t.integer "amount_cents", default: 0, null: false
    t.datetime "checked_in_at", null: false
    t.integer "points_earned", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["staff_id"], name: "index_visits_on_staff_id"
    t.index ["tenant_id", "checked_in_at"], name: "index_visits_on_tenant_id_and_checked_in_at"
    t.index ["tenant_id", "user_id"], name: "index_visits_on_tenant_id_and_user_id"
    t.index ["tenant_id"], name: "index_visits_on_tenant_id"
    t.index ["user_id"], name: "index_visits_on_user_id"
  end

  add_foreign_key "campaigns", "tenants"
  add_foreign_key "loyalty_cards", "tenants"
  add_foreign_key "loyalty_cards", "users"
  add_foreign_key "point_transactions", "loyalty_cards"
  add_foreign_key "point_transactions", "tenants"
  add_foreign_key "point_transactions", "users", column: "staff_id"
  add_foreign_key "point_transactions", "visits"
  add_foreign_key "redemptions", "loyalty_cards"
  add_foreign_key "redemptions", "rewards"
  add_foreign_key "redemptions", "tenants"
  add_foreign_key "rewards", "tenants"
  add_foreign_key "sessions", "users"
  add_foreign_key "solid_queue_blocked_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_claimed_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_failed_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_ready_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_recurring_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_scheduled_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "subscriptions", "tenants"
  add_foreign_key "users", "tenants"
  add_foreign_key "visits", "tenants"
  add_foreign_key "visits", "users"
  add_foreign_key "visits", "users", column: "staff_id"
end
