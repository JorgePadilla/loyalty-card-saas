class Admin::VisitsController < Admin::BaseController
  def index
    authorize Visit
    @pagy, @visits = pagy(Visit.recent.includes(:user, :staff))
  end

  def show
    @visit = Visit.find(params[:id])
    authorize @visit
  end
end
