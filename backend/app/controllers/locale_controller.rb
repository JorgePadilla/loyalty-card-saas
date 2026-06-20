# Handles the manual EN/ES switcher. Persists the choice to a permanent cookie
# (remembered for guests) and to the signed-in user's `locale` column, then
# returns the visitor to the page they were on.
class LocaleController < ApplicationController
  allow_unauthenticated_access

  def update
    locale = params[:locale].to_s.downcase
    if I18n.available_locales.map(&:to_s).include?(locale)
      cookies.permanent[:locale] = { value: locale, same_site: :lax }
      current_user&.update(locale: locale)
    end
    redirect_back fallback_location: root_path
  end
end
