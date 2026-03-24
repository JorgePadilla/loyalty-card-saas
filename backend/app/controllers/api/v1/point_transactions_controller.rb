class Api::V1::PointTransactionsController < Api::V1::BaseController
  def index
    card = current_api_user.loyalty_card
    transactions = card.point_transactions.recent
    render json: PointTransactionBlueprint.render(transactions)
  end
end
