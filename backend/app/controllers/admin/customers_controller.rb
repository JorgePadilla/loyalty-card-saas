class Admin::CustomersController < Admin::BaseController
  def index
    authorize User, :index?

    scope = User.customers.includes(:loyalty_card).references(:loyalty_card)

    if params[:q].present?
      term = "%#{params[:q].strip}%"
      scope = scope.where(
        "users.first_name ILIKE :q OR users.last_name ILIKE :q OR " \
        "users.email_address ILIKE :q OR users.phone ILIKE :q",
        q: term
      )
    end

    @sort = %w[recent points inactive name].include?(params[:sort]) ? params[:sort] : "recent"
    scope = case @sort
            when "points"   then scope.order(Arel.sql("loyalty_cards.total_points DESC NULLS LAST"))
            when "inactive" then scope.order(Arel.sql("loyalty_cards.last_visit_at ASC NULLS FIRST"))
            when "name"     then scope.order(:first_name, :last_name)
            else                 scope.order(Arel.sql("loyalty_cards.last_visit_at DESC NULLS LAST"))
            end

    @q = params[:q]
    @pagy, @customers = pagy(scope)
  end
end
