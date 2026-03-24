module PlanEnforcement
  extend ActiveSupport::Concern

  PLAN_LIMITS = {
    "free" => { customers: 50, staff: 1 },
    "starter" => { customers: 500, staff: 5 },
    "pro" => { customers: Float::INFINITY, staff: 15 },
    "enterprise" => { customers: Float::INFINITY, staff: Float::INFINITY }
  }.freeze

  private

  def enforce_customer_limit!
    limits = plan_limits
    count = current_tenant.users.customers.count
    if count >= limits[:customers]
      raise PlanLimitExceeded, "Customer limit reached (#{limits[:customers]} on #{current_tenant.plan} plan). Please upgrade."
    end
  end

  def enforce_staff_limit!
    limits = plan_limits
    count = current_tenant.users.staff_members.count
    if count >= limits[:staff]
      raise PlanLimitExceeded, "Staff limit reached (#{limits[:staff]} on #{current_tenant.plan} plan). Please upgrade."
    end
  end

  def plan_limits
    PLAN_LIMITS.fetch(current_tenant.plan, PLAN_LIMITS["free"])
  end

  def current_tenant
    ActsAsTenant.current_tenant
  end

  class PlanLimitExceeded < StandardError; end
end
