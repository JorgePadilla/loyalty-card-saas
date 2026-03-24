class UserPolicy < ApplicationPolicy
  def create?
    user.owner? || user.manager?
  end

  def update?
    user.owner? || user.manager?
  end

  def destroy?
    return false if record == user # can't delete yourself
    user.owner?
  end
end
