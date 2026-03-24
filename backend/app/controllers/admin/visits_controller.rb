class Admin::VisitsController < Admin::BaseController
  def index
    @visits = Visit.recent.includes(:user, :staff).limit(50)
  end

  def show
    @visit = Visit.find(params[:id])
  end
end
