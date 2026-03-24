class RedemptionBlueprint < Blueprinter::Base
  identifier :id
  fields :points_spent, :status, :created_at

  association :reward, blueprint: RewardBlueprint
end
