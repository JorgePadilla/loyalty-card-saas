class Api::V1::RewardsController < Api::V1::BaseController
  def index
    rewards = Reward.active.order(:points_cost)
    render json: RewardBlueprint.render(rewards)
  end

  def show
    reward = Reward.find(params[:id])
    render json: RewardBlueprint.render(reward)
  end
end
