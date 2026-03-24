class Api::V1::LoyaltyCardsController < Api::V1::BaseController
  def show
    card = current_api_user.loyalty_card
    if card
      render json: LoyaltyCardBlueprint.render(card)
    else
      render_error("No loyalty card found", status: :not_found)
    end
  end
end
