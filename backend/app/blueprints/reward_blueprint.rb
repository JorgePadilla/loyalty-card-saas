class RewardBlueprint < Blueprinter::Base
  identifier :id
  fields :name, :description, :image_url, :points_cost, :reward_type,
         :active, :tier_required, :created_at
end
