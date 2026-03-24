class VisitPolicy < ApplicationPolicy
  def create?
    user.staff_or_above?
  end
end
