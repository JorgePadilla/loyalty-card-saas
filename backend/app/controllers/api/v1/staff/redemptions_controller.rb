class Api::V1::Staff::RedemptionsController < Api::V1::BaseController
  before_action :require_staff!

  def update
    redemption = Redemption.find(params[:id])
    new_status = params[:status]

    if %w[confirmed expired].include?(new_status)
      redemption.update!(status: new_status)
      render json: RedemptionBlueprint.render(redemption)
    else
      render_error("Invalid status. Must be 'confirmed' or 'expired'.")
    end
  end

  private

  def require_staff!
    render_error("Staff access required", status: :forbidden) unless current_api_user.staff_or_above?
  end
end
