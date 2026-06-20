# Resolves and applies the request locale for the HTML (web) side of the app.
# Priority: ?locale param → signed-in user → remembered cookie → IP country
# → browser Accept-Language → default. Every candidate is validated against
# I18n.available_locales so a bad value can never set an unsupported locale.
module LocaleSelection
  extend ActiveSupport::Concern

  included do
    around_action :switch_locale
  end

  private

  def switch_locale(&action)
    I18n.with_locale(resolve_locale, &action)
  end

  def resolve_locale
    explicit_locale ||
      user_locale ||
      cookie_locale ||
      geo_locale ||
      accept_language_locale ||
      I18n.default_locale
  end

  def explicit_locale
    available_locale(params[:locale])
  end

  def user_locale
    available_locale(current_user&.locale)
  end

  def cookie_locale
    available_locale(cookies[:locale])
  end

  # IP country → Spanish for Spanish-speaking countries. Cached + fails to nil.
  # Only for anonymous visitors (marketing first-visit default); signed-in users
  # resolve via their saved locale/cookie, so we never make the external call on
  # authenticated pages like the admin dashboard.
  def geo_locale
    return if current_user

    country = Geo::CountryLookup.country_for(request.remote_ip)
    :es if country && Geo::SPANISH_SPEAKING_COUNTRIES.include?(country)
  end

  # Parse "es-MX,es;q=0.9,en;q=0.8" → first supported language code.
  def accept_language_locale
    header = request.env["HTTP_ACCEPT_LANGUAGE"]
    return if header.blank?

    header.split(",").each do |part|
      code = part.split(";").first.to_s.strip.downcase.split("-").first
      locale = available_locale(code)
      return locale if locale
    end
    nil
  end

  def available_locale(value)
    return if value.blank?

    locale = value.to_s.downcase.to_sym
    locale if I18n.available_locales.include?(locale)
  end
end
