class JwtService
  SECRET = Rails.application.credentials.secret_key_base
  ALGORITHM = "HS256"
  ACCESS_TOKEN_EXPIRY = 24.hours
  REFRESH_TOKEN_EXPIRY = 30.days

  def self.encode(payload, expiry = ACCESS_TOKEN_EXPIRY)
    payload[:exp] = expiry.from_now.to_i
    payload[:iat] = Time.current.to_i
    JWT.encode(payload, SECRET, ALGORITHM)
  end

  def self.decode(token)
    decoded = JWT.decode(token, SECRET, true, algorithm: ALGORITHM)
    HashWithIndifferentAccess.new(decoded.first)
  rescue JWT::DecodeError, JWT::ExpiredSignature => e
    nil
  end

  def self.generate_refresh_token
    SecureRandom.hex(32)
  end
end
