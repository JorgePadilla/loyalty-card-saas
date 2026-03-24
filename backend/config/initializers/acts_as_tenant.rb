ActsAsTenant.configure do |config|
  config.require_tenant = false # Allow unauthenticated pages (marketing, login)
end
