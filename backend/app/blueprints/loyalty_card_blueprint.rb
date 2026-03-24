class LoyaltyCardBlueprint < Blueprinter::Base
  identifier :id
  fields :qr_code, :tier, :total_points, :redeemed_points, :current_points,
         :visits_count, :streak_count, :last_visit_at

  association :user, blueprint: UserBlueprint
end
