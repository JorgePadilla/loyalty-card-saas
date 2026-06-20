class SubscriptionPolicy < ApplicationPolicy
  # Billing is owner-only — staff and managers can't view or change the plan.
  def show?
    user.owner?
  end

  def create?
    user.owner?
  end

  def billing_portal?
    user.owner?
  end
end
