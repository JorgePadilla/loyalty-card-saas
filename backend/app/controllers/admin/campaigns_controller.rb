class Admin::CampaignsController < Admin::BaseController
  before_action :set_campaign, only: %i[show edit update destroy]

  def index
    authorize Campaign
    @campaigns = Campaign.order(created_at: :desc)
  end

  def show
    authorize @campaign
  end

  def new
    @campaign = Campaign.new(starts_at: Time.current, ends_at: 7.days.from_now, multiplier: 2.0)
    authorize @campaign
  end

  def create
    @campaign = Campaign.new(campaign_params)
    authorize @campaign
    if @campaign.save
      redirect_to admin_campaigns_path, notice: t("admin.campaigns.flash.created")
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @campaign
  end

  def update
    authorize @campaign
    if @campaign.update(campaign_params)
      redirect_to admin_campaigns_path, notice: t("admin.campaigns.flash.updated")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @campaign
    @campaign.destroy
    redirect_to admin_campaigns_path, notice: t("admin.campaigns.flash.deleted")
  end

  private

  def set_campaign
    @campaign = Campaign.find(params[:id])
  end

  def campaign_params
    params.require(:campaign).permit(:name, :description, :multiplier, :starts_at, :ends_at, :active)
  end
end
