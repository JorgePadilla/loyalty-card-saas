class Admin::CampaignsController < Admin::BaseController
  before_action :set_campaign, only: %i[show edit update destroy]

  def index
    @campaigns = Campaign.order(created_at: :desc)
  end

  def show
  end

  def new
    @campaign = Campaign.new(starts_at: Time.current, ends_at: 7.days.from_now, multiplier: 2.0)
  end

  def create
    @campaign = Campaign.new(campaign_params)
    if @campaign.save
      redirect_to admin_campaigns_path, notice: "Campaign created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @campaign.update(campaign_params)
      redirect_to admin_campaigns_path, notice: "Campaign updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @campaign.destroy
    redirect_to admin_campaigns_path, notice: "Campaign deleted."
  end

  private

  def set_campaign
    @campaign = Campaign.find(params[:id])
  end

  def campaign_params
    params.require(:campaign).permit(:name, :description, :multiplier, :starts_at, :ends_at, :active)
  end
end
