require "ipaddr"

module Geo
  # Countries where Spanish is the (or a) primary language — used to pick the
  # default UI language for a fresh visitor. Central America + the rest of
  # Spanish-speaking Latin America + Spain.
  SPANISH_SPEAKING_COUNTRIES = %w[
    ES MX GT HN SV NI CR PA CU DO PR CO VE EC PE BO PY UY AR CL
  ].freeze

  # Resolves an IP address to an ISO 3166-1 alpha-2 country code.
  #
  # Pluggable + resilient: results are cached in Solid Cache, lookups time out
  # fast, and ANY failure (network, bad IP, API down) returns nil so locale
  # resolution simply falls through to Accept-Language. The external provider
  # can be swapped (e.g. for a bundled MaxMind GeoLite2 DB) without changing
  # callers — they only use `Geo::CountryLookup.country_for(ip)`.
  class CountryLookup
    TIMEOUT = 1 # seconds
    SUCCESS_TTL = 30.days
    FAILURE_TTL = 1.hour
    PROVIDER_URL = "https://ipapi.co/%<ip>s/country/".freeze

    def self.country_for(ip)
      new(ip).country
    end

    def initialize(ip)
      @ip = ip.to_s.strip
    end

    def country
      return if @ip.blank? || private_or_local?

      key = "geoip:country:#{@ip}"
      return Rails.cache.read(key) if Rails.cache.exist?(key)

      code = fetch_country
      Rails.cache.write(key, code, expires_in: code ? SUCCESS_TTL : FAILURE_TTL)
      code
    end

    private

    def private_or_local?
      addr = IPAddr.new(@ip)
      addr.loopback? || addr.private? || addr.link_local?
    rescue IPAddr::InvalidAddressError
      true
    end

    def fetch_country
      response = Faraday.get(format(PROVIDER_URL, ip: @ip)) do |req|
        req.options.timeout = TIMEOUT
        req.options.open_timeout = TIMEOUT
      end
      return unless response.success?

      code = response.body.to_s.strip.upcase
      code if code.match?(/\A[A-Z]{2}\z/)
    rescue => e
      Rails.logger.warn("[Geo::CountryLookup] #{e.class}: #{e.message}")
      nil
    end
  end
end
