class VisitBlueprint < Blueprinter::Base
  identifier :id
  fields :service_name, :amount_cents, :checked_in_at, :points_earned, :created_at

  association :user, blueprint: UserBlueprint
  association :staff, blueprint: UserBlueprint
end
