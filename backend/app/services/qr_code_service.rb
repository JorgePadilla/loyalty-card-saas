class QrCodeService
  EXPIRY = 60 # seconds
  SECRET = Rails.application.credentials.secret_key_base

  def self.generate_payload(loyalty_card)
    timestamp = Time.current.to_i
    data = "#{loyalty_card.qr_code}:#{timestamp}"
    hmac = OpenSSL::HMAC.hexdigest("SHA256", SECRET, data)
    "#{data}:#{hmac}"
  end

  def self.verify_payload(payload)
    parts = payload.to_s.split(":")
    return nil unless parts.length == 3

    qr_code, timestamp, hmac = parts
    return nil unless timestamp.to_i > (Time.current.to_i - EXPIRY)

    expected_hmac = OpenSSL::HMAC.hexdigest("SHA256", SECRET, "#{qr_code}:#{timestamp}")
    return nil unless ActiveSupport::SecurityUtils.secure_compare(hmac, expected_hmac)

    qr_code
  end
end
