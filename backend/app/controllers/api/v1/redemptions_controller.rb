class Api::V1::RedemptionsController < Api::V1::BaseController
  def index
    card = current_api_user.loyalty_card
    redemptions = card.redemptions.recent.includes(:reward)
    render json: RedemptionBlueprint.render(redemptions)
  end

  def create
    card = current_api_user.loyalty_card
    reward = Reward.find(params[:reward_id])
    result = RedemptionService.new(loyalty_card: card, reward: reward).call

    if result.success?
      render json: RedemptionBlueprint.render(result.redemption), status: :created
    else
      render_error(result.error)
    end
  end
end
