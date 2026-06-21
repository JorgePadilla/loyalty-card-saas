class Platform::TenantsController < Platform::BaseController
  before_action :set_tenant, only: %i[show suspend reactivate update_plan impersonate]

  def index
    scope = Tenant.includes(:subscription)
    if params[:q].present?
      term = "%#{params[:q].strip}%"
      scope = scope.where("tenants.name ILIKE :q OR tenants.slug ILIKE :q", q: term)
    end
    @pagy, @tenants = pagy(scope.order(created_at: :desc))

    # Counts grouped once to avoid N+1 across the list.
    @customer_counts = User.customers.group(:tenant_id).count
    @staff_counts    = User.staff_members.group(:tenant_id).count
  end

  def show
    @subscription   = @tenant.subscription
    @owner          = User.where(tenant_id: @tenant.id, role: :owner).first
    @users          = User.staff_members.where(tenant_id: @tenant.id).order(:role, :created_at)
    @customer_count = User.customers.where(tenant_id: @tenant.id).count
    @staff_count    = User.staff_members.where(tenant_id: @tenant.id).count
  end

  def suspend
    @tenant.update!(suspended_at: Time.current)
    redirect_to platform_tenant_path(@tenant), notice: t("platform.tenants.flash.suspended")
  end

  def reactivate
    @tenant.update!(suspended_at: nil)
    redirect_to platform_tenant_path(@tenant), notice: t("platform.tenants.flash.reactivated")
  end

  def update_plan
    plan = params[:plan].to_s
    if Tenant.plans.key?(plan)
      @tenant.update!(plan: plan)
      redirect_to platform_tenant_path(@tenant), notice: t("platform.tenants.flash.plan_updated")
    else
      redirect_to platform_tenant_path(@tenant), alert: t("platform.tenants.flash.invalid_plan")
    end
  end

  # Log in as this tenant's owner (support). Keeps the platform session intact
  # and drops a signed marker so the admin area shows a "stop impersonating" banner.
  def impersonate
    owner = User.where(tenant_id: @tenant.id, role: :owner).first
    unless owner
      redirect_to platform_tenant_path(@tenant), alert: t("platform.tenants.flash.no_owner")
      return
    end

    session = owner.sessions.create!(user_agent: request.user_agent, ip_address: request.remote_ip)
    cookies.signed.permanent[:session_id]   = { value: session.id, httponly: true, same_site: :lax }
    cookies.signed[:impersonator_id]         = { value: current_platform_admin.id, httponly: true, same_site: :lax }
    redirect_to admin_root_path
  end

  private

  def set_tenant
    @tenant = Tenant.find(params[:id])
  end
end
