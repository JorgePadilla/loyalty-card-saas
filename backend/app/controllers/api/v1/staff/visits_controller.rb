class Api::V1::Staff::VisitsController < Api::V1::BaseController
  before_action :require_staff!

  def index
    visits = Visit.recent.includes(:user, :staff).limit(50)
    render json: VisitBlueprint.render(visits)
  end

  private

  def require_staff!
    render_error("Staff access required", status: :forbidden) unless current_api_user.staff_or_above?
  end
end
