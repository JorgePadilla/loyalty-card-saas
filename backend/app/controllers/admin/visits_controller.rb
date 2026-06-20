class Admin::VisitsController < Admin::BaseController
  def index
    authorize Visit
    @visits = Visit.recent.includes(:user, :staff).limit(50)
  end

  def show
    @visit = Visit.find(params[:id])
    authorize @visit
  end
end
